use dirs;
use govarnam::Varnam;
use std::fs;
use std::path::Path;

fn main() {
    let home_dir = match dirs::home_dir() {
        Some(dir) => dir,
        None => {
            panic!("Could not find the home directory");
        }
    };

    let schemes_dir = format!("{}\\.libvarnam\\schemes", home_dir.to_str().unwrap());

    for entry in fs::read_dir(schemes_dir).unwrap() {
        let entry = entry.unwrap();
        let path = entry.path();
        if path.is_dir() {
            let scheme_path = path
                .join(path.file_name().unwrap())
                .with_extension("vst")
                .to_str()
                .unwrap()
                .to_string();
            
            let learning_path = format!(
                "{}\\.libvarnam\\schemes\\learnings\\{}.vst.learnings",
                home_dir.to_str().unwrap(),
                path.file_name().unwrap().to_str().unwrap()
            );

            if !Path::new(&scheme_path).exists() {
                continue;
            }

            println!("Scheme path: {:?}", scheme_path);
            println!("Learning path: {:?}", learning_path);
            println!(
                "Scheme path created: {:?}",
                Path::new(&scheme_path).exists()
            );
            println!(
                "Learning path created: {:?}",
                Path::new(&learning_path).exists()
            );

            let result =
                std::panic::catch_unwind(|| match Varnam::init(&scheme_path, &learning_path) {
                    Ok(_varnam) => {
                        println!("Language path created: {:?}", learning_path);
                    }
                    Err(e) => {
                        let msg = format!("Cannot initialize varnam: {:?}", e);
                        panic!("{}", msg);
                    }
                });
            if result.is_err() {
                println!("An error occurred while initializing varnam. Skipping this scheme.");
                continue;
            }
        }
    }
}
