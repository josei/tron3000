require 'spinning'
require 'sticky'

class Flare < Entity
  spinning
  sticky
  
  draw_mode   :additive
  spin_speed  2
  follow      nil
  factor      0.5
end