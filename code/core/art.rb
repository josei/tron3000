class Art
  attr_reader :images, :audio
  
  def initialize(game)
    @game = game
    @images, @audio = {}, {}
        
    Tron.extensions.each do |ext, path|
      # Automatically load images & animations
      Dir["#{path}/#{Tron::Resources[:graphics]}/*.png"].each do |f|
        base = File.basename(f,'.png')
        if base.include?('-') then # Animation
          name = base[0...base.index('-')]
          info = base[base.index('-')+1..-1].split('x')
          width, height, frames = info[0].to_i, info[1].to_i, info[2].to_i
          @images[name.to_sym] = Gosu::Image.load_tiles(game, f, width, height, false).first(frames)
        else # Plain image
          @images[base.to_sym] = [Gosu::Image.new(game, f, false)]
        end
      end

      # Automatically load audio
      Dir["#{path}/#{Tron::Resources[:audio]}/*.wav"].each do |f|
        base = File.basename(f,'.wav')
        @audio[base.to_sym] = Gosu::Sample.new(game, f)
      end
    end
    @images = @images.to_struct
    @audio = @audio.to_struct
  end
end
