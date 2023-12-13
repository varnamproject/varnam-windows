use once_cell::sync::Lazy;

use govarnam::Varnam;

static VARNAM: Lazy<Varnam> = Lazy::new(|| {
    let scheme_path = "C:\\Users\\doxop\\.libvarnam\\schemes\\ml\\ml.vst";
    let learning_path = "C:\\Users\\doxop\\.libvarnam\\schemes\\learnings\\ml.vst.learnings";

    match Varnam::init(
        scheme_path,
        learning_path
    ) {
        Ok(varnam) => varnam,
        Err(e) => {
            let msg = format!("Cannot initialize varnam: {:?}", e);
            panic!("{}", msg);
        }
    }
});

fn main() {
    // for _ in 0..50 {
        let mut matches: Vec<(String, String)> = Vec::with_capacity(20);

        let results = VARNAM.transliterate("namaskkaaram");

        // for item in results {
        //     println!(
        //         "Word: {}, Weight: {}, Learned on: {}",
        //         item.to_string(),
        //         item.weight,
        //         item.learned_on,
        //     );
        // }

        for result in results {
            matches.push(("input".into(), result.to_string()))
        }

        eprintln!("{:?}", matches);
    // }
}