Weapon :ammo=>1 do
  def fire
    Match.new :x=>@x, :y=>@y, :angle=>@angle, :owner=>@player
    Glow.new :x=>@x, :y=>@y, :angle=>@angle, :follow=>self, :factor => 0.5
  end
end

class Match < Entity
  spinning
  projectile
  
  speed         10
  draw_mode     :additive
  sound         :missile
  
  def destroy
    Fire.new :x=>@x, :y=>@y, :owner => @owner
    Glow.new :x=>@x, :y=>@y, :factor => 0.5
    super
  end
end

class Fire < Entity
  draw_mode :additive
  image     :explosion1
  angle     { rand(360) }
  factor    0.2
  particles []

  FireParticle = Struct.new(:x,:y,:frame)
  
  def on_create
    super
    burn @x, @y
  end
  
  def draw
    @particles.each { |p| @image_resource[p.frame].draw_rot(p.x,p.y,0, 0, 0.5,0.5, @factor,@factor, @color, :additive) }
  end
  
  def update
    @game.art.audio.fire.loop

    @particles.each do |p|
      p.frame += 3
      @game.motorbikes.each {|m| m.kill_by(@owner) if distance(m.x, m.y, p.x, p.y)<8}

      if p.frame == 9
        # Spread around
        [[p.x-6, p.y-6],               [p.x, p.y-8],               [p.x+6, p.y-6],
                                       [p.x, p.y-1],
         [p.x-8, p.y],   [p.x-1, p.y],               [p.x+1, p.y], [p.x+8, p.y],
                                       [p.x, p.y+1],
         [p.x-6, p.y+6],               [p.x, p.y+8],               [p.x+6, p.y+6]].each do |px, py|
          burn px, py if @game.arena.getpixel(px, py).alpha != 0
        end
        @particles.delete(p)
      end
    end
    
    destroy if @particles.size == 0
  end
  
  def destroy
    @game.art.audio.fire.stop
    super
  end
  
  private
  def burn x, y
    @particles << FireParticle.new(x % @game.width, y % @game.height, 3)
    @game.arena.putpixel(x, y)
  end
end