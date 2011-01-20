class Selection < Component
  hue             nil
  selection       nil
  selected        false
  object          nil
  
  def color
    if @selected
      Gosu::Color.from_ahsv(128,@hue, 1.0, 1.0)
    else
      @color
    end
  end
end