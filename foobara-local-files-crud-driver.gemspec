require_relative "version"

Gem::Specification.new do |spec|
  spec.name = "foobara-local-files-crud-driver"
  spec.version = Foobara::LocalFilesCrudDriverVersion::VERSION
  spec.authors = ["Miles Georgi"]
  spec.email = ["azimux@gmail.com"]

  spec.summary = "Stores all record data in a yaml file in a local directory"
  spec.homepage = "https://github.com/foobara/local-files-crud-driver"
  spec.license = "MPL-2.0"
  spec.required_ruby_version = Foobara::LocalFilesCrudDriverVersion::MINIMUM_RUBY_VERSION

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/**/*",
    "src/**/*",
    "LICENSE*.txt",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.add_dependency "foobara", ">= 0.1.1", "< 2.0.0"

  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
