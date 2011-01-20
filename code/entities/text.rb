class Text < Entity
  image      :nothing
  text        ""
  factor    { @game.width / 300 }
  to_factor { @factor / 2 }
  timeout     500
  df        { interpolate(@factor, @to_factor, @timeout) }
  dc        { interpolate(@color.alpha, 0.0, @timeout) }
  color     { Gosu::Color.new(255, 128,128,255) }
  alpha       192

  def draw
    @game.font.draw_rel("#{@text}", @x,@y,0, 0.5,0.5, @factor,@factor, @color)
  end
  
  def update
    @factor += @df
    @alpha += @dc
    @color = Color.new(@alpha.to_i,@color.red, @color.green, @color.blue)
    destroy if @alpha + @dc < 0
  end
end