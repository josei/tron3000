require 'attributes'

class Account
  include Attributes
  
  points  0
  nick    { ['Player'].sort_by{rand}.first }
  hue     { rand(360) }
  ai      :human
end