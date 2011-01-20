module Behaviours
  def ancestors; @ancestors ||= {}; end
  
  def extend mod
    @ancestors ||= {}
    raise ArgumentError, "module already included" if @ancestors[mod]
    mod_clone = mod.clone
    super mod_clone
    @ancestors[mod] = mod_clone
  end

  def unextend mod
    raise ArgumentError, "unextend takes an included module." unless @ancestors[mod]
    mod_clone = @ancestors[mod]
    @ancestors.delete mod
    mod_clone.instance_methods.each {|m| mod_clone.module_eval { remove_method m } }
  end
end