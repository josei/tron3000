class Timer
  attr_reader :fps, :previous_fps
  
  def initialize
    @last_millis, @fps, @previous_fps = Gosu::milliseconds, 0, []
  end
  
  def calculate_fps
    now = Gosu::milliseconds
    @previous_fps << 1000 / (now - @last_millis + 1)
    @previous_fps.shift if @previous_fps.size > 50
    @fps = 0; @previous_fps.each {|fps| @fps += fps}; @fps /= @previous_fps.size
    @last_millis = now
  end
end