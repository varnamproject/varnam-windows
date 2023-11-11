#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use libc::size_t;
use std::ffi::{c_char, c_int, c_void, CStr};
use std::fmt::{Debug, Display};

#[link(name = "govarnam")]
// v_array imports
extern "C" {
    fn varray_init() -> *mut varray_t;
    fn varray_push(array: *const varray_t, data: *const c_void);
    fn varray_get(array: *const varray_t, index: c_int) -> *mut c_void;
    fn varray_length(array: *const varray_t) -> c_int;
    fn varray_is_empty(array: *const varray_t) -> bool;
    fn varray_clear(array: *const varray_t);
}

#[repr(C)]
#[derive(Copy, Clone, PartialEq)]
pub struct varray_t {
    memory: *mut *mut c_void,
    allocated: size_t,
    used: size_t,
    index: c_int,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct Suggestion_t {
    word: *mut c_char,
    pub weight: c_int,
    pub learned_on: c_int,
}

impl varray_t {
    pub fn len(&self) -> c_int {
        unsafe { varray_length(self) }
    }

    pub fn init() -> *mut varray_t {
        unsafe { varray_init() }
    }

    pub fn push(&self, data: *const c_void) {
        unsafe { varray_push(self, data) }
    }

    pub fn get(&self, index: c_int) -> *mut c_void {
        unsafe { varray_get(self, index) }
    }

    pub fn is_empty(&self) -> bool {
        unsafe { varray_is_empty(self) }
    }

    pub fn clear(&self) {
        unsafe { varray_clear(self) }
    }
}

impl Debug for varray_t {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mut formater = f.debug_list();

        for index in 0..self.len() {
            let item = self.get(index);
            let item = &(item as *const Suggestion_t);
            formater.entry(item);
        }

        formater.finish()
    }
}

impl From<varray_t> for Vec<Suggestion_t> {
    fn from(value: varray_t) -> Self {
        let mut result: Vec<Suggestion_t> = Vec::with_capacity(value.len() as usize);
        for index in 0..value.len() {
            let item = value.get(index);
            let item = unsafe { *(item as *const Suggestion_t) };
            result.push(item);
        }
        result
    }
}

impl Debug for Suggestion_t {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Suggetion_t")
            .field("word", &&self.extract_word())
            .field("weight", &self.weight)
            .field("learned_on", &self.learned_on)
            .finish()
    }
}
impl Display for Suggestion_t {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.extract_word())
    }
}

impl Suggestion_t {
    fn extract_word(&self) -> &str {
        let c_str = unsafe { CStr::from_ptr(self.word) };
        c_str.to_str().unwrap()
    }
}

impl Into<String> for Suggestion_t {
    fn into(self) -> String {
        self.extract_word().to_string()
    }
}

#[cfg(test)]
mod tests {
    use std::ffi::c_int;

    use super::varray_t;
    use libc::c_void;

    #[test]
    fn test_init() {
        let varray: varray_t = unsafe { *varray_t::init() };
        assert_eq!(varray.len(), 0);
        assert!(varray.is_empty());
    }

    #[test]
    fn test_insert_and_get() {
        let varray: varray_t = unsafe { *varray_t::init() };
        let pointer_to_data = c_int::from(12);
        varray.push(pointer_to_data as *const c_void);
        let data = varray.get(0);
        assert_eq!(varray.len(), 1);
        assert_eq!(pointer_to_data, data as i32);
    }

    #[test]
    fn test_clear() {
        let varray: varray_t = unsafe { *varray_t::init() };
        let pointer_to_data = c_int::from(12) as *const c_void;
        varray.push(pointer_to_data);
        varray.push(pointer_to_data);
        assert_eq!(varray.len(), 2);
        assert!(!varray.is_empty());
        varray.clear();
        assert!(varray.is_empty());
    }
}
