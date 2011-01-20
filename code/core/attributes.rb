# Example of an 'attributed' class:
# class Insect
#   include Attributes
#   wings       4
#   life        100
#   inspiration {rand(100)}
#   parent      nil
#   def lose_wing; @wings -= 1; end
# end
# 
# Inspired in Dwemthy's Array. In this case, it's a module, an attributes are inherited. Also, blocks can be used.
module Attributes
  def self.included klass; klass.extend ClassMethods; end

  module ClassMethods
    def method_missing method, *args, &block
      if args.size == 0 and !block_given?
        include Object.const_get(method.to_s.camelize)
      else
        @attribute_values ||= {}
        @attribute_list ||= []
        @attribute_values[method] = args[0]
      
        if block_given? then
          instance_eval do define_method("default_#{method.to_s}", &block) end
        else
          attr_reader "default_#{method}"
        end
        @attribute_list << method unless @attribute_list.include?(method)

        accessors = args[1] || :rw
        attr_reader "initial_#{method}"
        attr_reader "#{method}" if accessors.to_s.index('r') and !instance_methods.map{|m| m.to_s}.include?("#{method}")
        attr_writer "#{method}" if accessors.to_s.index('w') and !instance_methods.map{|m| m.to_s}.include?("#{method}=")
      end
    end
    
    def attribute_list; @attribute_list; end
    def attribute_values; @attribute_values; end
    
    def inherited klass
      klass.instance_variable_set('@attribute_list', @attribute_list.clone)
      klass.instance_variable_set('@attribute_values', @attribute_values.clone)
    end
  end
  
  def initialize args={}
    # Set defaults
    self.class.attribute_values.each { |k,v| instance_variable_set("@default_#{k}",v) }
    
    # Set values with user's params
    self.class.attribute_list.each { |k,v| instance_variable_set("@#{k}",args[k]); }
    # Set values with defaults if needed - declaration order is maintained
    self.class.attribute_list.each do |k|
      met = method("default_#{k}").call
      instance_variable_set("@#{k}", met.nil? ? eval("@#{k}") : met) if args[k].nil?
    end

    # Set initial values
    self.class.attribute_values.each { |k,v| eval "@initial_#{k} = @#{k}" }
    
    on_create
  end

  def on_create; end
end
