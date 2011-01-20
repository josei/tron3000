Weapon :ammo => 50 do
  def speed
    normal = super
    if @button_fire
      normal * 3
    else
      normal
    end
  end
end