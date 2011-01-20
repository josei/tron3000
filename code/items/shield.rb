Skill do
  def obstacle?(x=@x, y=@y); end
  
  def draw
    super
    draw_loop(@game.art.images.shell.first, @x, @y, -@frames*10, 1.0, 1.0)
  end
end