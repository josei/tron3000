require 'player'

def Bot &block
  c = Object.const_set(File.basename(caller.first.split(':')[-2], '.rb').camelize, Class.new(Bot))
  c.class_eval(&block)
end

class Bot < Player
  release_left_timeout  0
  release_right_timeout 0
  release_fire_timeout  0

  def update
    super
    
    @release_left_timeout  -= 1; release_left  if @release_left_timeout  == 0
    @release_right_timeout -= 1; release_right if @release_right_timeout == 0
    @release_fire_timeout  -= 1; release_fire  if @release_fire_timeout  == 0
  end

  def press_left; @entity.button_down(:left); end
  def press_right; @entity.button_down(:right); end
  def press_fire; @entity.button_down(:fire); end

  def release_left; @entity.button_up(:left); end
  def release_right; @entity.button_up(:right); end
  def release_fire; @entity.button_up(:fire); end

  def keep_left;  @entity.button_down(:left)  unless @button_left;  @release_left_timeout  = 1; end
  def keep_right; @entity.button_down(:right) unless @button_right; @release_right_timeout = 1; end
  def keep_fire;  @entity.button_down(:fire)  unless @button_fire;  @release_fire_timeout  = 1; end
end
