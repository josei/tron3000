Weapon :ammo=>1 do
  def fire
    BigMissile.new :x=>@x, :y=>@y, :angle=>@angle, :owner=>@player
  end
end

class BigMissile < Entity
  image     :missile
  sound     :missile
  speed     10
  follow    nil
  flare   { Flare.new :follow=>self }
  corona  { Corona.new :follow=>self, :speed=>0, :factor=>0.75 }
  glow    { Glow.new :x=>@x, :y=>@y, :follow=>@owner.entity }

  def update
    advance(@speed) { obstacle? }
    @speed += 1 if @speed < 20
  end
  
  def destroy
    Explosion.new :x=>@x, :y=>@y, :angle=>@angle, :owner => @owner, :factor => 3.0, :ring => true
    super
  end
end