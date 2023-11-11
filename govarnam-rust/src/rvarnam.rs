use crate::bindings::v_array::{varray_t, Suggestion_t};

use super::bindings::varnam::*;
use std::io::Error;
use std::io::ErrorKind;
use std::{
    ffi::{c_int, CStr, CString},
    path::Path,
};

pub struct Varnam {
    handle_id: c_int,
}

impl Varnam {
    pub fn get_version() -> String {
        unsafe {
            let version = varnam_get_version();
            CStr::from_ptr(version).to_string_lossy().to_string()
        }
    }

    pub fn get_build() -> String {
        unsafe {
            let build_version = varnam_get_build();
            CStr::from_ptr(build_version).to_string_lossy().to_string()
        }
    }

    pub fn get_last_error(&self) -> String {
        unsafe {
            let error_string = varnam_get_last_error(self.handle_id);
            CStr::from_ptr(error_string).to_string_lossy().to_string()
        }
    }

    pub fn init<T: AsRef<Path>>(vst_file: T, learning_file: T) -> Result<Self, Error> {
        let id = 22;

        if !vst_file.as_ref().exists() {
            return Err(Error::new(
                ErrorKind::NotFound,
                "The path provided for the Vst file is invalid",
            ));
        }

        let vst_file = vst_file.as_ref().to_string_lossy().to_string();
        let learning_file = learning_file.as_ref().to_string_lossy().to_string();
        unsafe {
            let _init_id = varnam_init(
                vst_file.as_ptr() as *const i8,
                learning_file.as_ptr() as *const i8,
                &id,
            );
        };
        // TODO: check error use init_id
        Ok(Varnam { handle_id: id })
    }

    pub fn transliterate<T: AsRef<str>>(&self, word: T) -> Vec<Suggestion_t> {
        let id: c_int = 1;
        let word = CString::new(word.as_ref()).unwrap();
        let mut varray_ptr = varray_t::init();
        unsafe { varnam_transliterate(self.handle_id, id, word.as_ptr(), &mut varray_ptr) };
        let varray_pointer = unsafe { *varray_ptr as varray_t };
        varray_pointer.into()
    }
}

impl Drop for Varnam {
    fn drop(&mut self) {
        unsafe { varnam_close(self.handle_id) }
    }
}
