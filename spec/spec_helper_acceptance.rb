require 'voxpopuli/acceptance/spec_helper_acceptance'
configure_beaker(modules: :fixtures)

Rspec.configure do
  pp <<-EOS

  EOS

  apply_manifest(pp, catch_failures: true)
end
