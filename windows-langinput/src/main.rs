use windows::Win32::UI::TextServices::{
    ITfInputProcessorProfileMgr, TF_INPUTPROCESSORPROFILE, GUID_TFCAT_TIP_KEYBOARD,
    CLSID_TF_InputProcessorProfiles
};

use windows::core::{Interface, Result, GUID};

use windows::Win32::System::Com::{CoCreateInstance, CoInitializeEx, CLSCTX_INPROC_SERVER, COINIT_APARTMENTTHREADED};

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

pub fn create_instance_inproc<T: Interface + windows::core::ComInterface>(
    clsid: &GUID,
) -> Result<T> {
    unsafe { CoCreateInstance(clsid, None, CLSCTX_INPROC_SERVER) }
}

pub fn get_active_langid() -> windows::core::Result<u16> {
    let profile_manager: ITfInputProcessorProfileMgr =
        create_instance_inproc(&CLSID_TF_InputProcessorProfiles)?;

    let mut profile: TF_INPUTPROCESSORPROFILE = Default::default();
    unsafe {
        profile_manager.GetActiveProfile(&GUID_TFCAT_TIP_KEYBOARD, &mut profile)?;
    }

    Ok(profile.langid)
}

fn main() {
    unsafe {
        CoInitializeEx(None, COINIT_APARTMENTTHREADED).expect("Failed to initialize COM");
    }

    let langid = get_active_langid().unwrap() as u32;
    println!("{} - {}", LANG_MALAYALAM, SUBLANG_MALAYALAM_INDIA);
    println!("{}", (SUBLANG_MALAYALAM_INDIA << 10 | LANG_MALAYALAM) as u16);
    println!("Active langid: {}", langid);
}
