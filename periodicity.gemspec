# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{periodicity}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kostas Karachalios"]
  s.date = %q{2009-08-06}
  s.description = %q{Helps calculate the next run for schedulers using a human readable syntax.}
  s.email = ["kostas.karachalios@me.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "lib/periodicity.rb", "lib/periodicity/period.rb", "script/console", "script/destroy", "script/generate", "spec/periodicity_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.homepage = %q{http://github.com/vrinek/periodicity}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{periodicity}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Helps calculate the next run for schedulers using a human readable syntax.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.2"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.2"])
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.2"])
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
