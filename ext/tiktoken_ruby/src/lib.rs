mod core_bpe_wrapper;

use core_bpe_wrapper::CoreBPEWrapper;
use magnus::{define_module, function, prelude::*, Error, method, class, RModule, ExceptionClass};

fn r50k_base() -> CoreBPEWrapper {
    let core_bpe = tiktoken_rs::r50k_base().unwrap();
    CoreBPEWrapper::new(core_bpe)
}
fn p50k_base() -> CoreBPEWrapper {
    let core_bpe = tiktoken_rs::p50k_base().unwrap();
    CoreBPEWrapper::new(core_bpe)
}
fn p50k_edit() -> CoreBPEWrapper {
    let core_bpe = tiktoken_rs::p50k_edit().unwrap();
    CoreBPEWrapper::new(core_bpe)
}
fn cl100k_base() -> CoreBPEWrapper {
    let core_bpe = tiktoken_rs::cl100k_base().unwrap();
    CoreBPEWrapper::new(core_bpe)
}

fn module() -> Result<RModule, magnus::Error> {
    define_module("Tiktoken")
}

fn uncicode_error() -> Result<ExceptionClass, magnus::Error> {
    module()?.define_error("UnicodeError", magnus::exception::standard_error())
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let module = module()?;

    let factory_module = module.define_module("BpeFactory")?;
    factory_module.define_singleton_method("r50k_base", function!(r50k_base, 0))?;
    factory_module.define_singleton_method("p50k_base", function!(p50k_base, 0))?;
    factory_module.define_singleton_method("p50k_edit", function!(p50k_edit, 0))?;
    factory_module.define_singleton_method("cl100k_base", function!(cl100k_base, 0))?;


    let ext_module = module.define_module("Ext")?;
    let bpe_class = ext_module.define_class("CoreBPE", class::object())?;

    bpe_class.define_method("encode_ordinary", method!(CoreBPEWrapper::encode_ordinary, 1))?;
    bpe_class.define_method("encode", method!(CoreBPEWrapper::encode, 2))?;
    bpe_class.define_method("encode_with_special_tokens", method!(CoreBPEWrapper::encode_with_special_tokens, 1))?;


    bpe_class.define_method("decode", method!(CoreBPEWrapper::decode, 1))?;
    Ok(())
}
