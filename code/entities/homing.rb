module Homing
  def self.included klass
    klass.class_eval do
      follow          nil
      homing_strategy :best
      homing_method   do case @homing_strategy
                        when :best;     method(:best_angle)
                        when :closest;  method(:closest_angle)
                        end
                      end
    end
  end
  
  def update
    super
    if follow
      diff = (@angle - @homing_method.call(follow.x, follow.y)).normalize_angle
      self.angle += 4 if diff < -4
      self.angle -= 4 if diff > 4
    end
  end
end