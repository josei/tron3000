module Projectile
  def self.included klass
    klass.class_eval do
      speed   8
    end
  end

  def on_create
    super
    advance(speed+5) { obstacle? }
  end
    
  def update
    super
    advance(speed) { obstacle? }
  end
end