class Bubble < Entity
  factor          0.0
  item            nil
  state          :appearing
  frames          0
  bubble          do
                    case @item
                    when Action; :blue_bubble
                    when Skill;  :red_bubble
                    when Weapon; :green_bubble
                    else :golden_bubble
                    end   
                  end
  bubble_resource { @bubble_resource = @game.art.images[@bubble] }
  image           { @item.image unless @image }
  silent          false

  def on_create
    super
    @item = @item.clone
  end

  def draw
    draw_loop(@bubble_resource.first) unless @state == :destroying
    super
  end
  
  def update
    @frames += 1
    case @state
    when :appearing
      @factor += interpolate(0.0, tremble, 10)
      @state = :normal if (@factor-tremble).abs < interpolate(0.0, tremble, 10)
    when :normal
      @factor = tremble
    when :destroying
      @factor += @df
      @alpha += @dc
      @color = Color.new(@alpha.to_i, @color.red, @color.green, @color.blue)
      destroy! if @alpha + @dc < 0
    end
  end
  
  def destroy
    return if @state == :destroying
    @state, @draw_mode = :destroying, :additive
    @alpha = @color.alpha
    @df, @dc = interpolate(@factor, 1.0, 20), interpolate(@alpha,0,20)
  end
  
  def self.count; ObjectSpace.each_object(self){}; end
  
  private
  def tremble; 0.5 + Math::sin(@frames/Math::PI)/16; end
end
