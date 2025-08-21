# -*- encoding: utf-8 -*-
# stub: rb_sys 0.9.115 ruby lib

Gem::Specification.new do |s|
  s.name = "rb_sys".freeze
  s.version = "0.9.115"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://oxidize-rb.github.io/rb-sys/", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/oxidize-rb/rb-sys" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ian Ker-Seymer".freeze]
  s.bindir = "exe".freeze
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDZTCCAk2gAwIBAgIUBA3+R8/tEu+w03IWit3NPqhAv5EwDQYJKoZIhvcNAQEL\nBQAwQjEUMBIGA1UEAwwLaS5rZXJzZXltZXIxFTATBgoJkiaJk/IsZAEZFgVnbWFp\nbDETMBEGCgmSJomT8ixkARkWA2NvbTAeFw0yNTA1MDcxOTA3NDNaFw0zNTA1MDUx\nOTA3NDNaMEIxFDASBgNVBAMMC2kua2Vyc2V5bWVyMRUwEwYKCZImiZPyLGQBGRYF\nZ21haWwxEzARBgoJkiaJk/IsZAEZFgNjb20wggEiMA0GCSqGSIb3DQEBAQUAA4IB\nDwAwggEKAoIBAQDCdqRvnq+HDz2rMbDCCi/f7Ziy+IIfNBDLhd0gktKmaIfjqPHZ\nL0WMVvDV3cBCHKd3AjYBPuRviUwjDlRfEteZ9WdT+8cV4l8WvwSKHyim7WrVUZ4J\nteLkf+qY3ZLy16pa1nUue2zcL+y7ac2FXwx37Jf6kVmhIuI6tNDzQkUlo3L2vLXq\nrMIwYPCpcBrcsoKXsz21Ulj/GL81mZlRe36kQV1O/AIdPqTTobJQVw07yN8SXTeI\nUNx+6y46Q/6sSlqv/KPkL8enF3TWd7oB/z69wQLKreCRS14p/QCuzzvRgzB+SVya\n1G/oQLdlTSGaqc/VZSgOgQNIzXlhnmvsgmZBAgMBAAGjUzBRMB0GA1UdDgQWBBTp\nKxeobKHGiDDo0fytyQc8lwiyTzAfBgNVHSMEGDAWgBTpKxeobKHGiDDo0fytyQc8\nlwiyTzAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAhKxsiI5Xz\nH3isxJy4pD1FZ6rrU0gg/kFkWlsYgrw/Cqt53Nj6ValhpbA/VoftE80xEHfv4qR0\neiBkYVyULXZbojF9qRokVTXDY6lWzHdesbSt314IBBJR55aTw4IPHGikhMNeZ3M1\nffINONWhsL+ZwMaiLedThkRkPNzCvvRSNZiQXsdl/xV55JWqmmgfONCafx6/L8cI\nEZEISe0Z9uvVtO6G+mfX6nfGGVjJg6B53wSXaipDGxOh0vn1YiQzPxY+8ouXmfj6\nC/k2s4tlFwg7XEtz7wjSnVeiNP9EOK50WgVr4muWx1rhvOFhpxypONCCANJUILGk\n1JUZhXwcbcst\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2025-05-14"
  s.email = ["i.kerseymer@gmail.com".freeze]
  s.executables = ["rb-sys-dock".freeze]
  s.files = ["exe/rb-sys-dock".freeze]
  s.homepage = "https://oxidize-rb.github.io/rb-sys/".freeze
  s.licenses = ["MIT".freeze, "Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Helpers for compiling Rust extensions for ruby".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rake-compiler-dock>.freeze, ["= 1.9.1"])
end
