use windows::core::HRESULT;
use windows::Win32::Foundation::{E_FAIL, HMODULE, S_OK};

use crate::registry;

use windows::Win32::System::SystemServices::{
    LANG_MALAYALAM, SUBLANG_MALAYALAM_INDIA,
    LANG_ASSAMESE, SUBLANG_ASSAMESE_INDIA,
    LANG_MARATHI, SUBLANG_MARATHI_INDIA,
    LANG_BENGALI, SUBLANG_BENGALI_INDIA,
    LANG_NEPALI, SUBLANG_NEPALI_INDIA,
    LANG_GUJARATI, SUBLANG_GUJARATI_INDIA,
    LANG_ODIA, SUBLANG_ODIA_INDIA,
    LANG_HINDI, SUBLANG_HINDI_INDIA,
    LANG_PUNJABI, SUBLANG_PUNJABI_INDIA,
    LANG_KANNADA, SUBLANG_KANNADA_INDIA,
    LANG_SANSKRIT, SUBLANG_SANSKRIT_INDIA,
    LANG_TAMIL, SUBLANG_TAMIL_INDIA,
    LANG_TELUGU, SUBLANG_TELUGU_INDIA,
};

#[no_mangle]
pub static mut DLL_INSTANCE: HMODULE = HMODULE(0);

#[no_mangle]
#[allow(non_snake_case)]
#[doc(hidden)]
unsafe extern "system" fn DllRegisterServer() -> HRESULT {
    unsafe fn register() -> windows::core::Result<()> {
        let lang_ids = [
            (SUBLANG_MALAYALAM_INDIA << 10 | LANG_MALAYALAM) as u16,
            (SUBLANG_ASSAMESE_INDIA << 10 | LANG_ASSAMESE) as u16,
            (SUBLANG_MARATHI_INDIA << 10 | LANG_MARATHI) as u16,
            (SUBLANG_BENGALI_INDIA << 10 | LANG_BENGALI) as u16,
            (SUBLANG_NEPALI_INDIA << 10 | LANG_NEPALI) as u16,
            (SUBLANG_GUJARATI_INDIA << 10 | LANG_GUJARATI) as u16,
            (SUBLANG_ODIA_INDIA << 10 | LANG_ODIA) as u16,
            (SUBLANG_HINDI_INDIA << 10 | LANG_HINDI) as u16,
            (SUBLANG_PUNJABI_INDIA << 10 | LANG_PUNJABI) as u16,
            (SUBLANG_KANNADA_INDIA << 10 | LANG_KANNADA) as u16,
            (SUBLANG_SANSKRIT_INDIA << 10 | LANG_SANSKRIT) as u16,
            (SUBLANG_TAMIL_INDIA << 10 | LANG_TAMIL) as u16,
            (SUBLANG_TELUGU_INDIA << 10 | LANG_TELUGU) as u16,
        ];

        registry::register_server(DLL_INSTANCE)
            .map_err(|_| windows::core::Error::new(E_FAIL, "Failed to register server".into()))?;

        for lang_id in lang_ids.iter() {
            registry::register_profile(DLL_INSTANCE, *lang_id)?;
        }

        registry::register_categories()?;

        Ok(())
    }

    register()
        .map_err(|err| {
            DllUnregisterServer().ok().ok();
            err
        })
        .into()
}

#[no_mangle]
#[allow(non_snake_case)]
#[doc(hidden)]
unsafe extern "system" fn DllUnregisterServer() -> HRESULT {
    let lang_ids = [
        (SUBLANG_MALAYALAM_INDIA << 10 | LANG_MALAYALAM) as u16,
        (SUBLANG_ASSAMESE_INDIA << 10 | LANG_ASSAMESE) as u16,
        (SUBLANG_MARATHI_INDIA << 10 | LANG_MARATHI) as u16,
        (SUBLANG_BENGALI_INDIA << 10 | LANG_BENGALI) as u16,
        (SUBLANG_NEPALI_INDIA << 10 | LANG_NEPALI) as u16,
        (SUBLANG_GUJARATI_INDIA << 10 | LANG_GUJARATI) as u16,
        (SUBLANG_ODIA_INDIA << 10 | LANG_ODIA) as u16,
        (SUBLANG_HINDI_INDIA << 10 | LANG_HINDI) as u16,
        (SUBLANG_PUNJABI_INDIA << 10 | LANG_PUNJABI) as u16,
        (SUBLANG_KANNADA_INDIA << 10 | LANG_KANNADA) as u16,
        (SUBLANG_SANSKRIT_INDIA << 10 | LANG_SANSKRIT) as u16,
        (SUBLANG_TAMIL_INDIA << 10 | LANG_TAMIL) as u16,
        (SUBLANG_TELUGU_INDIA << 10 | LANG_TELUGU) as u16,
    ];

    for lang_id in lang_ids.iter() {
        registry::unregister_profile(*lang_id).ok();
    }

    registry::unregister_categories().ok();
    registry::unregister_server().ok();

    S_OK
}
