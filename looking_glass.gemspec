Gem::Specification.new do |s|
  s.name          = 'looking_glass'
  s.version       = '0.0.1'
  s.platform      = Gem::Platform::RUBY
  s.licenses      = ['MIT']
  s.authors       = ['Burke Libbey']
  s.email         = ['burke.libbey@shopify.com']
  s.homepage      = 'https://github.com/Shopify/looking_glass'
  s.summary       = 'Mirror API for Ruby'
  s.description   = 'Provides a number of specs and classes that document a mirror API for Ruby.'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  s.add_development_dependency 'mspec',         '~> 1.9'
  s.add_runtime_dependency     'method_source', '~> 0.8'
end
