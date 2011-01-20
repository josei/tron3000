class Extensions < Menu
  def on_create
    Tron.extensions.each { |ext,path| show_extension ext }
  end
     
  button
  def back
    @game.config.extensions = @components.select {|c| c.is_a?(OptionList) and c.value=='on'}.map{|c| c.nick}
    @game.menu.back
  end

  separator

  private
  def show_extension e
    option_list :nick => e,
                :value => (@game.config.extensions.include?(e) ? 'on': 'off'),
                :values => ['on', 'off'],
                :after => :separator
  end
end