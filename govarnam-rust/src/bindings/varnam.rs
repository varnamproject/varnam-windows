use super::v_array::varray_t;
use std::ffi::{c_char, c_int};

#[link(name = "govarnam")]
extern "C" {
    pub fn varnam_get_version() -> *const c_char;
    pub fn varnam_get_build() -> *const c_char;
    pub fn varnam_get_last_error(varnamHandleID: c_int) -> *const c_char;
    pub fn varnam_close(varnamHandleID: c_int);
    pub fn varnam_init(
        vstFile: *const c_char,
        learningsFile: *const c_char,
        id: *const c_int,
    ) -> *const c_int;
    pub fn varnam_transliterate(
        varnamHandleID: c_int,
        id: c_int,
        word: *const c_char,
        resultPointer: *mut *mut varray_t,
    ) -> *const c_int;
}
