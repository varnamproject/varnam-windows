fn main() {
    println!("Starting build script");

    let current_dir = std::env::current_dir().unwrap();
    let govarnam_dir = current_dir.parent().unwrap().join("govarnam-rust");

    if cfg!(target_os = "windows") {
        // The compiled `libgovarnam.dll` builds to `../cpp/x64/Debug` when building with `windows-build.bat`
        let lib_dir = govarnam_dir.join("../cpp/x64/Debug").display().to_string();
        println!("cargo:rustc-link-search=native={}", lib_dir);
    } else {
        println!("cargo:rustc-link-search=native=./lib");
    }

    println!("cargo:rustc-link-lib=dylib=govarnam");
}
