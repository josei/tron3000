class Delete < Menu
  account nil
  title   'Delete?'
  
  button :text => 'Yes, sure'
  def yes
    @game.config.accounts.delete(@account)
    @game.menu.back # Go back to :edit_player
    @game.menu.back # Go back to :players
  end
  
  button :text => 'No, wait'
  def no
    @game.menu.back
  end
end