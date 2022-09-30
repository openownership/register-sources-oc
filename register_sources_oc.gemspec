# frozen_string_literal: true

require_relative "lib/register_sources_oc/version"

Gem::Specification.new do |spec|
  spec.name = "register_sources_oc"
  spec.version = RegisterSourcesOc::VERSION
  spec.authors = ["Josh Williams"]
  spec.email = ["josh@spacesnottabs.com"]

  spec.summary = "Library for storing and retrieving Open Corporates data."
  spec.description = spec.summary
  spec.homepage = "https://github.com/openownership/register-sources-oc"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["source_code_uri"] = "https://github.com/openownership/register-sources-oc"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'dotenv'

  spec.add_dependency 'dry-types', '>= 1', '< 2'
  spec.add_dependency 'dry-struct', '>= 1', '< 2'

  spec.add_dependency 'elasticsearch', '>= 7.10', '< 8'

  spec.add_dependency 'activesupport', '>= 6', '< 8'
  spec.add_dependency 'countries', '>= 4', '< 5'
  spec.add_dependency 'iso8601'
  spec.add_dependency 'rexml'

  spec.add_dependency 'faraday', '>= 1', '< 2'
  spec.add_dependency 'faraday_middleware', '>= 1', '< 2'
  spec.add_dependency 'net-http-persistent'
end
