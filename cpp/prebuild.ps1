$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

Get-ChildItem -Path $scriptDir -Include *.dll, *.pdb, *.exp -Recurse | ForEach-Object {Remove-Item $_.FullName -Force -Confirm:$false}

Push-Location $scriptDir/../govarnam
.\windows-build.bat
gendef libgovarnam.dll
lib /def:libgovarnam.def /OUT:libgovarnam.lib /MACHINE:X64
Copy-Item "libgovarnam.dll" -Destination "$scriptDir\x64\Debug\libgovarnam.dll"
Copy-Item "libgovarnam.lib" -Destination "$scriptDir\x64\Debug\libgovarnam.lib"
Copy-Item -Path "schemes" -Destination "$scriptDir\x64\Debug" -Recurse
New-Item -ItemType Directory -Path "$scriptDir\x64\Debug\schemes\learnings"
Pop-Location

Push-Location $scriptDir/../rust
rustup target add x86_64-pc-windows-msvc
cargo build --release --target=x86_64-pc-windows-msvc
cbindgen --crate composition_processor --output ../cpp/SampleIME/cbindgen/composition_processor.h
cbindgen --crate input_processor --output ../cpp/SampleIME/cbindgen/input_processor.h
cbindgen --crate itf_components --output ../cpp/SampleIME/cbindgen/itf_components.h
cbindgen --crate globals --output ../cpp/SampleIME/cbindgen/globals.h
cbindgen --crate ime --output ../cpp/SampleIME/cbindgen/ime.h
cbindgen --crate numberkey_windows --output ../cpp/SampleIME/cbindgen/numberkey_windows.h
cbindgen --crate ruststringrange --output ../cpp/SampleIME/cbindgen/ruststringrange.h
cbindgen --crate govarnam --output ../cpp/SampleIME/cbindgen/govarnam.h
Pop-Location
