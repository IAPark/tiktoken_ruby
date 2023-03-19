use std::collections::HashSet;

use crate::uncicode_error;


#[magnus::wrap(class = "Tiktoken::Ext::CoreBPE")]
pub struct CoreBPEWrapper {
    core_bpe: tiktoken_rs::CoreBPE,
}

impl CoreBPEWrapper {
    pub fn new(core_bpe: tiktoken_rs::CoreBPE) -> Self {
        Self { core_bpe }
    }

    pub fn encode_ordinary(&self, text: String) -> Vec<usize> {
        self.core_bpe.encode_ordinary(text.as_str())
    }

    pub fn encode(&self, text: String, allowed_special: magnus::RArray) -> Result<Vec<usize>, magnus::Error> {
        let allowed_special: Vec<String> = allowed_special.to_vec()?;
        let allowed_special: Vec<&str> = allowed_special.iter().map(|s| s.as_str()).collect();
        let allowed_special: HashSet<&str> = HashSet::from_iter(allowed_special.iter().cloned());

        Ok(self.core_bpe.encode(text.as_str(), allowed_special))
    }

    pub fn encode_with_special_tokens(&self, text: String) -> Vec<usize> {
        self.core_bpe.encode_with_special_tokens(text.as_str())
    }

    pub fn decode(&self, ids: Vec<usize>) -> Result<String, magnus::Error> {
        self.core_bpe.decode(ids)
            .map_err(|e| {
                let error = match uncicode_error() {
                    Ok(error) => error,
                    Err(e) => return e
                };
                
                magnus::Error::new(error, e.to_string())
        })

    }
}
