module Looper
  # x, y, angle and frame attributes have writer methods that ensure
  # the values are within their valid ranges.
  def x= var; @x = var.normalize_x; end
  def y= var; @y = var.normalize_y; end
  def angle= var; @angle = var.normalize_angle; end
  def frame= var; @frame = var.normalize(0..@image_resource.size); end

  def distance(x2, y2, x1=@x, y1=@y)
    dx = (x2-x1).normalize(-@game.width>>1..@game.width>>1)
    dy = (y2-y1).normalize(-@game.height>>1..@game.height>>1)
    return Math::sqrt(dx*dx + dy*dy)
  end

  # Returns the angle between two points with the shortest path possible
  def closest_angle(x2, y2, x1=@x, y1=@y)
    dx = (x2-x1).normalize(-@game.width>>1..@game.width>>1)
    dy = (y2-y1).normalize(-@game.height>>1..@game.height>>1)
    return Gosu::angle(0,0, dx,dy).normalize_angle
  end

  # Returns an angle that is close to the entity's current angle while trying not
  # to choose a long path
  def best_angle(x2, y2, x1=@x, y1=@y, angle=@angle)
    w, h = @game.width, @game.height
    [ [x1-w,y1-h], [x1,y1-h], [x1+w,y1-h],
      [x1-w,y1],   [x1,y1],   [x1+w,y1],
      [x1-w,y1+h], [x1,y1+h], [x1+w,y1+h] ].map { |x,y| [Gosu::angle(x,y,x2,y2), Gosu::distance(x,y,x2,y2)] }.
      sort_by{|a,dist| (angle-a).normalize_angle.abs+dist/10}.first.first
  end

  def draw_loop(image=@image_resource[@frame], x=@x, y=@y, angle=@angle, factor_x=@factor, factor_y=@factor, color=@color, mode=@draw_mode)
    gw, gh = @game.width, @game.height
    w2, h2 = (image.width / 2)*factor_x, (image.height / 2) * factor_y
    
    pos = [[x, y]]
    
    if y+h2 > gh then
      pos << [x - gw, y - gh] if x+w2 > gw
      pos << [x, y - gh]
      pos << [x + gw, y - gh] if x-w2 < 0
    end

    pos << [x - gw, y] if x+w2 > gw
    pos << [x + gw, y] if x-w2 < 0

    if y-h2 < 0 then
      pos << [x - gw, y + gh] if x+w2 > gw
      pos << [x, y + gh]
      pos << [x + gw, y + gh] if x-w2 < 0
    end

    pos.each { |ix, iy| image.draw_rot(ix, iy, 0, angle, 0.5, 0.5, factor_x, factor_y, color, mode)}
  end

  def draw_ray(w, l, image=@image_resource[@frame], x=@x, y=@y, angle=@angle, color=@color, mode=@draw_mode)
    u = [-offset_y(@angle,1),offset_x(@angle,1)]; v=[-u[1],u[0]]
    points = [ [x-w*u[0], y-w*u[1]], [x+w*u[0], y+w*u[1]],
               [x-w*u[0]+l*v[0], y-w*u[1]+l*v[1]], [x+w*u[0]+l*v[0], y+w*u[1]+l*v[1]] ]
    image.draw_as_quad(points[0][0],points[0][1],color, points[1][0],points[1][1],color,
                       points[2][0],points[2][1],color, points[3][0],points[3][1],color, 0,mode)
  end

  def draw_ray_loop(w, l, image=@image_resource[@frame], x=@x, y=@y, angle=@angle, color=@color, mode=@draw_mode)
    gw, gh = @game.width, @game.height
    
    pos = [[x, y]]
    
    pos << [x - gw, y - gh]# if x+w2 > gw
    pos << [x, y - gh]
    pos << [x + gw, y - gh] #if x-w2 < 0

    pos << [x - gw, y] #if x+w2 > gw
    pos << [x + gw, y] #if x-w2 < 0

    pos << [x - gw, y + gh] #if x+w2 > gw
    pos << [x, y + gh]
    pos << [x + gw, y + gh] #if x-w2 < 0

    pos.each { |rx, ry| draw_ray(w, l, image, rx, ry, angle, color, mode) }
  end
end

class Numeric
  def normalize(range)
    ((self - range.begin) % (range.end-range.begin)) + range.begin
  end
  
  def normalize_x; normalize(0..Game::instance.width); end
  def normalize_y; normalize(0..Game::instance.height); end
  def normalize_angle; normalize(-180..180); end
end
