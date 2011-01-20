class ColorPicker < Component
  hue 0

  def click; end

  def update
    super
    @hue += 1 if @game.menu.button_right or @game.menu.button_enter
    @hue -= 1 if @game.menu.button_left
    @hue %= 360
  end
  
  def color
    Gosu::Color.from_ahsv(128,@hue, 1.0, 1.0)
  end
end