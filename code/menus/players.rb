class Players < Menu
  def on_show
    s = @components.index(find(:separator))
    (@components.size-s-1).times { @components.pop }
    
    @game.config.accounts.sort_by{|a| a.points}.each { |a| show_account a }
  end
  
  button
  def back
    @game.menu.back
  end
  
  button
  def new_player
    a = Account.new
    @game.config.accounts << a
    show_account a
  end
  
  separator
  
  private
  def show_account a
    points = "#{a.points} #{a.points == 1 ? 'point' : 'points'}"
    button(:text => "#{a.nick}\t(#{points})", :color => Gosu::Color.from_ahsv(128,a.hue, 1.0, 1.0), :after=>:separator) { @game.menu.view(:edit_player, :account=>a) }
  end
end