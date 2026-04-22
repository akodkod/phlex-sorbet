# frozen_string_literal: true

require_relative "lib/phlex/sorbet/version"

Gem::Specification.new do |spec|
  spec.name = "phlex-sorbet"
  spec.version = Phlex::Sorbet::VERSION
  spec.authors = ["Andrew Kodkod"]
  spec.email = ["andrew@kodkod.me"]

  spec.summary = "Typed Props for Phlex components"
  spec.description = "Define type-safe Props for your Phlex views and components using sorbet-schema"
  spec.homepage = "https://github.com/akodkod/phlex-sorbet"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["source_code_uri"] = "https://github.com/akodkod/phlex-sorbet"
  spec.metadata["changelog_uri"] = "https://github.com/akodkod/phlex-sorbet/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(["git", "ls-files", "-z"], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?("bin/", "Gemfile", ".gitignore", ".rspec", "spec/", ".github/", ".rubocop.yml")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "phlex", ">= 2.0"
  spec.add_dependency "sorbet-runtime", ">= 0.6"
  spec.add_dependency "sorbet-schema", ">= 0.9"
end
