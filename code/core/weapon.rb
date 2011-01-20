require 'item'

class Weapon < Item
  ammo    10
  timeout 10
end

def Weapon args={}, &block
  Weapon.new args, &block
end
