Weapon :ammo=>15 do  
  def fire
    Beam.new :x=>@x, :y=>@y, :angle=>@angle, :owner=>@player
    Glow.new :x=>@x, :y=>@y, :angle=>@angle, :follow=>self, :factor => 0.5
  end
end

class Beam < Entity
  projectile
  explosive
  
  speed     50
  draw_mode :additive
  explosion :beam_explosion
end

class BeamExplosion < Explosion
  image   [:beam_explosion1, :beam_explosion2]
  factor  0.4
  glow    nil
end
