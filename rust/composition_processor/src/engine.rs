use dictionary_parser::TableDictionaryEngine;
use itf_components::compartment::Compartment;

use crate::test_virtual_key::{
    test_virtual_key, CandidateMode, KeystrokeCategory, KeystrokeFunction,
};
use windows::{
    core::{AsImpl, GUID},
    Win32::{
        Foundation::{HMODULE, MAX_PATH},
        System::LibraryLoader::GetModuleFileNameW,
        UI::{
            Input::KeyboardAndMouse::VK_SHIFT,
            TextServices::{ITfThreadMgr, TF_LBI_STATUS_DISABLED, TF_LBI_STATUS_HIDDEN},
        },
        // System::SystemServices::{
        //     LANG_MALAYALAM,
        //     LANG_ASSAMESE,
        //     LANG_MARATHI,
        //     LANG_BENGALI,
        //     LANG_NEPALI,
        //     LANG_GUJARATI,
        //     LANG_ODIA,
        //     LANG_HINDI,
        //     LANG_PUNJABI,
        //     LANG_KANNADA,
        //     LANG_SANSKRIT,
        //     LANG_TAMIL,
        //     LANG_TELUGU,
        // },
    },
};

pub mod keystroke_buffer;
use keystroke_buffer::KeystrokeBuffer;

mod modifiers;
use modifiers::Modifiers;

mod punctuations;
use punctuations::PunctuationMapper;

mod preserved_keys;
use preserved_keys::PreservedKeys;

pub mod compartment_update_listener;
use compartment_update_listener::CompartmentUpdateListener;

mod language_bar;
use language_bar::LanguageBar;

use once_cell::sync::Lazy;

use govarnam::Varnam;

static VARNAM: Lazy<Varnam> = Lazy::new(|| {
    let dll_instance_handle = unsafe { ime::dll::DLL_INSTANCE };

    let file_name = unsafe {
        let mut file_name = [0u16; MAX_PATH as usize];
        GetModuleFileNameW(dll_instance_handle, &mut file_name);
        String::from_utf16(&file_name).unwrap()
    };

    let dir = std::path::Path::new(&file_name[..]).parent().unwrap();

    // let (scheme_path, learning_path) = match active_langid as u32 {
    //     LANG_MALAYALAM => (dir.join("schemes/ml/ml.vst"), dir.join("schemes/learnings/ml.vst.learnings")), // Malayalam
    //     LANG_ASSAMESE => (dir.join("schemes/as/as.vst"), dir.join("schemes/learnings/as.vst.learnings")), // Assamese
    //     LANG_MARATHI => (dir.join("schemes/mr/mr.vst"), dir.join("schemes/learnings/mr.vst.learnings")), // Marathi
    //     LANG_BENGALI => (dir.join("schemes/bn/bn.vst"), dir.join("schemes/learnings/bn.vst.learnings")), // Bengali
    //     LANG_NEPALI => (dir.join("schemes/ne/ne.vst"), dir.join("schemes/learnings/ne.vst.learnings")), // Nepali
    //     LANG_GUJARATI => (dir.join("schemes/gu/gu.vst"), dir.join("schemes/learnings/gu.vst.learnings")), // Gujarati
    //     LANG_ODIA => (dir.join("schemes/or/or.vst"), dir.join("schemes/learnings/or.vst.learnings")), // Odia
    //     LANG_HINDI => (dir.join("schemes/hi/hi.vst"), dir.join("schemes/learnings/hi.vst.learnings")), // Hindi
    //     LANG_PUNJABI => (dir.join("schemes/pa/pa.vst"), dir.join("schemes/learnings/pa.vst.learnings")), // Punjabi
    //     LANG_KANNADA => (dir.join("schemes/kn/kn.vst"), dir.join("schemes/learnings/kn.vst.learnings")), // Kannada
    //     LANG_SANSKRIT => (dir.join("schemes/sa/sa.vst"), dir.join("schemes/learnings/sa.vst.learnings")), // Sanskrit
    //     LANG_TAMIL => (dir.join("schemes/ta/ta.vst"), dir.join("schemes/learnings/ta.vst.learnings")), // Tamil
    //     LANG_TELUGU => (dir.join("schemes/te/te.vst"), dir.join("schemes/learnings/te.vst.learnings")), // Telugu
    //     _ => panic!("Unsupported language ID: {}", active_langid), // Panic for unsupported languages
    // };

    let scheme_path =  dir.join("schemes/ml/ml.vst");
    let learning_path = dir.join("schemes/learnings/ml.vst.learnings");

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

pub struct CompositionProcessorEngine {
    keystroke_buffer: KeystrokeBuffer,
    table_dictionary_engine: Option<TableDictionaryEngine>,
    modifiers: Modifiers,
    punctuation_mapper: PunctuationMapper,
    preserved_keys: PreservedKeys,
    compartment_wrapper: CompartmentUpdateListener,
    language_bar: LanguageBar,
}

impl CompositionProcessorEngine {
    pub fn new(thread_mgr: ITfThreadMgr, tf_client_id: u32) -> CompositionProcessorEngine {
        CompositionProcessorEngine {
            keystroke_buffer: KeystrokeBuffer::default(),
            table_dictionary_engine: None,
            modifiers: Modifiers::default(),
            punctuation_mapper: PunctuationMapper::default(),
            preserved_keys: PreservedKeys::default(),
            compartment_wrapper: CompartmentUpdateListener::new(thread_mgr, tf_client_id),
            language_bar: LanguageBar::new(),
        }
    }

    pub unsafe fn from_void(engine: *mut std::ffi::c_void) -> Box<CompositionProcessorEngine> {
        Box::from_raw(engine as *mut CompositionProcessorEngine)
    }

    pub fn setup_language_profile(&mut self, thread_mgr: ITfThreadMgr, client_id: u32) -> bool {
        if client_id == 0 {
            return false;
        }

        self.preserved_keys()
            .init_keys(thread_mgr.clone(), client_id)
            .ok();
        self.compartment_wrapper
            .init(thread_mgr.clone(), client_id)
            .ok();
        self.language_bar
            .init(thread_mgr, client_id, &self.compartment_wrapper)
            .ok();
        unsafe { ime::font::set_default_candidate_text_font() };

        true
    }

    pub fn test_virtual_key(
        &self,
        code: u16,
        ch: char,
        composing: bool,
        candidate_mode: CandidateMode,
    ) -> (bool, KeystrokeCategory, KeystrokeFunction) {
        test_virtual_key(self, code, ch, composing, candidate_mode)
    }

    pub fn get_candidate_list(
        &self,
        _is_incremental_word_search: bool,
        _is_wildcard_search: bool,
    ) -> Vec<(String, String)> {
        let mut matches: Vec<(String, String)> = Vec::with_capacity(20);
        let keystroke_buffer = self.keystroke_buffer.get_reading_string();

        let results = VARNAM.transliterate(keystroke_buffer.to_owned());

        // let results: Vec<&str> = Vec::from(["stuff", "stuff", "stuff", "stuff"]);

        // let current_language = self.language_bar.get_active_langid();

        // if let Ok(lang_id) = current_language {
        //     use std::io::prelude::*;
            
        //     let mut file = std::fs::OpenOptions::new()
        //         .write(true)
        //         .append(true)
        //         .open("C:\\Users\\doxop\\Documents\\debug.txt")
        //         .unwrap();

        //     if let Err(e) = writeln!(file, "Language ID: {}", lang_id) {
        //         eprintln!("Couldn't write to file: {}", e);
        //         let mut error_file = std::fs::OpenOptions::new()
        //             .write(true)
        //             .append(true)
        //             .open("C:\\Users\\doxop\\Documents\\debug.txt")
        //             .unwrap();
        //         if let Err(e) = writeln!(error_file, "Error: {}", e) {
        //             eprintln!("Couldn't write error to file: {}", e);
        //         }
        //     }
        // } else {
        //     use std::io::prelude::*;
            
        //     let mut file = std::fs::OpenOptions::new()
        //         .write(true)
        //         .append(true)
        //         .open("C:\\Users\\doxop\\Documents\\debug.txt")
        //         .unwrap();

        //     if let Err(e) = writeln!(file, "Error: Failed to get active language ID") {
        //         eprintln!("Couldn't write error to file: {}", e);
        //     }
        // }

        for result in results {
            matches.push((keystroke_buffer.clone(), result.to_string()))
        }

        matches
    }

    pub fn get_candidate_string_in_converted(&self, search: &str) -> Vec<(String, String)> {
        if let Some(ref table_dictionary_engine) = self.table_dictionary_engine {
            // Search phrase from SECTION_TEXT's converted string list
            let wildcard_search = search.to_owned() + "*";

            table_dictionary_engine
                .collect_word_from_converted_string_for_wildcard(&wildcard_search)
        } else {
            Vec::new()
        }
    }

    pub fn on_preserved_key(
        &self,
        guid: &GUID,
        thread_mgr: ITfThreadMgr,
        client_id: u32,
    ) -> windows::core::Result<bool> {
        let matching = self
            .preserved_keys
            .keys
            .iter()
            .find(|&preserved| preserved.key_guid == *guid);
        if matching.is_none() {
            return Ok(false);
        }

        let preserved = matching.unwrap();

        if preserved.key.uVKey == VK_SHIFT.0 as u32 && !self.modifiers.is_shift_key_down_only() {
            return Ok(false);
        }

        let compartment = Compartment::new(thread_mgr, client_id, preserved.compartment_guid);
        let state = compartment.get_bool()?;
        compartment.set_bool(!state)?;

        Ok(true)
    }

    fn _setup_dictionary_file(&mut self, dll_instance_handle: HMODULE, dictionary_file_name: &str) {
        let file_name = unsafe {
            let mut file_name = [0u16; MAX_PATH as usize];
            GetModuleFileNameW(dll_instance_handle, &mut file_name);
            String::from_utf16(&file_name).unwrap()
        };

        let dir = std::path::Path::new(&file_name[..]).parent().unwrap();
        let dict_path = dir.join(dictionary_file_name);

        self.table_dictionary_engine =
            Some(TableDictionaryEngine::load(dict_path.to_str().unwrap()).unwrap())
    }

    fn set_language_bar_status(&self, status: u32, set: bool) -> windows::core::Result<()> {
        self.language_bar.button().as_impl().set_status(status, set)
    }

    pub fn hide_language_bar_button(&self, hide: bool) -> windows::core::Result<()> {
        self.set_language_bar_status(TF_LBI_STATUS_HIDDEN, hide)
    }

    pub fn disable_language_bar_button(&self, disable: bool) -> windows::core::Result<()> {
        self.set_language_bar_status(TF_LBI_STATUS_DISABLED, disable)
    }

    pub fn get_table_dictionary_engine(&self) -> &Option<TableDictionaryEngine> {
        &self.table_dictionary_engine
    }

    pub fn modifiers(&self) -> &Modifiers {
        &self.modifiers
    }

    pub fn modifiers_mut(&mut self) -> &mut Modifiers {
        &mut self.modifiers
    }

    pub fn punctuation_mapper(&self) -> &PunctuationMapper {
        &self.punctuation_mapper
    }

    pub fn punctuation_mapper_mut(&mut self) -> &mut PunctuationMapper {
        &mut self.punctuation_mapper
    }

    pub fn preserved_keys(&self) -> &PreservedKeys {
        &self.preserved_keys
    }

    pub fn keystroke_buffer(&self) -> &KeystrokeBuffer {
        &self.keystroke_buffer
    }

    pub fn keystroke_buffer_mut(&mut self) -> &mut KeystrokeBuffer {
        &mut self.keystroke_buffer
    }

    pub fn compartment_wrapper(&self) -> &CompartmentUpdateListener {
        &self.compartment_wrapper
    }
}
