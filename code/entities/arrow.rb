class Arrow < Entity
  player            nil
  state             :appear
  factor            0.0
  frames            0
  erase             false
  eraser_resource { @game.art.images[:eraser] }
  
  def draw
    super
    if @erase
      draw_loop(@eraser_resource.first, @x,@y,0,@factor/2,@factor/2,default_color)
    end
  end
  
  def update
    super

    @frames += 1

    dist = -(Math::sin(@frames/100.0*2*Math::PI)*7).abs
    @x = @initial_x + offset_x(@angle, dist)
    @y = @initial_y + offset_y(@angle, dist)

    case @state
    when :appear
      @factor += interpolate(0.0, 1.0, 100)
      @factor = 1.0 and @state = :normal if @factor > 1.0
      @color = Color.new((255 * @factor).to_i, @color.red, @color.green, @color.blue)
    when :normal
      df = interpolate(1.0, 0.2, 1000)
      @factor += df
      Glow.new(:x=>@x,:y=>@y,:follow=>self,:factor=>0.5,:color=>@color) if @factor < 0.38 and @frames % 50==0
      spawn if @factor < 0.2
    when :destroying
      @factor -= 0.02
      destroy! if @factor < 0.1
      @color = Color.new((255 * @factor).to_i, @color.red, @color.green, @color.blue)
    end
  end
  
  def button_down(id)
    case id
    when :left
      @erase = !@erase
    when :right
      @erase = !@erase
    when :fire
      spawn if @state == :normal
    end
  end
  
  def button_up(id); end
 
  def destroy; @state = :destroying; end
  
  def spawn; @player.spawn; destroy; end
end
