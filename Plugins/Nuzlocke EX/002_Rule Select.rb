module ChallengeModes

  module_function
  #-----------------------------------------------------------------------------
  # Select rules for challenge mode
  #-----------------------------------------------------------------------------
  def select_mode
    selected_rules = select_active_rules

    return selected_rules
  end
  #-----------------------------------------------------------------------------
  # Select custom ruleset for challenge
  #-----------------------------------------------------------------------------
  def select_active_rules
    all_rules = RULES.keys
    excluded_indices = [5, 6, 7, 8]
    # Excluir las reglas en los índices especificados
    excluded_rules = excluded_indices.map { |index| all_rules[index] }.compact
    selected_rules = all_rules - excluded_rules
    return selected_rules
  end
  

  def display_rules(rules)
    vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    infowindow = Window_AdvancedTextPokemon.newWithSize("", 0, 0, Graphics.width, Graphics.height, vp)
    infowindow.setSkin(MessageConfig.pbGetSystemFrame)
    infowindow.letterbyletter = true
    infowindow.lineHeight = 28
    rule_text  = ""
    rules.each_with_index do |rule, i| 
      next if rule == :GAME_OVER_WHITEOUT
      rule_text += "- " + _INTL(ChallengeModes::RULES[rule][:desc])
      rule_text += "\n" if i != rules.length - (rules.include?(:GAME_OVER_WHITEOUT) ? 2 : 1)
    end
    pbSetSmallFont(infowindow.contents)
    infowindow.text = rule_text
    infowindow.resizeHeightToFit(rule_text)
    infowindow.height = Graphics.height if infowindow.height > Graphics.height
    infowindow.y = (Graphics.height - infowindow.height) / 2
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      infowindow.update
      pbUpdateSceneMap
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        if infowindow.busy?
          pbPlayDecisionSE if infowindow.pausing?
          infowindow.resume
        else
          break
        end
      end
    end
    rule_text  = ""
    if rules.include?(:GAME_OVER_WHITEOUT) || !rules.include?(:PERMAFAINT)
      rule_text += "- " + _INTL(ChallengeModes::RULES[:GAME_OVER_WHITEOUT][:desc])
    else
      rule_text += "- " + _INTL("If all your party Pokémon faint in battle, you will be allowed to continue the challenge with unfainted Pokémon from your PC.")
      rule_text += "\n- " + _INTL("If all the Pokémon in your Party and PC faint, you will lose the challenge.")
    end
    rule_text += "\n"
    rule_text += "- " + _INTL("The challenge begins after you have obtained your first Pokéball.")
    pbSetSmallFont(infowindow.contents)
    infowindow.text = rule_text
    infowindow.resizeHeightToFit(rule_text)
    infowindow.height = Graphics.height if infowindow.height > Graphics.height
    infowindow.y = (Graphics.height - infowindow.height) / 2
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      infowindow.update
      pbUpdateSceneMap
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        if infowindow.busy?
          pbPlayDecisionSE if infowindow.pausing?
          infowindow.resume
        else
          break
        end
      end
    end
    infowindow.dispose
    vp.dispose
  end
  #-----------------------------------------------------------------------------
end

class Window_CommandPokemon_Challenge < Window_CommandPokemon
  def initialize(commands, width = nil)
    @text_key = []
    commands.each_with_index do |command, i|
      next if !command.is_a?(Array)
      commands[i]  = command[0]
      @text_key[i] = command[1]
    end
    super(commands, width)
  end

  def drawItem(index, count, rect)
    pbSetSystemFont(self.contents)
    rect = drawCursor(index, rect)
    base   = self.baseColor
    shadow = self.shadowColor
    x_pos = rect.x 
    y_pos = rect.y 
    pbDrawShadowText(self.contents, x_pos + 4, y_pos + (self.contents.text_offset_y || 0), 
      rect.width, rect.height, @commands[index], base, shadow)
    return if !@text_key[index] 
    text = _INTL("OFF")
    base   = Color.new(232, 32, 16)
    shadow = Color.new(248, 168, 184)
    if @text_key[index] == 1
      text = _INTL("ON")
      base   = Color.new(0, 112, 248)
      shadow = Color.new(120, 184, 232)
    end
    text = "[#{text}]"
    option_width = rect.width / 2
    x_pos += rect.width - option_width
    pbSetSystemFont(self.contents)
    pbDrawShadowText(self.contents, x_pos, rect.y + (self.contents.text_offset_y || 0),
      option_width, rect.height, text, base, shadow, 1)
  end

  def commands=(commands)
    @text_key = []
    commands.each_with_index do |command, i|
      next if !command.is_a?(Array)
      commands[i]  = command[0]
      @text_key[i] = command[1]
    end
    @commands = commands
  end
end
