# VarnamIME for Windows

Easily type Indian languages on Windows using [Varnam transliteration engine](https://varnamproject.github.io/).

> [!NOTE]
> This project is a hard-fork of [ime-rs](https://github.com/saschanaz/ime-rs) extended to support plugging Varnam as the transliteration engine on native Windows IME.
> 
> **Project Status:** _Experimental_. Please refer to the [Checklist](#checklist) for pending tasks.

## Build

**Prerequisites:**
- Windows 64bit
- [Visual Studio](https://visualstudio.microsoft.com/downloads/) (Including command-line utils: `lib.exe` and `gendef.exe`)
- [Rust](https://www.rust-lang.org/)
- [Go](https://go.dev/)
- [msys64](https://www.msys2.org/)
- [PowerShell](https://www.microsoft.com/store/productId/9MZ1SNWT0N5D)

### Setup:

**1.** Install cbindgen for Rust:

```
cargo install cbindgen
```

**2.** Compile the libgovarnam shared library

```
cd varnam-windows\govarnam
windows-build.bat
```

This will generate a dynamically linked DLL: `libgovarnam.dll`.

**3.** Open the project **Varnam Windows** by opening the file `cpp\VarnamWindows.sln` in Visual Studio.

**4.** Build and compile the bundle:

```
Build -> Clean Varnam Windows
Build -> Rebuild Varnam Windows
```

This should install the `libgovarnam.dll` and `libgovarnam.lib` into the env configured PATH - `C:\lib` and fetch the latest language schemes from https://github.com/varnamproject/schemes and place them inside the `C:\Users\<username>\.libvarnam` directory.

**5.** Open "Command Prompt" as Administrator, navigate to `varnam-windows\cpp\x64\Debug` and register the DLL to install Varnam as the native IME for the supported languages.

```
regsvr32 "Varnam Windows.dll"
```

To unregister the DLL, run:

```
regsvr32 /u "Varnam Windows.dll"
```

> [!IMPORTANT]  
> Only the x64/Debug configuration build is supported.

## Checklist

- [x] Compile [govarnam](https://github.com/varnamproject/govarnam) into a DLL and LIB to use as a shared library on Windows.
- [x] Call the DLL from Rust for transliteration via dynamic linking. This is extended from [govarnam-rust](https://github.com/varnamproject/govarnam-rust).
- [x] Link the Rust interface and SampleIME CPP to build an IME build dll.
- [x] Windows Setup Wizard script via Inno Setup.
- [ ] Language Switching (Currently runs on just [Malayalam VST](https://github.com/varnamproject/schemes/tree/master/schemes/ml))
        - [ ] Implement the supported CONSTANTS for languages from [`windows_sys::Win32::System::SystemServices`](https://docs.rs/windows-sys/latest/windows_sys/Win32/System/SystemServices/index.html) and trigger language switch on Language Settings change.
- [ ] Keyboard Layout shifting (Active/Disable toggle)
- [ ] Resource files for icons (`*.ico`) for Registry Profile. (Currently the SampleIME 'Chinese Simplified' icon resources are loaded)
- [ ] 🔴Handle Govarnam `nil pointer dereference` and potential race conditions (due to early freeing?). An example stack trace:

```
panic: runtime error: invalid memory address or nil pointer dereference
[signal 0xc0000005 code=0x0 addr=0x48 pc=0x7ffe9289dcfb]

goroutine 19 [running]:
github.com/varnamproject/govarnam/govarnam.(*Varnam).tokenizeWord(0x0, {0x7ffe92a55f20, 0xc0000520a0}, {0xc00000a100, 0xc}, 0x0?, 0x0)
        libvarnam-windows/govarnam/govarnam/symbol.go:258 +0x15b
github.com/varnamproject/govarnam/govarnam.(*Varnam).channelTokenizeWord(0x0?, {0x7ffe92a55f20, 0xc0000520a0}, {0xc00000a100, 0xc}, 0x0?, 0x0?, 0x0?)
        libvarnam-windows/govarnam/govarnam/channel.go:24 +0xb6
created by github.com/varnamproject/govarnam/govarnam.(*Varnam).transliterate in goroutine 7
        libvarnam-windows/govarnam/govarnam/govarnam.go:281 +0x189
error: process didn't exit successfully: `target\debug\varnam_init.exe` (exit code: 0xc0000005, STATUS_ACCESS_VIOLATION)
```

---