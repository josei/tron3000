Bot do
  probe     [-5,5,-25,25,-75,75,-150,150]
  
  def update
    super
    
    if @entity.is_a?(Arrow)
      @clean ||= nil; @clean_arrow ||= nil
      if @clean_arrow != @entity
        @clean_arrow = @entity
        busy_pixels = 0
        50.times do
          x, y = rand(@game.width), rand(@game.height)
          busy_pixels += 1 if @game.arena.getpixel(x,y).alpha != 0
        end
        @clean = (busy_pixels > 1)
      end
      
      if @clean
        keep_left unless @entity.erase
      else
        keep_fire
      end
    else
      to_angle = nil
      
      # Look for bubbles
      best_bubble = @game.bubbles.sort_by { |b| @entity.distance(b.x, b.y) }.first
      if best_bubble
        to_bubble_angle = @entity.closest_angle(best_bubble.x,best_bubble.y)
        to_angle = to_bubble_angle unless @entity.line(to_bubble_angle) {|x,y| @entity.obstacle?(x,y)}
      end
      
      # Point and shoot
      shoot = false
      if @entity.weapon
        best_bike = @game.motorbikes.select {|m| m != @entity}.sort_by { |m| @entity.distance(m.x, m.y) }.first
        if best_bike
          to_bike_angle = @entity.closest_angle(best_bike.x,best_bike.y)
          (shoot = true) and (to_angle = to_bike_angle) unless @entity.line(to_bike_angle) {|x,y| @entity.free?(x,y)}
        end
      end
      
      # Avoid obstacles
      if @entity.line {|x,y| @entity.obstacle?(x,y)}
        @probe_values ||= []
        if @probe_values.size != @probe.size
          @probe_values += @probe[@probe_values.size..@probe_values.size].
            map { |angle| [angle, @entity.line(angle) {|x,y| @entity.obstacle?(x,y)}] }.
            map { |angle, dist| [angle, dist ? dist : 100] }
          @probe_values = @probe_values.sort_by { |a, d| d }
        end

        to_angle, dist = @probe_values.last if @probe_values.size>1
      else
        @probe_values = []
      end
   
      if to_angle
        diff = (to_angle - @entity.angle).normalize_angle
        if diff > 0
          keep_right
        else
          keep_left
        end
        if diff < @entity.angle_step
          @probe_values = [] if @probe_values.size == @probe.size
          keep_fire if shoot
        end
      end
    end
  end
end
