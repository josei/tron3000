module Sticky
  def self.included klass
    klass.class_eval do
      follow    nil
    end
  end
  
  def on_create
    super
    stick
  end
  
  def update
    super
    stick
    destroy if @follow and !@game.entities.include?(@follow)
  end

  def stick; @x, @y, @angle = @follow.x, @follow.y, @follow.angle if @follow; end
end