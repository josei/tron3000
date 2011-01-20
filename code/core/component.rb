require 'attributes'

class Component
  include Attributes  
  
  game        nil
  focus       0.0
  focusable   true
  code        nil
  nick        nil
  text        ''
  color     { Gosu::Color.new(128,128,220,128) }
  
  def click
    @code.call if @code
  end
  
  def update
    if @game.menu.visible
      @focus -= 0.1 unless @focus <= 1.0 or @game.menu.selection == self
      @focus += 0.1 if (@focus < 1.5 and @game.menu.selection == self) or @focus <= 1.0
    else
      @focus -= 0.1 if @focus >= 0.0
    end    
  end
end