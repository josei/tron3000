# Idea from http://www.roscripts.com/snippets/show/20, thanks!
class Hash
   def to_struct
      Struct.new(*keys).new(*values)
   end
end