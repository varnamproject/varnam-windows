use govarnam::Varnam;
use std::{env, fs, path::Path};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        println!("Usage: vlf_import <schemes_directory_path>");
        std::process::exit(1);
    }

    let directory_path = &args[1];
    let vlf_directory = Path::new(directory_path).join("vlf");

    let vlf_files = fs::read_dir(vlf_directory)
        .unwrap_or_else(|err| panic!("Failed to read directory: {:?}", err))
        .filter_map(|entry| {
            let path = entry.unwrap().path();
            if path.extension().and_then(|s| s.to_str()) == Some("vlf") {
                let absolute_path = path.canonicalize().unwrap();
                println!("Importing: {:?}", absolute_path.to_str().unwrap());
                Some(absolute_path)
            } else {
                None
            }
        });

    for vlf_file in vlf_files {
        // let scheme_id = vlf_file.file_stem()
        //     .unwrap()
        //     .to_str()
        //     .unwrap()
        //     .to_string();

        let scheme_id = "ml";

        let varnam = Varnam::init_from_id(scheme_id)
            .unwrap_or_else(|err| panic!("Failed to initialize varnam: {:?}", err));

        varnam.import(vlf_file.to_str().unwrap())
            .unwrap_or_else(|err| panic!("Failed to import file: {:?}", err));

        println!("Imported: {}", scheme_id);
    }
}
