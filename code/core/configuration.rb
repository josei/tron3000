class Configuration
  attr_accessor :accounts, :res_x, :res_y, :fullscreen, :invert_speakers, :extensions
  
  begin
  Filename = File.expand_path('~/.tron3000.data')
  rescue
  Filename = File.expand_path('./.tron3000.data')
  end
  
  def initialize
    defaults
  end

  def defaults
    @accounts ||= []
    @res_x ||= 800
    @res_y ||= 600
    @fullscreen ||= false
    @invert_screen ||= true
    @extensions ||= Tron.extensions.keys
    @extensions &= Tron.extensions.keys # Don't load unavailable extensions
    # Updates
    @accounts.each { |a| a.ai = :human if a.ai.nil? }
    
    self
  end
  
  def save
    File.open(Filename, 'w+') { |f| f << Marshal.dump(self) }
  end
  
  def self.load
    if Dir[Filename].empty?
      new
    else
      Marshal.load( File.read( Filename ) ).defaults
    end
  end
end