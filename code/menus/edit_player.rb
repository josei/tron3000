class EditPlayer < Menu
  account nil
  
  def on_create
    find(:color_picker).hue = @account.hue
    find(:nick).text_input.text = @account.nick
    find(:type).values += @game.bots
    find(:type).value = @account.ai if find(:type).values.include?(@account.ai)
  end
  
  button
  def back
    @account.nick = find(:nick).text_input.text
    @account.hue = find(:color_picker).hue
    @account.ai = find(:type).value
    @game.menu.back
  end

  text_input :nick=>:nick, :text=>'Name'
  
  option_list :nick => :type,
              :values => [:human],
              :value => :machine

  color_picker :nick=>:color_picker, :text => 'Pick a color', :hue => 0
  
  button
  def delete_player
    @game.menu.view :delete, :account => @account
  end
end