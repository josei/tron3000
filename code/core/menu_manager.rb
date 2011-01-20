require 'attributes'

class MenuManager
  include Attributes
  
  game              nil
  menu              nil
  previous_menus    []
  visible           true
  scale_factor    { @game.height.to_f/900 }
  factor            1.0
  color             Gosu::Color.new(128, 192,255,128)
  white             Gosu::Color.new(255,255,255,255)
  selection         nil
  scroll            0
  shade           { @game.art.images[:shade].first }
  button_right      false
  button_left       false
  button_enter      false
  popups            []
  
  def update
    view :main_menu unless @menu
    
    @popups.each do |p|
      p.timer -= 1
      p.focus -= p.speed if p.focus > (p.visible ? 1.1 : 0.1)
      @popups.delete p if p.focus < 0.1
    end

    @menu.components.each {|c| c.update}
        
    # Use scroll
    if @menu.components.size > 8
      @previous_scroll ||= @scroll
      @scroll = @previous_scroll*0.9 + 0.1*(0.1-@menu.components.index(@selection)*text_height)
      @previous_scroll = @scroll
    else
      @previous_scroll = @scroll = 0
    end
  end

  def draw
    return unless @menu

    y = 0.3; @menu.components.each do |c|
      y += text_height(@factor)
      
      texts = [[0, 0.5, c.text]]
      texts = [[-0.05, 1.0, c.text.split("\t")[0]],  [0.05, 0.0, c.text.split("\t")[1]]] if c.text.index("\t")
      texts.each do |dx, center, text|
        draw_text(text, 0.5+dx,y+@scroll, @factor*c.focus/1.2, Gosu::Color.new(([c.color.alpha*c.focus/4,0].max).to_i,c.color.red,c.color.green,c.color.blue),center)
        draw_text(text, 0.5+dx,y+@scroll, @factor*c.focus, Gosu::Color.new(([c.color.alpha*c.focus,0].max).to_i,c.color.red,c.color.green,c.color.blue),center)
      end
    end
    if @visible
      draw_image(@game.art.images.tron3000.first, 0.5, 0.15, 0, @factor*(1+Math::sin(@game.frames/50.0)/20.0), @white, 0.5,0.5, :additive)
      draw_image(@game.art.images.eltorbellino.first, 0.95, 0.9, 0, @factor*(0.5+Math::sin(@game.frames/100.0)/20.0), @white)
      draw_text(@menu.title, 0.5,0.2, @factor*4, Gosu::Color.new(@color.alpha/2,@color.red,(@color.green/2).to_i,(@color.blue*1.5).to_i))
      y = 0.85; @game.config.extensions.each do |ext|
        next if ext == :default
        draw_image(@game.art.images[ext].first, 0.1, y, Math::sin((@game.frames+y*10)/40.0)*10, @factor*(1+Math::sin((@game.frames+y*10)/50.0)/20.0), @white)
        y-=0.15
      end
    end
    @popups.each do |p|
      draw_image(@shade, 0.5, 0.4, 0, @factor*20*p.focus*p.focus, Gosu::Color.new((255*(1.0-(p.focus-1.0).abs)).to_i,@white.red,@white.green,@white.blue))
      texts = [[0.5, p.text]]
      texts = [[1.0, p.text.split("\n")[0]],  [0.0, p.text.split("\n")[1]]] if p.text.index("\n")
      texts.each do |center, text|
        draw_text(text, 0.5,0.4, @factor*(p.focus*p.focus+0.5), Gosu::Color.new((255*(1.0-(p.focus-1.0).abs)).to_i,(@color.red/2).to_i,(@color.green/2).to_i,(@color.blue*1.5).to_i),0.5,center)
      end
    end
  end
  
  def draw_image(image, x, y, angle=0, factor=@factor,color=@color,center_x=0.5,center_y=0.5,mode=:default)
    image.draw_rot(coord(x)+(@game.width-@game.height)/2,coord(y),0, angle, center_x,center_y, factor*@scale_factor,factor*@scale_factor, color, mode)
  end  
  def draw_text(text, x, y,factor=@factor,color=@color,center_x=0.5,center_y=0.5)
    @game.big_font.draw_rel(text, coord(x)+(@game.width-@game.height)/2,coord(y),0, center_x,center_y, factor*@scale_factor,factor*@scale_factor, color)
  end  
  def text_height(factor=@factor); relative(@game.big_font_height*factor*@scale_factor); end
  def text_width(text,factor=@factor); relative(@game.big_font.text_width(text,factor*@scale_factor)); end
  
  # Translates a relative coordinate into a real one
  def coord(x); (x*@game.height).to_i; end
  
  # Translates a real coordinate into a relative one
  def relative(x); x.to_f/@game.height; end
  
  def view v, args={}
    @previous_menus << @menu
    show Object.const_get(v.to_s.camelize).new(args)
  end
  
  def back
    show @previous_menus.pop
  end
  
  def show v
    @menu = v
    @menu.components.each { |c| c.focus = 0 }
    @menu.on_show
    @visible = true
    @selection = @menu.components.first
  end
  
  def message text, timer=0, speed=0.1, &block
    block = Proc.new{} unless block_given?
    @popups << {:text=>text, :block=>block, :focus=>2.0, :timer=>timer, :speed => speed, :visible => true}.to_struct
  end
  
  def button_down(id)
    ((parse_button(id)==:up || parse_button(id)==:down) ? @game.art.audio.move : @game.art.audio.click).play if @visible
    if !@popups.empty? and @popups.last.visible
      if @popups.last.timer <= 0
        block = @popups.last.block
        @popups.last.visible = false
        block.call(id)
      end
      return
    end
    id = parse_button(id)
    
    @visible = !@visible if id == :escape
    return if !@visible
        
    case id
    when :enter
      @selection.click
      @button_enter = true
    when :up
      begin
        @selection = @menu.components[@menu.components.index(@selection || @sel_next) - 1]
      end until @selection.focusable
    when :down
      begin
        @selection = @menu.components[(@menu.components.index(@selection || @sel_next) + 1) % @menu.components.size]
      end until @selection.focusable
    when :left
      @button_left = true
    when :right
      @button_right = true
    end
  end

  def button_up(id)
    id = parse_button(id)
    return unless @visible
    case id
    when :enter
      @button_enter = false
    when :left
      @button_left = false
    when :right
      @button_right = false
    end
  end

  def parse_button id
    case id
    when Gosu::KbUp;     :up
    when Gosu::KbDown;   :down
    when Gosu::KbLeft;   :left
    when Gosu::KbRight;  :right
    when Gosu::KbReturn; :enter
    when Gosu::KbEscape; :escape
    end
  end
end
