require 'singleton'

class Game < Gosu::Window
  include Singleton
  
  attr_accessor :players
  attr_reader :arena, :entities, :config, :menu, :frames, :fps, :art, :time
  attr_reader :font, :font_height, :big_font, :big_font_height
  attr_reader :bots
    
  def initialize
    @config = Configuration.load
    # Trick to avoid resolution crashes
    config2 = @config.clone
    config2.res_x, config2.res_y, config2.fullscreen = 800, 600, false
    config2.save
    super(@config.res_x, @config.res_y, @config.fullscreen, 20)
    self.caption = "Tron 3000"

    @art = Art.new(self)
    @font_height = 20
    @font = Gosu::Font.new(self, Gosu::default_font_name, @font_height)
    @big_font_height = 60
    @big_font = Gosu::Font.new(self, Gosu::default_font_name, @big_font_height)
    @arena = Arena.new(self)
    @menu = MenuManager.new :game => self
    @timer = Timer.new
    @players = []
    @entities = []
    @time = 0

    @all_items, @bots = {}, [];
    Tron.extensions.each do |ext, path|
      @all_items[ext] = Tron.contents(:items, Tron.extensions[ext]).map do |i|
        item = Object.const_get(i.to_s.camelize)
        item.image = :nothing unless @art.images.respond_to?(item.image)
        item.image_resource = @art.images[item.image]
        item.sound = :item unless @art.audio.respond_to?(item.sound)
        item
      end
      @bots += Tron.contents(:bots, Tron.extensions[ext])
    end
    
    @frames = 0    
    @background = nil    
  end
    
  def items
    config.extensions.inject([]) { |items,ext| items += @all_items[ext] }
  end
  
  def start time=15
    @entities = []
    @time = 60*time
    @players.each { |p| p.start }
    @arena.clear_all
    switch_background
    Glow.new :x=>width/2, :y=>height/2, :factor=>15.0*height/600, :speed=>2
    @art.audio.gong.play
    @demo = false
  end

  def demo
    @players = []
    hue = rand(360)
    Machine.new(:account=>Account.new(:nick=>'',:ai=>:machine, :hue=>hue)).join
    Machine.new(:account=>Account.new(:nick=>'',:ai=>:machine, :hue=>hue+180)).join
    start
    @demo = true
  end

  def switch_background
    image = art.images.members.select{|m| m.index("background_")}.sort_by{rand}.first
    @background = art.images[image].first
    @background_color = Gosu::Color.new(image.split('_')[1].to_i,255,255,255)
  end

  def finish
    if @demo
      demo
      return
    end
    @art.audio.gong.play
    winner, second = players.sort_by{|p| -p.points}.first(2)
    if winner.points == second.points
      # Draw
      Text.new :x=>width/2, :y=>height/2, :text=>'Tie break! +30 seconds'
      @time += 30
    else
      # Somebody wins
      @menu.message("The winner is...\n#{winner.account.nick}", 300, 0.005) { @menu.visible = true }
      winner.account.points += @players.size-1
      @config.save
    end
  end
  
  def update
    @menu.update
    @frames += 1
    demo if @frames == 1

    return unless @time > 0 and (!@menu.visible or @demo) 
    
    if @frames % 50 == 0
      @art.audio.click.play if @time <=10
      @time -= 1
    end

    finish if @time == 0

    @entities.each { |i| i.update }
    @players.each { |p| p.update }

    # Create items
    @item_timeout ||= rand(100) + 100; @item_timeout -=1
    if @item_timeout < 0 and bubbles.size < 30
      Bubble.new :item => items[rand(items.size)] if items.size > 0
      @item_timeout = nil 
    end
  end
    
  def draw
    @timer.calculate_fps
    
    factor=Math.sin(@frames/200.0)/20+1.1; @background.draw_rot(width/2,height/2,-10,0, 0.5,0.5, factor,factor, @background_color) if @background
    @arena.draw
    @entities.each { |i| i.draw }
    @players.each { |p| p.draw }
    #@font.draw_rel("FPS: #{@timer.fps} (min: #{@timer.previous_fps.min})", width/2, 10, 10, 0.5,0.5, 1.0, 1.0, 0x88ffff00)
    @font.draw_rel((@time/60).to_s+":"+("%.2d"%(time%60)), width/2,height-25,10, 0.5,0.5, 2.0, 2.0, 0x88ff7f00) if @time != 0
    @menu.draw
  end
  
  def button_down(id)
    @menu.button_down(id)
    return if @menu.visible
    @players.each { |p| p.button_down(id) }
  end

  def button_up(id)
    @menu.button_up(id)
    return if @menu.visible
    @players.each { |p| p.button_up(id) }
  end
  
  def motorbikes; players.map { |p| p.entity }.select{ |e| e.is_a? Motorbike }; end
  
  def bubbles; entities.select{ |e| e.is_a? Bubble }; end
  
  def find_player_by_color c
    players.select{|p| p.color == c}.first
  end
  
  def close
    super
    @config.save
  end
end
