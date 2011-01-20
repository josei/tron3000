class Motorbike < Entity
  draw_mode     :additive
  player        nil
  button_right  false
  button_left   false
  button_fire   false
  angle_step    5
  speed         2
  weapon        nil
  skill         nil
  diagonal      true
  frames        0

  def update
    @frames += 1
    animate
    turn
    advance(speed) { check_diagonals; trail; obstacle? }
    manage_weapon
    manage_skill
    pick_items
  end
  
  def animate
    @factor = 0.5 + Math::sin(@game.frames/Math::PI)/8
  end
  
  def turn
    self.angle += angle_step if @button_right
    self.angle -= angle_step if @button_left
  end
  
  def check_diagonals
    return unless @diagonal
    new_x, new_y = @x+offset_x(@angle, 1), @y+offset_y(@angle, 1)
    unless (0..@game.width) === new_x and (0..@game.height) === new_y
      Text.new :x=>@game.width/2, :y=>@game.height/2, :text=>'Diagonal!', :color=>@color, :timeout=>200
      play :diagonal
      @player.points += 1
    end
  end
  
  def trail
    x, y = @x - offset_x(@angle, 4), @y - offset_y(@angle, 4)
    [[x-1, y-1], [x, y-1], [x+1, y-1],
     [x-1, y],   [x, y],   [x+1, y],
     [x-1, y+1], [x, y+1], [x+1, y+1]].each { |px, py| @game.arena.putpixel(px, py, color) }
  end
  
  def manage_weapon
    return unless @weapon

    @weapon.timeout -= 1
    if @weapon.timeout < 0 and @button_fire then
      fire
      @weapon.timeout = @weapon.initial_timeout
      @weapon.ammo -= 1
      lose_weapon if @weapon.ammo == 0
    end
  end

  def lose_weapon
    return unless @weapon
    unextend @weapon.behaviour
    @weapon = nil
  end

  # Should be overloaded by weapons
  def fire; end
  
  def manage_skill
    return unless @skill
    
    @skill.timeout -= 1
    lose_skill if @skill.timeout == 0
  end
  
  def lose_skill
    return unless @skill
    Glow.new :x=>@x, :y=>@y, :follow=>self, :color=>@color
    unextend @skill.behaviour
    @skill = nil
  end
  
  def pick_items
    @game.bubbles.select {|b| distance(b.x, b.y) < 15 and b.state != :destroying}.each do |b|
      pick b.item
      b.destroy
    end
  end
      
  def pick item
    @diagonal = false
    play item.sound
    case item
    when Action
      extend item.behaviour
      pick_action
      unextend item.behaviour
      
    when Skill
      lose_skill
      @skill = item
      extend @skill.behaviour
      pick_skill
      
    when Weapon
      lose_weapon
      @weapon = item
      extend @weapon.behaviour
      pick_weapon
    end
  end
  
  # Should be overloaded by actions
  def pick_action; end
  # Should be overloaded by skills
  def pick_skill; end
  # Should be overloaded by weapons
  def pick_weapon; end

  def kill_by killer
    point_to killer, killer==@player ? -1 : 1
    
    super
  end
  
  def point_to killer, points=1
    killer.points += points
    points_str = points>0 ? "+#{points}" : "#{points}"
    text = killer==@player ? "#{points_str}" : "#{points_str} #{killer.account.nick}"
    Text.new :text=>text, :x=>@x, :y=>@y, :factor=>1.0, :color=>killer.color, :timeout=>200
  end
  
  def destroy
    lose_skill
    lose_weapon
    Explosion.new :x => @x, :y => @y, :owner => @player, :factor => 0.5
    @player.home
    super
  end

  def button_down(button)
    @diagonal = false
    case button
    when :right; @button_right = true
    when :left; @button_left = true
    when :fire; @button_fire = true
    end    
  end
  
  def button_up(button)
    case button
    when :right; @button_right = false
    when :left; @button_left = false
    when :fire; @button_fire = false
    end    
  end
  
  # Pick the easiest victim
  def pick_victim strategy=:best
    met = case strategy
          when :best;     method(:best_angle)
          when :closest;  method(:closest_angle)
          end
    victim = nil
    bikes = @game.motorbikes.delete_if{|m| m == self}
    unless bikes.size==0
      victim = bikes.map do |m|
        ang = (@angle - met.call(m.x,m.y)).normalize_angle.abs
        [m, ang]
      end.sort_by {|m, ang| ang}.first.first
    end
    victim
  end
end
