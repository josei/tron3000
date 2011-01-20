Action do
  def pick_action
    super
    @game.arena.paint_all(@color)
    Glow.new  :x=>@game.width/2, :y=>@game.height/2, :factor=>20.0*@game.height/600, :speed=>10, :color=>@color
  end
end