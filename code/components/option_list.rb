class OptionList < Component
  values          nil
  value           nil
  text          { nick.to_s.textize }

  def click
    @value = @values[(@values.index(@value) + 1) % @values.size]
    super
  end
  
  def text
    "#{@text}: #{@value}"
  end
end
