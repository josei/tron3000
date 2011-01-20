require 'attributes'

class Menu
  include Attributes

  game        { Game::instance }
  components  { self.class.components.map {|c| c2=c.dup; c2.code=method(c2.code) if c2.code.is_a? Symbol; c2.game=@game; c2} }
  title       { self.class.to_s.underscore.textize }
  
  Dir["#{Tron.path_for(Tron::Resources[:components])}/*.rb"].sort.map { |f| File.basename(f, ".rb") }.each do |c|
    eval <<-eos
      def self.#{c} args={}
        @components ||= []
        @components << #{c.camelize}.new(args)
      end
      def #{c} args={}, &block
        args[:code] = block if block_given?
        args[:game] = @game
        c = #{c.camelize}.new(args)
        if args[:before]
          @components.insert(@components.index(find(args[:before])), c)
        elsif args[:after]
          @components.insert(@components.index(find(args[:after]))+1, c)
        else
          @components << c
        end
        c
      end
    eos
  end
  
  def self.method_added(method)
    @components ||= []
    return if @components.size==0
    c = @components.last
    return unless c.focusable and c.code.nil?
    c.code = c.nick = method
    c.text = c.nick.to_s.textize if c.text == ''
    super
  end
  
  def self.components; @components; end
  
  def find nick
    @components.select{|c| c.nick == nick.to_sym}.first
  end
  
  def on_show; end
end