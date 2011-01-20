require 'sticky'

class Corona < Entity
  sticky

  draw_mode :additive
  speed     20
  grow      0.0
  
  def update
    super
    @color = Color.new(@color.alpha - @speed, @color.red,@color.green,@color.blue)
    @factor += @speed * @grow * @initial_factor
    destroy if @color.alpha < @speed
  end
end