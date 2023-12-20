use std::fs::File;
use std::io::BufReader;
use serde::{Deserialize, Serialize};
use std::env;
use std::collections::HashSet;

#[derive(Deserialize, Serialize)]
struct LanguagesEnabledConfig {
    malayalam: bool,
    assamese: bool,
    marathi: bool,
    bengali: bool,
    nepali: bool,
    gujarati: bool,
    odia: bool,
    hindi: bool,
    punjabi: bool,
    kannada: bool,
    sanskrit: bool,
    tamil: bool,
    telugu: bool,
}

fn main() {
    let file = File::open("languages_enabled_config.json").unwrap();
    let reader = BufReader::new(file);
    
    let mut languages_enabled_config: LanguagesEnabledConfig = serde_json::from_reader(reader).unwrap();

    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Please provide a comma separated list of languages to enable");
        std::process::exit(1);
    }
    let languages_input = &args[1];

    let languages_to_enable: HashSet<&str> = languages_input.split(',').collect();

    if languages_to_enable.contains("malayalam") {
        println!("Enabling language: Malayalam");
        languages_enabled_config.malayalam = true;
    }
    if languages_to_enable.contains("assamese") {
        println!("Enabling language: Assamese");
        languages_enabled_config.assamese = true;
    }
    if languages_to_enable.contains("marathi") {
        println!("Enabling language: Marathi");
        languages_enabled_config.marathi = true;
    }
    if languages_to_enable.contains("bengali") {
        println!("Enabling language: Bengali");
        languages_enabled_config.bengali = true;
    }
    if languages_to_enable.contains("nepali") {
        println!("Enabling language: Nepali");
        languages_enabled_config.nepali = true;
    }
    if languages_to_enable.contains("gujarati") {
        println!("Enabling language: Gujarati");
        languages_enabled_config.gujarati = true;
    }
    if languages_to_enable.contains("odia") {
        println!("Enabling language: Odia");
        languages_enabled_config.odia = true;
    }
    if languages_to_enable.contains("hindi") {
        println!("Enabling language: Hindi");
        languages_enabled_config.hindi = true;
    }
    if languages_to_enable.contains("punjabi") {
        println!("Enabling language: Punjabi");
        languages_enabled_config.punjabi = true;
    }
    if languages_to_enable.contains("kannada") {
        println!("Enabling language: Kannada");
        languages_enabled_config.kannada = true;
    }
    if languages_to_enable.contains("sanskrit") {
        println!("Enabling language: Sanskrit");
        languages_enabled_config.sanskrit = true;
    }
    if languages_to_enable.contains("tamil") {
        println!("Enabling language: Tamil");
        languages_enabled_config.tamil = true;
    }
    if languages_to_enable.contains("telugu") {
        println!("Enabling language: Telugu");
        languages_enabled_config.telugu = true;
    }

    let pretty_json = serde_json::to_string_pretty(&languages_enabled_config).unwrap();
    std::fs::write("languages_enabled_config.json", pretty_json).unwrap();
}
