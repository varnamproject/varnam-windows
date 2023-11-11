fn main() {
    println!("Starting build script");

    if cfg!(target_os = "windows") {
        // The compiled `libgovarnam.dll` installs to `C:\lib` when building with `windows-build.bat`
        println!("cargo:rustc-link-search=native=C:\\lib");
    } else {
        println!("cargo:rustc-link-search=native=./lib");
    }

    println!("cargo:rustc-link-lib=dylib=govarnam");
}
