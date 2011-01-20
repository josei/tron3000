class Options < Menu
  def on_create
    find(:resolution).value = "#{@game.config.res_x}x#{@game.config.res_y}"
    find(:fullscreen).value = @game.config.fullscreen ? 'on' : 'off'
    find(:invert_speakers).value = @game.config.invert_speakers ? 'on' : 'off'
  end
     
  button
  def back
    restart = false
    res_x, res_y = find(:resolution).value.split('x').map {|v| v.to_i}
    fullscreen = find(:fullscreen).value == 'on'
    restart = true if @game.config.res_x != res_x or @game.config.res_y != res_y or @game.config.fullscreen != fullscreen
    
    @game.config.res_x, @game.config.res_y, @game.config.fullscreen = res_x, res_y, fullscreen
    
    @game.config.invert_speakers = find(:invert_speakers).value == 'on'

    if restart
      @game.menu.message("Restart to apply changes") { @game.menu.back }
    else
      @game.menu.back
    end
  end

  option_list :nick => :resolution,
              :values => ['640x480', '800x480', '800x600', '1024x600', '1024x768', '1280x768', '1280x800', '1280x1024', '1440x900'],
              :value => '1024x768'
  
  option_list :nick => :fullscreen,
              :values => ['on', 'off'],
              :value => 'on'

  option_list :nick => :invert_speakers,
              :values => ['on', 'off'],
              :value => 'off'
end