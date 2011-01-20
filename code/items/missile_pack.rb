Weapon :ammo => 3, :timeout => 40 do
  def fire
    HomingMissile.new :x=>@x, :y=>@y, :angle=>@angle, :owner=>@player, :follow => pick_victim
    Glow.new :x=>@x, :y=>@y, :follow=>self
  end
end

class HomingMissile < Entity
  homing
  explosive
  projectile

  image   :missile
  sound   :missile
  factor  0.75
  flare { Flare.new :follow=>self, :factor=>0.5 }

  def update
    @speed += 1 if @speed < 30
    super
  end
end
