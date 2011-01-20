class TextInput < Component
  text_input      { Gosu::TextInput.new }

  def click
    @game.text_input = @game.text_input.nil? ? @text_input : nil
  end

  def text
    text = "#{@text}: #{@text_input.text}"
    text += "_" if @text_input == @game.text_input
    text
  end
end