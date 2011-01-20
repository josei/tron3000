require 'item'

class Action < Item; end

def Action args={}, &block
  Action.new args, &block
end
