# frozen_string_literal: true

require_relative "lib/docxgen/version"

Gem::Specification.new do |spec|
  spec.name          = "docxgen"
  spec.version       = Docxgen::VERSION
  spec.authors       = ["Andrey Viktorov"]
  spec.email         = ["andv@outlook.com"]

  spec.summary       = "docxgen allows generating docx files based on templates with variables"
  spec.homepage      = "https://github.com/4ndv/docxgen"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/4ndv/docxgen"
  spec.metadata["changelog_uri"] = "https://github.com/4ndv/docxgen/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
