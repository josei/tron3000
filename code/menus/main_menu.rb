class MainMenu < Menu
  button
  def new_game
    @game.menu.view :pick_players
  end

  button
  def players
    @game.menu.view :players
  end

  button
  def options
    @game.menu.view :options
  end

  button
  def extensions
    @game.menu.view :extensions
  end

  separator

  button
  def quit
    @game.close
  end
end