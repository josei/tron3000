require 'attributes'

class Item
  include Attributes
  
  nick            { File.basename(caller[7].split(':').first, '.rb').to_sym }
  image           { @nick }
  def sound; @sound.is_a?(Symbol) ? @sound : @sound.sort_by { rand }.first; end
  sound           { @nick }
  behaviour         nil
  image_resource    nil
  
  def initialize args={}, &block
    super args
    @behaviour = Module.new(&block)
    Kernel.const_set @nick.to_s.camelize, self
  end
end
