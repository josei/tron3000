class String
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      self.first + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end
  
  def underscore
    self.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase.
      gsub(" ", "_")
  end
  
  def textize
    temp = gsub('_', ' ')
    temp = temp[0..0].upcase + temp[1..-1]
    temp
  end
end