require 'item'

class Skill < Item
  timeout 1000
end

def Skill args={}, &block
  Skill.new args, &block
end
