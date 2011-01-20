class Explosion < Entity
  draw_mode       :additive
  image           [:explosion1, :explosion2, :explosion3]
  glow          { Glow.new :x=>@x, :y=>@y, :angle=>@angle, :factor => @factor*2, :speed => 3 }
  ring            false
  ring_resource { @game.art.images.explosion_ring }
  corona        { Corona.new :x=>@x, :y=>@y, :angle=>@angle, :factor => @factor, :speed => 3, :grow => 0.01 if @ring }
  
  def on_create
    super
    @game.arena.clear(@x, @y, 40*@factor)
  end
  
  def draw
    super
    draw_loop(@ring_resource[@frame]) if @ring
  end
  
  def update
    self.frame += 1
    destroy if @frame == 0
    @game.motorbikes.each {|m| m.kill_by(@owner) if distance(m.x, m.y)<80*@factor}
  end
end
