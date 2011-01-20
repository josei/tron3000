class Gosu::Sample  
  def loop
    @instance ||= nil
    @instance = play if @instance.nil? or !@instance.playing?
  end

  def stop
    @instance.stop unless @instance.nil?
  end
end