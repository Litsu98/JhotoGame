#===============================================================================
# DiegoWT's Starter Selection script
#===============================================================================
class Quizz
  def initialize(pkmn1, pkmn2, pkmn3)
    @select        = nil
    @frame         = 0
    @selframe      = 0
    @ballAnimation = 0
    @endscene      = 0
    @pkmn1         = pkmn1; @pkmn2 = pkmn2; @pkmn3 = pkmn3
    
    @viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites    = {}
    
    @sprites["base"] = IconSprite.new(0, -40, @viewport)
    if StarterSelSettings::STARTERBG == 1 
      @sprites["base"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/base1")
    elsif StarterSelSettings::STARTERBG == 2 
      @sprites["base"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/base2")
    end
    @sprites["base"].opacity = 0
    
    @sprites["shadow_1"] = IconSprite.new(106, 212, @viewport)
    @sprites["shadow_2"] = IconSprite.new(260, 212, @viewport)
    @sprites["shadow_3"] = IconSprite.new(414, 212, @viewport)
    for i in 1..3
      if StarterSelSettings::STARTERBG == 1 
        @sprites["shadow_#{i}"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/shadow1")
      elsif StarterSelSettings::STARTERBG == 2 
        @sprites["shadow_#{i}"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/shadow2")
      end
      @sprites["shadow_#{i}"].opacity = 0
    end
    
    @sprites["ball_1"] = IconSprite.new(152, 188, @viewport)
    @sprites["ball_2"] = IconSprite.new(306, 188, @viewport)
    @sprites["ball_3"] = IconSprite.new(460, 188, @viewport)
    for i in 1..3
      @sprites["ball_#{i}"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/ball#{i}")
      @sprites["ball_#{i}"].ox = @sprites["ball_#{i}"].bitmap.width / 2
      @sprites["ball_#{i}"].oy = @sprites["ball_#{i}"].bitmap.height / 2
      @sprites["ball_#{i}"].opacity = 0
    end
    
    @sprites["hlight_1"] = IconSprite.new(118, 154, @viewport)
    @sprites["hlight_2"] = IconSprite.new(272, 154, @viewport)
    @sprites["hlight_3"] = IconSprite.new(426, 154, @viewport)
    for i in 1..3
      @sprites["hlight_#{i}"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/highlight")
      @sprites["hlight_#{i}"].opacity = 0
    end
    
    @sprites["select"] = IconSprite.new(200,188,@viewport) # Outline selection
    @sprites["select"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/sel")
    @sprites["select"].ox = @sprites["select"].bitmap.width / 2
    @sprites["select"].oy = @sprites["select"].bitmap.height / 2
    @sprites["select"].visible = false
    @sprites["select"].opacity = 0
    @sprites["selection"] = IconSprite.new(264,32,@viewport) # Hand selection
    @sprites["selection"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/select")
    @sprites["selection"].visible = false
    
    @sprites["type1"] = IconSprite.new(0, 0, @viewport)    
    @sprites["type1"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/typegradient")
    @sprites["type1"].opacity = 0
    @sprites["type2"] = IconSprite.new(0, 0, @viewport)    
    @sprites["type2"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/typegradient")
    @sprites["type2"].mirror = true
    @sprites["type2"].opacity = 0
    
    @sprites["ballbase"] = IconSprite.new(50, 0, @viewport)
    @sprites["ballbase"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/ballbase")
    if StarterSelSettings::STARTERCZ >= 1
      @sprites["ballbase"].setBitmap("Graphics/UI/DiegoWT's Starter Selection/ballbase2x")
      @sprites["ballbase"].zoom_x = 0.5
      @sprites["ballbase"].zoom_y = 0.5
    end
    @sprites["ballbase"].ox = @sprites["ballbase"].bitmap.width / 2
    @sprites["ballbase"].oy = @sprites["ballbase"].bitmap.height / 2
    @sprites["ballbase"].opacity = 0
    
    @data = {}
    @data["pkmn_1"] = Pokemon.new(@pkmn1,StarterSelSettings::STARTERL)
    @data["pkmn_1"].form = StarterSelSettings::STARTER1FORM
    if StarterSelSettings::STARTER1IV == 1
      @data["pkmn_1"].iv[:HP]              = 31
      @data["pkmn_1"].iv[:ATTACK]          = 31
      @data["pkmn_1"].iv[:DEFENSE]         = 31
      @data["pkmn_1"].iv[:SPECIAL_ATTACK]  = 31
      @data["pkmn_1"].iv[:SPECIAL_DEFENSE] = 31
      @data["pkmn_1"].iv[:SPEED]           = 31
    end
    if StarterSelSettings::STARTER1SHINY != 0
      @data["pkmn_1"].shiny = false if StarterSelSettings::STARTER1SHINY == 1
      @data["pkmn_1"].shiny = true if StarterSelSettings::STARTER1SHINY == 2
    end
    @data["pkmn_2"] = Pokemon.new(@pkmn2,StarterSelSettings::STARTERL)
    @data["pkmn_2"].form = StarterSelSettings::STARTER2FORM
    if StarterSelSettings::STARTER2IV == 1
      @data["pkmn_2"].iv[:HP]              = 31
      @data["pkmn_2"].iv[:ATTACK]          = 31
      @data["pkmn_2"].iv[:DEFENSE]         = 31
      @data["pkmn_2"].iv[:SPECIAL_ATTACK]  = 31
      @data["pkmn_2"].iv[:SPECIAL_DEFENSE] = 31
      @data["pkmn_2"].iv[:SPEED]           = 31
    end
    if StarterSelSettings::STARTER2SHINY != 0
      @data["pkmn_2"].shiny = false if StarterSelSettings::STARTER2SHINY == 1
      @data["pkmn_2"].shiny = true if StarterSelSettings::STARTER2SHINY == 2
    end
    @data["pkmn_3"] = Pokemon.new(@pkmn3,StarterSelSettings::STARTERL)
    @data["pkmn_3"].form = StarterSelSettings::STARTER3FORM
    if StarterSelSettings::STARTER3IV == 1
      @data["pkmn_3"].iv[:HP]              = 31
      @data["pkmn_3"].iv[:ATTACK]          = 31
      @data["pkmn_3"].iv[:DEFENSE]         = 31
      @data["pkmn_3"].iv[:SPECIAL_ATTACK]  = 31
      @data["pkmn_3"].iv[:SPECIAL_DEFENSE] = 31
      @data["pkmn_3"].iv[:SPEED]           = 31
    end
    if StarterSelSettings::STARTER3SHINY != 0
      @data["pkmn_3"].shiny = false if StarterSelSettings::STARTER3SHINY == 1
      @data["pkmn_3"].shiny = true if StarterSelSettings::STARTER3SHINY == 2
    end
    
    for i in 1..3
      @sprites["pkmn_#{i}"] = PokemonSprite.new(@viewport)
      @sprites["pkmn_#{i}"].setOffset(PictureOrigin::CENTER)
      @pokemon = @data["pkmn_#{i}"]
      @data.values.each { |pkmn| 
        if pkmn.form != 0
          pkmn.calc_stats
          pkmn.refresh
        end
      }
      @sprites["pkmn_#{i}"].setPokemonBitmap(@data["pkmn_#{i}"], @data["pkmn_#{i}"].shiny, false, 0)
      @sprites["pkmn_#{i}"].x = @sprites["ball_#{i}"].x
      @sprites["pkmn_#{i}"].y = @sprites["ball_#{i}"].y - 32
    end
    pbInitMessageWindow
    @sprites["message_window"].x = 0
    @sprites["message_window"].y = Graphics.height - @sprites["message_window"].height
    @sprites["message_window"].viewport = @viewport
  end

  def pbOpenScene
    @sprites["base"].opacity = 255
    for i in 1..3
      @sprites["shadow_#{i}"].opacity = 255
      @sprites["ball_#{i}"].opacity = 255
      @sprites["pkmn_#{i}"].opacity = 255
      @sprites["ballbase"].opacity = 255
      @sprites["hlight_#{i}"].opacity = 255
    end
    pbMessageDisplay(_INTL("Choose your Pokémon!"), 0)
    pbUpdate
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        break
      elsif Input.trigger?(Input::C)
        if @endscene == 0
          @endscene = 1
          break
        end
      end
    end
    pbFadeOutAndHide
  end
  
  def pbUpdate
    # Update sprites and animations
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbFadeOutAndHide
    @sprites.each_value do |sprite|
      sprite.visible = false
    end
    @viewport.dispose
  end
end
