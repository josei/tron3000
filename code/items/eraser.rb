Action do
  def pick_action
    super
    @game.arena.clear_all
  end
end