module Attacking
  def self.included klass
    klass.class_eval do
      frames        0
      attack_radius 20
    end
  end
  
  def update
    super
    @frames += 1
  end
  
  def advance(distance)
    super do
      yield || (destroyed = false
        @game.motorbikes.each {|m| (destroyed=true) and attack(m) if (distance(m.x,m.y) < attack_radius*factor and @frames>10 and can_attack?(m))}
        destroyed)
    end
  end

  def can_attack? m
    true
  end

  def attack m
    m.kill_by @owner
  end
end