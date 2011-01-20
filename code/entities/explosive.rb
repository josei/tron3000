module Explosive
  def destroy
    @explosion ||= :explosion
    Object.const_get(@explosion.to_s.camelize).new :x=>@x, :y=>@y, :angle=>@angle, :owner=>@owner
    super
  end
end