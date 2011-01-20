class PickPlayers < Menu
  keys nil
  
  def on_create
    @game.config.accounts.each { |a| show_account a }
  end

  button
  def back
    @game.menu.back
  end

  button
  def start
    if accounts.size < 2
      @game.menu.message "Select some players!"
      return
    end
    
    @game.players = []
    accounts.each do |a|
      if a.ai == :human
        Player.new(:button_left=>@keys[a][:left], :button_right=>@keys[a][:right], :button_fire=>@keys[a][:fire], :account => a).join
      else
        ai = @game.bots.include?(a.ai) ? a.ai : :machine
        Object.const_get(ai.to_s.camelize).new(:account => a).join
      end
    end
    @game.start find(:time).value[0..2].to_i
    @game.menu.view :main_menu
    @game.menu.visible = false
  end
  
  option_list :nick => :time,
              :values => ['5 minutes (snack)','15 minutes (official)','30 minutes (extended)','60 minutes (crazy)'],
              :value => '15 minutes (official)'

  separator
  
  private
  
  def show_account a
    selection(:text => a.nick, :hue => a.hue, :object => a, :after => :separator) do
      @game.menu.selection.selected = (!@game.menu.selection.selected and accounts.size<4) ? true : false
      if @game.menu.selection.selected and a.ai == :human
        @keys ||= {}
        @game.menu.message "#{a.nick}\nPress left" do |k1|
          @keys[a] ||= {}; @keys[a][:left] = k1
          @game.menu.message "#{a.nick}\nPress right" do |k2|
            @keys[a] ||= {}; @keys[a][:right] = k2
            @game.menu.message "#{a.nick}\nPress fire" do |k3|
              @keys[a] ||= {}; @keys[a][:fire] = k3
            end
          end
        end
      end
    end
  end
  
  def accounts
    @components.select {|c| c.is_a?(Selection) and c.selected}.map {|c| c.object}
  end
end
