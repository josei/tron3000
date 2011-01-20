class Player
  include Attributes
  include Gosu
  
  game          { Game::instance }
  button_left     nil
  button_right    nil
  button_fire     nil
  entity          nil
  color           nil
  points          0
  account         nil

  def update; end

  def draw
    # Draw score
    @game.font.draw_rel("#{@points}", @score_x,@score_y,0, 0.5,0.5, 1.5,1.5, @color_semitrans)
    if @entity.is_a? Motorbike
      if @entity.weapon
        @entity.weapon.image_resource.first.draw_rot(@score_x+30,@score_y,0, 0, 0.5,0.5, 0.5,0.5, @color_semitrans)
        @game.font.draw_rel("#{@entity.weapon.ammo}", @score_x+55,@score_y,0, 0.5,0.5, 1.0,1.0, @color_semitrans)
      end
      if @entity.skill
        @entity.skill.image_resource.first.draw_rot(@score_x+80,@score_y,0, 0, 0.5,0.5, 0.5,0.5, @color_semitrans)
        @game.font.draw_rel("#{@entity.skill.timeout/50+1}", @score_x+105,@score_y,0, 0.5,0.5, 1.0,1.0, @color_semitrans)
      end
    end
  end

  def join
    # Change color a bit to make it unique :)
    n=0; colors=nil; begin
      colors = @game.players.map {|p| [p.color.red,p.color.green,p.color.blue]}
      @color = Color.from_hsv(@account.hue+n, 1.0, 1.0)
      colors << [@color.red, @color.green, @color.blue]
      n += 1
    end until colors.uniq.size == @game.players.size + 1
    @color_semitrans = Color.from_ahsv(150,@account.hue, 0.5, 1.0)

    # Set position
    margin,score_size = 60, 125
    @x,@y,@angle, @score_x,@score_y = [ [margin,margin,135, margin/3,margin/3],
                                        [@game.width-margin,@game.height-margin,315, @game.width-score_size-margin/3,@game.height-margin/3],
                                        [margin,@game.height-margin,45, margin/3,@game.height-margin/3],
                                        [@game.width-margin,margin,225, @game.width-score_size-margin/3, margin/3]
                                        ] [@game.players.size]
    
    @game.players << self
  end

  def start
    # Show name on screen
    Text.new :x=>@x+offset_x(@angle,@game.width/3), :y=>@y+offset_y(@angle,@game.height/4), :text=>@account.nick, :color=>@color
    
    @points = @initial_points
    
    # Put arrow
    home
  end

  def home
    @entity = Arrow.new(:x=>@x, :y=>@y, :angle=>@angle, :player=>self, :color=>@color)
  end

  def spawn
    if @game.players.size == @game.players.select{|p| p.entity.is_a?(Arrow) and p.entity.erase}.size
      @game.arena.clear_all
      @game.players.each {|p| p.entity.erase=false; p.entity.spawn if p != self}
    else
      @game.arena.clear(@x, @y, 40)
    end
    @entity = Motorbike.new(:x=>@x, :y=>@y, :angle=>@angle, :player=>self, :color=>@color)
  end
  
  def button_down(id)
    return unless @entity
    case id
    when @button_left; @entity.button_down(:left)
    when @button_right; @entity.button_down(:right)
    when @button_fire; @entity.button_down(:fire)
    end
  end

  def button_up(id)
    return unless @entity
    case id
    when @button_left; @entity.button_up(:left)
    when @button_right; @entity.button_up(:right)
    when @button_fire; @entity.button_up(:fire)
    end
  end
end
