require 'attributes'
require 'looper'

class Entity
  include Tron
  include Gosu
  include Attributes
  include Behaviours
  include Looper
  
  game            { Game::instance }
  entities        { @game.entities << self; @game.entities}
  x               { rand(@game.width) unless @x }
  y               { rand(@game.height) unless @y }
  angle             0
  frame             0
  draw_mode         :default
  factor            1.0
  color           { Color.new(255, 255,255,255) }
  silent            false
  sound           { self.class.to_s.underscore.to_sym unless @sound }
  image           { self.class.to_s.underscore.to_sym unless @image }
  image_resource  { @game.art.images[[@image].flatten.sort_by{rand}.first] }
  owner             nil
  
  def on_create
    sound = [@sound].flatten.sort_by{rand}.first
    play sound if !@silent and @game.art.audio.respond_to?(sound)
  end
  
  def update; end

  def draw; draw_loop; end
  
  def kill_by killer; destroy; end
  
  def destroy; destroy!; end
  
  def destroy!; @game.entities.delete(self); end
  
  def advance(distance)
    dx, dy = offset_x(@angle, 1), offset_y(@angle, 1)
    (1..distance.to_i).each do
      self.x += dx; self.y += dy
      next unless block_given?
      obstacle = yield
      destroy and break if obstacle == true
      kill_by(obstacle) and break if obstacle.is_a? Player
    end
  end
  
  # Indicate if there are obstacles in sight
  def obstacle?(x=@x, y=@y)
    c = @game.arena.getpixel(x, y)
    if c.alpha == 0
      false
    else
      @game.find_player_by_color(c)
    end
  end

  # Indicate if there are lines in sight
  def free?(x=@x, y=@y)
    c = @game.arena.getpixel(x, y)
    if c.alpha == 0
      false
    else
      @game.find_player_by_color(c)
    end
  end

  # Iterate on a line, e.g., to check for obstacles
  def line(angle=@angle,max=100,x=@x,y=@y)
    dx, dy = offset_x(angle,1), offset_y(angle,1)
    (0..max).each do |dist|
      x = (x+dx).normalize_x
      y = (y+dy).normalize_y
      return dist if yield(x,y)
    end
    return false
  end

  def interpolate(a, b, frames)
    (b - a).to_f / frames
  end
  
  # Plays a sound tied to an entity, so that its pan is adjusted according to
  # the entity's position
  def play sound
    pan = (@x-@game.width/2)/@game.width
    pan = -pan if @game.config.invert_speakers
    @game.art.audio[sound].play_pan(pan)
  end
end