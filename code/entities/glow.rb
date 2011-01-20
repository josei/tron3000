require 'sticky'

class Glow < Entity
  sticky

  draw_mode :additive
  speed     20
  
  def update
    super
    @color = Color.new(@color.alpha - @speed, @color.red,@color.green,@color.blue)
    destroy if @color.alpha < @speed
  end
end