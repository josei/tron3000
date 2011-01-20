module Spinning
  def self.included klass
    klass.class_eval do
      draw_angle    0
      spin_speed    10
    end
  end

  def draw
    last_angle = @angle; @angle = @draw_angle
    super
    @angle = last_angle
  end
  
  def update
    @draw_angle -= spin_speed
    super
  end
end