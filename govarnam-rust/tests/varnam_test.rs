use govarnam::Varnam;

#[test]
pub fn test_version() {
    let version = Varnam::get_version();
    assert_eq!(version, "1.9.0");
}

#[test]
pub fn test_build() {
    let build_version = Varnam::get_build();
    assert!(build_version.contains("1.9.0"));
}

#[test]
pub fn test_init() {
    let vst_file = "assets/ml/ml.vst";
    let learning_file = "assets/ml/learnings/ml.vst.learnings";
    let varnam = Varnam::init(vst_file, learning_file).unwrap();
    let result = varnam.transliterate("morning");
    assert_eq!(result.len(), 10);
}
