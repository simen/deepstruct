require 'rubygems'
require 'rake'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'deepstruct'
    gem.summary = gem.description = %Q{A sibling of ostruct that handles deeply nested structures and basic data type detection}
    gem.email = "simen@bengler.no"
    gem.homepage = "http://github.com/simen/deepstruct"
    gem.authors = ["Simen Svale Skogsrud"]
    gem.has_rdoc = true
    gem.require_paths = ["lib"]
    gem.files = FileList[%W(
      README.markdown
      VERSION
      LICENSE*
      lib/**/*
    )]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  $stderr << "Warning: Gem-building tasks are not included as Jeweler (or a dependency) not available. Install it with: `gem install jeweler`.\n"
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ruby-hdfs #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
