# encoding: utf-8

def gem_available?(name)
	require name
rescue LoadError
  false
end

if not gem_available?('ffi')
  puts "Can't find gem - ffi. To install run '[sudo] gem install ffi'"
  exit(1)
end

$library = nil
def find_govarnam
  return $library if not $library.nil?

  # Trying to find out govarnam in the predefined locations if
  # absolute path to the library is not specified
  govarnam_search_paths = ['.', File.dirname(File.expand_path(__FILE__)), '/usr/local/lib', '/usr/local/lib/i386-linux-gnu', '/usr/local/lib/x86_64-linux-gnu', '/usr/lib/i386-linux-gnu', '/usr/lib/x86_64-linux-gnu', '/usr/lib']
  govarnam_names = ['libgovarnam.so', "libgovarnam.so.#{$govarnam_major_version}", 'libgovarnam.dylib', 'varnam.dll']
  govarnam_search_paths.each do |path|
    govarnam_names.each do |fname|
      fullpath = File.join(path, fname)
      if File.exist?(fullpath)
        $library = fullpath
        return $library
      end
    end
  end
  nil
end

def initialize_vst_maker_handle(vst_path)
  require_relative './varnamruby.rb'

  varnam_handle_ptr = FFI::MemoryPointer.new :pointer

  initialized = VarnamLibrary.vm_init(vst_path, varnam_handle_ptr)

  varnam_handle = varnam_handle_ptr.read_int

  if initialized != 0
    msg = VarnamLibrary.varnam_get_last_error(varnam_handle)
    puts "Varnam initialization failed #{msg}"
    exit(1)
  end

  varnam_handle
end

class VarnamInstance
  def initialize(vst_path, learnings_path)
    require_relative './varnamruby'

    varnam_handle_ptr = FFI::MemoryPointer.new :pointer
    VarnamLibrary.varnam_init(vst_path, learnings_path, varnam_handle_ptr)
    @handle = varnam_handle_ptr.read_int
  end

  def config(key, value)
    configured = VarnamLibrary.varnam_config(@handle, key, value)
    if configured != 0
      error_message = VarnamLibrary.varnam_get_last_error(@handle)
      error error_message
      return
    end
    true
  end

  def transliterate(input)
    arr_ptr = FFI::MemoryPointer.new :pointer
    VarnamLibrary.varnam_transliterate(
      @handle,
      1,
      input,
      arr_ptr
    )

    sugs = []
    size = VarnamLibrary.varray_length(arr_ptr.get_pointer(0))
    0.upto(size - 1) do |i|
      word_ptr = VarnamLibrary.varray_get(arr_ptr.get_pointer(0), i)
      vsug = VarnamLibrary::Suggestion.new(word_ptr)
      sugs.push(
        Suggestion.new(
          vsug[:Word].force_encoding('UTF-8'),
          vsug[:Weight],
          vsug[:LearnedOn]
        )
      )
    end
    sugs
  end

  def reverse_transliterate(input)
    arr_ptr = FFI::MemoryPointer.new :pointer
    VarnamLibrary.varnam_reverse_transliterate(
      @handle,
      input,
      arr_ptr
    )

    result = []
    size = VarnamLibrary.varray_length(arr_ptr.get_pointer(0))
    0.upto(size - 1) do |i|
      word_ptr = VarnamLibrary.varray_get(arr_ptr.get_pointer(0), i)
      result.push(word_ptr.get_pointer(0).get_string(0).force_encoding('UTF-8'))
    end
    result
  end
end
