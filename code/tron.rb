module Tron
  Root = File.expand_path("#{File.dirname(__FILE__)}/..")
  Resources = { :helpers => 'code/helpers',
                :core => 'code/core',
                :entities => 'code/entities',
                :items => 'code/items',
                :menus => 'code/menus',
                :components => 'code/components',
                :bots => 'code/bots',
                :graphics => 'art/graphics',
                :audio => 'art/audio',
                :extensions => 'extensions' }
  Classes = [:helpers, :core, :entities, :items, :components, :menus, :bots]
    
  def self.run
    load_code
    Game::instance.show
  end

  def self.load_code
    $: << path_for('lib')
    load_classes(Classes)
    extensions.each { |ext,path| load_classes([:items, :bots], path) }
  end
  
  def self.load_classes(res, prefix=extensions[:default])
    res = [res].flatten
    paths = res.map { |r| "#{prefix}/#{Resources[r]}" }
    paths.each { |path| $: << path; Dir["#{path}/*.rb"].sort.each { |f| require File.basename(f, ".rb") } }
  end
    
  def self.contents(res, prefix=extensions[:default])
    Dir["#{prefix}/#{Resources[res]}/*.rb"].map { |f| File.basename(f, '.rb').to_sym }
  end
  
  def self.extensions
    extensions = {:default => path_for('.')}
    Dir["#{path_for(Resources[:extensions])}/*"].each {|e| extensions[File.basename(e).to_sym] = e}
    extensions
  end
  
  def self.path_for(path)
    "#{Root}/#{path}"
  end
end