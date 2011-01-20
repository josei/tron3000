require 'gosu'

class Gosu::Color
  def == c
    self.alpha==c.alpha and self.red==c.red and
    self.green==c.green and self.blue==c.blue
  end
end