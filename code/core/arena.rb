require 'opengl'
require 'glu'

class Arena
  include Gl
  include Glu

  Transparence = Gosu::Color.new(0,0,0,0)
  CHUNK_SIZE = 256
  CHUNK_SIZE_BITS = CHUNK_SIZE.bits
  Chunk = Struct.new(:tex, :data, :changed, :clean)

  def initialize(game)
    @game = game

    color = Transparence
    color_string = [color.red,color.green,color.blue,color.alpha].pack("C*")
    @emptiness = Array.new(CHUNK_SIZE*CHUNK_SIZE, color_string)*""
    @chunks = (1..(@game.width.to_f/CHUNK_SIZE).ceil).map do
      (1..(@game.height.to_f/CHUNK_SIZE).ceil).map do
        tex = glGenTextures(1).first
        data = @emptiness.clone
        glBindTexture(GL_TEXTURE_2D, tex)
  	    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, CHUNK_SIZE, CHUNK_SIZE, 0, GL_RGBA, GL_UNSIGNED_BYTE, data)
  	    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
  	    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
    		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
        Chunk.new(tex, data, false, true)
      end
    end
  end

  def putpixel(x, y, color=Transparence)
    x = x.to_i % @game.width
    y = y.to_i % @game.height
    chunk = @chunks[x >> CHUNK_SIZE_BITS][y >> CHUNK_SIZE_BITS]
    index = (((y % CHUNK_SIZE) << CHUNK_SIZE_BITS) + (x % CHUNK_SIZE)) << 2
    chunk.data.setbyte index, color.red
    chunk.data.setbyte index + 1, color.green
    chunk.data.setbyte index + 2, color.blue
    chunk.data.setbyte index + 3, color.alpha
    chunk.changed = true
    chunk.clean = false
  end

  def getpixel(x, y)
    x = x.to_i % @game.width
    y = y.to_i % @game.height
    chunk = @chunks[x >> CHUNK_SIZE_BITS][y >> CHUNK_SIZE_BITS]
    return Transparence if chunk.clean
    index = (((y % CHUNK_SIZE) << CHUNK_SIZE_BITS) + (x % CHUNK_SIZE)) << 2
    Gosu::Color.new(chunk.data.getbyte(index+3), chunk.data.getbyte(index), chunk.data.getbyte(index+1), chunk.data.getbyte(index+2))
  end

  def clear(x, y, size)
    x, y, size = x.to_i, y.to_i, size.to_i
    width, height = @game.width, @game.height

    color = Transparence
    color_string = [color.red,color.green,color.blue,color.alpha].pack("C*")
    (y-size).upto(y+size) do |py|
      (x-size).upto(x+size) do |px|
        px %= width
        py %= height
        chunk = @chunks[px >> CHUNK_SIZE_BITS][py >> CHUNK_SIZE_BITS]
        index = (((py % CHUNK_SIZE) << CHUNK_SIZE_BITS) + (px % CHUNK_SIZE)) << 2
        chunk.data[index..index+3] = color_string
        chunk.changed = true
      end
    end
  end

  def clear_all
    @chunks.each { |row| row.each { |c| c.data = @emptiness.clone; c.changed = true; c.clean = true } }
  end

  def paint_all(color)
    color_string=[color.red,color.green,color.blue,color.alpha].pack("C*")
    players_cs = []
    @game.players.each do |p|
      cs=[p.color.red,p.color.green,p.color.blue,p.color.alpha].pack("C*")
      players_cs << cs
    end
    @chunks.each do |row|
      row.each do |c|
        players_cs.each { |cs| c.data.gsub!(cs,color_string) }
        c.changed = true
      end
    end
  end

  def draw
    offsetx, offsety, scale = compute_offset_and_scale

    # Update changed chunks
    @chunks.each do |cy|
      cy.each do |c|
        next unless c.changed
        glBindTexture(GL_TEXTURE_2D, c.tex)
  	    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, CHUNK_SIZE, CHUNK_SIZE, 0, GL_RGBA, GL_UNSIGNED_BYTE, c.data)
    	  c.changed = false
	    end
    end

    # Draw all chunks
    @game.gl do
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE);
      glEnable(GL_TEXTURE_2D)

      x = offsetx
      @chunks.each do |cy|
        y = offsety
        cy.each do |c|
          glBindTexture(GL_TEXTURE_2D, c.tex)

          glBegin(GL_QUADS);
          glColor4f(1.0,1.0,1.0,0.25)
          [[x-1, y-1],           [x+1, y-1],
                       [x, y],
           [x-1, y+1],           [x+1, y+1]].each do |px, py|
            glTexCoord2d(0.0,0.0); glVertex2d(px,py)
            glTexCoord2d(1.0,0.0); glVertex2d(px+CHUNK_SIZE*scale,py)
            glTexCoord2d(1.0,1.0); glVertex2d(px+CHUNK_SIZE*scale,py+CHUNK_SIZE*scale)
            glTexCoord2d(0.0,1.0); glVertex2d(px,py+CHUNK_SIZE*scale)
          end
          glEnd()

          y += CHUNK_SIZE*scale
        end
        x += CHUNK_SIZE*scale
      end
    end
  end

  private

  def compute_offset_and_scale
    actual_width = glGetIntegerv(GL_VIEWPORT)[-2]
    actual_height = glGetIntegerv(GL_VIEWPORT)[-1]
    offsetx = 0
    offsety = 0

    if @game.fullscreen?
      scalex = actual_width / (@game.width).to_f;
      scaley = actual_height / (@game.height).to_f;
      scale = [scalex, scaley].min

      if scalex < scaley
        offsety = (actual_height / scalex - @game.height) / 2.0 * scale
      elsif scaley < scalex
        offsetx = (actual_width / scaley - @game.width) / 2.0 * scale
      end
    else
      scale = actual_width / (@game.width).to_f;
    end

    [offsetx, offsety, scale]
  end
end
