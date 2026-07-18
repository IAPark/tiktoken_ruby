use std::collections::HashSet;
use std::ffi::c_void;

use tiktoken_rs::Rank;

use crate::unicode_error;

#[magnus::wrap(class = "Tiktoken::Ext::CoreBPE")]
pub struct CoreBPEWrapper {
    core_bpe: tiktoken_rs::CoreBPE,
}

struct EncodeOrdinaryData {
    core_bpe: *const tiktoken_rs::CoreBPE,
    text: String,
    result: Vec<Rank>,
}

struct EncodeData {
    core_bpe: *const tiktoken_rs::CoreBPE,
    text: String,
    allowed_special: HashSet<String>,
    result: Result<Vec<Rank>, String>,
}

struct EncodeSpecialData {
    core_bpe: *const tiktoken_rs::CoreBPE,
    text: String,
    result: Vec<Rank>,
}

struct DecodeData {
    core_bpe: *const tiktoken_rs::CoreBPE,
    ids: Vec<Rank>,
    result: Result<String, String>,
}

struct DecodeBytesData {
    core_bpe: *const tiktoken_rs::CoreBPE,
    ids: Vec<Rank>,
    result: Result<Vec<u8>, String>,
}

unsafe extern "C" fn encode_ordinary_without_gvl(data: *mut c_void) -> *mut c_void {
    let data = &mut *(data as *mut EncodeOrdinaryData);
    let core_bpe = &*data.core_bpe;
    data.result = core_bpe.encode_ordinary(&data.text);
    std::ptr::null_mut()
}

unsafe extern "C" fn encode_without_gvl(data: *mut c_void) -> *mut c_void {
    let data = &mut *(data as *mut EncodeData);
    let core_bpe = &*data.core_bpe;
    let allowed_special: HashSet<&str> = data.allowed_special.iter().map(|s| s.as_str()).collect();
    // Keep only the token vector and surface any tokenization failure to Ruby.
    data.result = core_bpe
        .encode(&data.text, &allowed_special)
        .map(|(tokens, _last_piece_token_len)| tokens)
        .map_err(|e| e.to_string());
    std::ptr::null_mut()
}

unsafe extern "C" fn encode_special_without_gvl(data: *mut c_void) -> *mut c_void {
    let data = &mut *(data as *mut EncodeSpecialData);
    let core_bpe = &*data.core_bpe;
    data.result = core_bpe.encode_with_special_tokens(&data.text);
    std::ptr::null_mut()
}

unsafe extern "C" fn decode_without_gvl(data: *mut c_void) -> *mut c_void {
    let data = &mut *(data as *mut DecodeData);
    let core_bpe = &*data.core_bpe;
    data.result = core_bpe.decode(&data.ids).map_err(|e| e.to_string());
    std::ptr::null_mut()
}

unsafe extern "C" fn decode_bytes_without_gvl(data: *mut c_void) -> *mut c_void {
    let data = &mut *(data as *mut DecodeBytesData);
    let core_bpe = &*data.core_bpe;
    data.result = core_bpe.decode_bytes(&data.ids).map_err(|e| e.to_string());
    std::ptr::null_mut()
}

impl CoreBPEWrapper {
    pub fn new(core_bpe: tiktoken_rs::CoreBPE) -> Self {
        Self { core_bpe }
    }

    pub fn encode_ordinary(&self, text: String) -> Vec<Rank> {
        let mut data = EncodeOrdinaryData {
            core_bpe: &self.core_bpe as *const _,
            text,
            result: Vec::new(),
        };

        unsafe {
            rb_sys::rb_thread_call_without_gvl(
                Some(encode_ordinary_without_gvl),
                &mut data as *mut _ as *mut c_void,
                None,
                std::ptr::null_mut(),
            );
        }

        data.result
    }

    pub fn encode(
        &self,
        text: String,
        allowed_special: magnus::RArray,
    ) -> Result<Vec<Rank>, magnus::Error> {
        let allowed_special: Vec<String> = allowed_special.to_vec()?;

        let mut data = EncodeData {
            core_bpe: &self.core_bpe as *const _,
            text,
            allowed_special: HashSet::from_iter(allowed_special),
            result: Ok(Vec::new()),
        };

        unsafe {
            rb_sys::rb_thread_call_without_gvl(
                Some(encode_without_gvl),
                &mut data as *mut _ as *mut c_void,
                None,
                std::ptr::null_mut(),
            );
        }

        data.result.map_err(|e| {
            magnus::Error::new(magnus::Ruby::get().unwrap().exception_runtime_error(), e)
        })
    }

    pub fn encode_with_special_tokens(&self, text: String) -> Vec<Rank> {
        let mut data = EncodeSpecialData {
            core_bpe: &self.core_bpe as *const _,
            text,
            result: Vec::new(),
        };

        unsafe {
            rb_sys::rb_thread_call_without_gvl(
                Some(encode_special_without_gvl),
                &mut data as *mut _ as *mut c_void,
                None,
                std::ptr::null_mut(),
            );
        }

        data.result
    }

    pub fn decode(&self, ids: Vec<Rank>) -> Result<String, magnus::Error> {
        let mut data = DecodeData {
            core_bpe: &self.core_bpe as *const _,
            ids,
            result: Err(String::new()),
        };

        unsafe {
            rb_sys::rb_thread_call_without_gvl(
                Some(decode_without_gvl),
                &mut data as *mut _ as *mut c_void,
                None,
                std::ptr::null_mut(),
            );
        }

        data.result.map_err(|e| {
            let error = match unicode_error() {
                Ok(error) => error,
                Err(e) => return e,
            };

            magnus::Error::new(error, e)
        })
    }

    pub fn decode_bytes(&self, ids: Vec<Rank>) -> Result<magnus::RString, magnus::Error> {
        let mut data = DecodeBytesData {
            core_bpe: &self.core_bpe as *const _,
            ids,
            result: Err(String::new()),
        };

        unsafe {
            rb_sys::rb_thread_call_without_gvl(
                Some(decode_bytes_without_gvl),
                &mut data as *mut _ as *mut c_void,
                None,
                std::ptr::null_mut(),
            );
        }

        // Build the Ruby string only after the GVL has been re-acquired.
        // `str_from_slice` yields an ASCII-8BIT (binary) string, so the bytes
        // are handed back verbatim without any UTF-8 validation. We hold the
        // GVL here (this is called from Ruby), so `Ruby::get` cannot fail.
        let ruby = magnus::Ruby::get().unwrap();
        data.result
            .map(|bytes| ruby.str_from_slice(&bytes))
            .map_err(|e| {
                let error = match unicode_error() {
                    Ok(error) => error,
                    Err(e) => return e,
                };

                magnus::Error::new(error, e)
            })
    }
}
