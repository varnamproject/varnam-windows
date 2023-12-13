##
# Copyright (C) Navaneeth.K.N
#
# This is part of libvarnam. See LICENSE.txt for the license
##

require 'ffi'
require 'singleton'

# Ruby wrapper for libvarnam
module VarnamLibrary
  extend FFI::Library
  ffi_lib $library

  class Symbol < FFI::Struct
    layout :Identifier, :int,
    :Type, :int,
    :MatchType, :int,
    :Pattern, :string,
    :Value1, :string,
    :Value2, :string,
    :Value3, :string,
    :Tag, :string,
    :Weight, :int,
    :Priority, :int,
    :AcceptCondition, :int,
    :Flags, :int

    def value1=(val)
      pos = offset_of(:Value1)  
      if val.nil?
        self.pointer.put_pointer(pos, FFI::MemoryPointer::NULL)
      elsif val.is_a?(FFI::MemoryPointer)
        self.pointer.put_pointer(pos, val)
      else
        fail("name= requires an FFI::MemoryPointer or nil")
      end
    end
  end

  class SchemeDetails < FFI::Struct
    layout :identifier, :pointer,
      :langCode, :pointer,
      :displayName, :pointer,
      :author, :pointer,
      :compiledDate, :pointer,
      :isStable, :int
  end

  class Suggestion < FFI::Struct
    layout :Word, :string,
    :Weight, :int,
    :LearnedOn, :int
  end

  attach_function :varnam_debug, [:int, :int], :void
  attach_function :varnam_get_last_error, [:int], :string
  attach_function :varnam_set_vst_lookup_dir, [:string], :int
  attach_function :varnam_config, [:int, :int, :int], :int

  attach_function :varnam_new_search_symbol, [:pointer], :int
  attach_function :varnam_search_symbol_table, [:int, :int, Symbol.by_value, :pointer], :int

  attach_function :varnam_init, [:string, :string, :pointer], :int
  attach_function :varnam_transliterate, [:int, :int, :string, :pointer], :int
  attach_function :varnam_reverse_transliterate, [:int, :string, :pointer], :int

  attach_function :vm_init, [:string, :pointer], :int
  attach_function :vm_create_token, [:int, :string, :string, :string, :string, :string, :int, :int, :int, :int, :int], :int
  attach_function :vm_delete_token, [:int, Symbol.by_value], :int
  attach_function :vm_flush_buffer, [:int], :int
  attach_function :vm_set_scheme_details, [:int, :pointer], :int

  attach_function :varray_get, [:pointer, :int], :pointer
  attach_function :varray_length, [:pointer], :int
end

VarnamSymbol = Struct.new(:type, :pattern, :value1, :value2, :value3, :tag, :match_type, :priority, :accept_condition, :flags, :weight)
Suggestion = Struct.new(:Word, :Weight, :LearnedOn)
VarnamSchemeDetails = Struct.new(:langCode, :identifier, :displayName, :author, :compiledDate, :isStable)

module Varnam
  VARNAM_SYMBOL_VOWEL           = 1
  VARNAM_SYMBOL_CONSONANT       = 2
  VARNAM_SYMBOL_DEAD_CONSONANT  = 3
  VARNAM_SYMBOL_CONSONANT_VOWEL = 4
  VARNAM_SYMBOL_NUMBER          = 5
  VARNAM_SYMBOL_SYMBOL          = 6
  VARNAM_SYMBOL_ANUSVARA        = 7
  VARNAM_SYMBOL_VISARGA         = 8
  VARNAM_SYMBOL_VIRAMA          = 9
  VARNAM_SYMBOL_OTHER           = 10
  VARNAM_SYMBOL_NON_JOINER      = 11
  VARNAM_SYMBOL_JOINER          = 12
  VARNAM_SYMBOL_PERIOD          = 13

  VARNAM_MATCH_EXACT           = 1
  VARNAM_MATCH_POSSIBILITY     = 2

  VARNAM_CONFIG_USE_DEAD_CONSONANTS    = 100
  VARNAM_CONFIG_IGNORE_DUPLICATE_TOKEN = 101
  VARNAM_CONFIG_ENABLE_SUGGESTIONS = 102
  VARNAM_CONFIG_USE_INDIC_DIGITS = 103
  VARNAM_CONFIG_SET_DICTIONARY_SUGGESTIONS_LIMIT = 104
  VARNAM_CONFIG_SET_PATTERN_DICTIONARY_SUGGESTIONS_LIMIT = 105
  VARNAM_CONFIG_SET_TOKENIZER_SUGGESTIONS_LIMIT = 106
  VARNAM_CONFIG_SET_DICTIONARY_MATCH_EXACT = 107

  VARNAM_TOKEN_PRIORITY_HIGH = 1
  VARNAM_TOKEN_PRIORITY_NORMAL = 0
  VARNAM_TOKEN_PRIORITY_LOW = -1

  VARNAM_TOKEN_ACCEPT_ALL = 0
  VARNAM_TOKEN_ACCEPT_IF_STARTS_WITH = 1
  VARNAM_TOKEN_ACCEPT_IF_IN_BETWEEN = 2
  VARNAM_TOKEN_ACCEPT_IF_ENDS_WITH = 3

  VARNAM_LOG_DEFAULT = 1
  VARNAM_LOG_DEBUG = 2

  class RuntimeContext
    include Singleton

    def initialize
      @errors = 0
      @warnings = 0
      @tokens = {}
      @current_expression = ""
      @error_messages = []
      @warning_messages = []
      @current_tag = nil
    end

    def errored
      @errors += 1
    end

    def warned
      @warnings += 1
    end

    def errors
      @errors
    end

    def warnings
      @warnings
    end

    attr_accessor :tokens, :current_expression, :error_messages, :warning_messages, :current_tag
  end
end

def _context
  return Varnam::RuntimeContext.instance
end

def get_source_file_with_linenum
  Kernel::caller.last.sub(":in `<main>'", "")  # We don't need :in `<main>' to appear and make confusion
end

def inform(message)
  puts "   #{message}"
end

def warn(message)
  if _context.current_expression.nil?
    _context.warning_messages.push "#{get_source_file_with_linenum} : WARNING: #{message}"
  else
    _context.warning_messages.push "#{get_source_file_with_linenum} : WARNING: In expression #{_context.current_expression}. #{message}"
  end
  _context.warned
end

def error(message)
  if _context.current_expression.nil?
    _context.error_messages.push "#{get_source_file_with_linenum} : ERROR : #{message}"
  else
    _context.error_messages.push "#{get_source_file_with_linenum} : ERROR : In expression #{_context.current_expression}. #{message}"
  end
  _context.errored
end
