use magnus::{define_module, function, prelude::*, Error};

fn hello(subject: String) -> String {
    format!("Hello from Rust, {}!", subject)
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let module = define_module("Tiktoken")?;
    module.define_singleton_method("hello", function!(hello, 1))?;
    Ok(())
}
