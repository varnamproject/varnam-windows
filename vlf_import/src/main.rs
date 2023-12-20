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
        let scheme_id = if vlf_file.file_stem().unwrap().to_str().unwrap().contains("-") {
            vlf_file.file_stem().unwrap().to_str().unwrap().split("-").next().unwrap().to_string()
        } else {
            vlf_file.file_stem().unwrap().to_str().unwrap().to_string()
        };

        println!("Learning for scheme: {}", scheme_id);

        let scheme_path = format!("{}/vst/{}.vst", directory_path, scheme_id);
        let learning_path = format!("{}/learnings/{}.vst.learnings", directory_path, scheme_id);

        let varnam = match Varnam::init(
            scheme_path,
            learning_path
        ) {
            Ok(varnam) => varnam,
            Err(e) => {
                let msg = format!("Cannot initialize varnam: {:?}", e);
                panic!("{}", msg);
            }
        };

        varnam.import(vlf_file.to_str().unwrap())
            .unwrap_or_else(|err| panic!("Failed to import file: {:?}", err));
    }
}
