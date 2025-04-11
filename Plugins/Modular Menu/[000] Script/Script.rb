#===============================================================================
#  Modular Pause Menu
#    by Luka S.J.
# ----------------
#  Provides only features present in the default version of the Pokedex in
#  Essentials. Mean as a new cosmetic overhaul, adhering to the UI design
#  language of EBS
#-------------------------------------------------------------------------------
#  Main module for handling each menu item/entry
#===============================================================================
module ModularMenu
  # hash used to store the elements inside of the menu
  @@menuEntry = {}
  # hash used to store whether or not an element is unlocked
  @@available = {}
  # hash used to store the index of each element; for sorting
  @@indexes = {}
  @@index = 0
  #-----------------------------------------------------------------------------
  # function to add a new element/entry to the menu
  #-----------------------------------------------------------------------------
  def self.add_entry(ref, name, icon, &block)
    raise "No function code block defined for Modular Menu entry: #{name}." if block.nil?
    @@menuEntry[ref] = [name, icon, block]
    @@available[ref] = true if !@@available.keys.include?(ref)
    @@indexes[ref] = @@index
    @@index += 1
  end
  #-----------------------------------------------------------------------------
  # function to add a conditional for an existing entry
  #-----------------------------------------------------------------------------
  def self.add_condition(ref, &block)
    raise "No condition code block defined for Modular Menu entry: #{name}." if block.nil?
    @@available[ref] = block
  end
  #-----------------------------------------------------------------------------
  # function to get the name of an element/entry
  #-----------------------------------------------------------------------------
  def self.name(ref)
    return @@menuEntry[ref][0]
  end
  #-----------------------------------------------------------------------------
  # function to get the icon of an element/entry
  #-----------------------------------------------------------------------------
  def self.icon(ref)
    return "Graphics/Icons/#{@@menuEntry[ref][1]}"
  end
  #-----------------------------------------------------------------------------
  # function to get all the possible keys from the main hash
  #-----------------------------------------------------------------------------
  def self.keys
    entries = Array.new(@@menuEntry.keys.length)
    for key in @@menuEntry.keys
      entries[@@indexes[key]] = key
    end
    return entries
  end
  #-----------------------------------------------------------------------------
  # function used to invoke the stored code for each element/entry
  #-----------------------------------------------------------------------------
  def self.run(ref, scene)
    @@menuEntry[ref][2].call(scene)
  end
  #-----------------------------------------------------------------------------
  # function to check if the player has access to an element/entry
  #-----------------------------------------------------------------------------
  def self.available?(ref)
    return @@available[ref].is_a?(Proc) ? @@available[ref].call : @@available[ref]
  end
  #-----------------------------------------------------------------------------
  # function that lists all accessible menu elements/entries
  #-----------------------------------------------------------------------------
  def self.elements?
    ent = self.keys
    items = 0
    for val in ent
      items += 1 if self.available?(val)
    end
    return items
  end
  #-----------------------------------------------------------------------------
end
#-------------------------------------------------------------------------------
#  Main class used to handle the visuals
#-------------------------------------------------------------------------------
class PokemonPauseMenu_Scene
  attr_accessor :index
  attr_accessor :entries
  attr_accessor :endscene
  attr_accessor :close
  attr_accessor :hidden
  #-----------------------------------------------------------------------------
  # retained for compatibility
  #-----------------------------------------------------------------------------
  def pbShowInfo(text)
    @sprites["helpwindow"].resizeToFit(text, Graphics.height)
    @sprites["helpwindow"].text = text
    @sprites["helpwindow"].visible = true
    @helpstate = true
    pbBottomLeft(@sprites["helpwindow"])
  end
  #-----------------------------------------------------------------------------
  # retained for compatibility
  #-----------------------------------------------------------------------------
  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text, Graphics.height)
    @sprites["helpwindow"].text = text
    @sprites["helpwindow"].visible = true
    @helpstate = true
    pbBottomLeft(@sprites["helpwindow"])
  end
  #-----------------------------------------------------------------------------
  # main scene generation
  #-----------------------------------------------------------------------------
  def pbStartScene
    # sets the default index
    @index = $game_temp.pbGetLastChoice.nil? ? 0 : $game_temp.menuLastChoice

    @index = 0 if @index >= ModularMenu.elements?
    @oldindex = 0
    @endscene = true
    @close = false
    @hidden = false
    # loads the visual parts of the
    @viewport = Viewport.new(0,0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    # initializes the background graphic
    @bitmap = Graphics.snap_to_bitmap if !@bitmap
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = @bitmap
    @sprites["background"].blur_sprite(3)
    @sprites["background"].bitmap.blt(0, 8, pbBitmap("Graphics/Pictures/PauseMenu/bg"),Rect.new(0, 0, Graphics.width, Graphics.height))
    bmp = pbBitmap("Graphics/Pictures/Common/scrollbar_bg")
    @sprites["background"].bitmap.blt(Graphics.width - 28, (Graphics.height - bmp.height)/2, bmp, Rect.new(0, 0, bmp.width, bmp.height))
	
	#sprite menú
@sprites["sprite_menu"]=IconSprite.new(0,0,@viewport)
    if $game_variables[42] == 1
    @sprites["sprite_menu"].setBitmap("Graphics/Pictures/MenuChico")
end
    if $game_variables[42] == 2
    @sprites["sprite_menu"].setBitmap("Graphics/Pictures/MenuChica")

end


	#sprite menú
@sprites["medalla_menu"]=IconSprite.new(0,0,@viewport)
    if $game_switches[4]
    @sprites["medalla_menu"].setBitmap("Graphics/Pictures/medalla1")
end
    if $game_switches[5]
    @sprites["medalla_menu"].setBitmap("Graphics/Pictures/medalla2")
end
	#sprite menú
@sprites["medalla_menu"]=IconSprite.new(0,0,@viewport)
    if $game_switches[6]
    @sprites["medalla_menu"].setBitmap("Graphics/Pictures/medalla3")
end
    if $game_switches[7]
    @sprites["medalla_menu"].setBitmap("Graphics/Pictures/medalla4")
end

	
    # initializes the scrolling panorama
    @sprites["panorama"] = ScrollingSprite.new(@viewport)
    @sprites["panorama"].setBitmap("Graphics/Pictures/Common/panorama")
    @sprites["panorama"].speed = 1
    # retained for compatibility
    @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["helpwindow"].visible = false
    # draw the contest crap
    @sprites["textOverlay"] = Sprite.new(@viewport)
    @sprites["textOverlay"].bitmap = Bitmap.new(@viewport.rect.width, @viewport.rect.height)
    @sprites["textOverlay"].end_x = 0
    @sprites["textOverlay"].x = -@viewport.rect.width
    pbSetSystemFont(@sprites["textOverlay"].bitmap)
    bmp = pbBitmap("Graphics/Pictures/Common/partyBar")
    content = []
    text = []
	
	
			#nombre
    if $game_variables[54] == 1
    text.push([_INTL("#{$player.name}"),42,30,0,Color.new(255,255,255),Color.new(0,0,0,100),true])
end

    #dinero
	 if $game_variables[56] == 1
	text.push([_INTL("$ #{$player.money}"),18,88,0,Color.new(255,255,255),Color.new(0,0,0,100),true])
	end

    if $game_variables[26] < 10
      text.push([_INTL("#{ $game_variables[26] }"), 76, 390, 0, Color.new(255, 255, 255), Color.new(0, 0, 0, 100), true])
    elsif $game_variables[26] < 100
      text.push([_INTL("#{ $game_variables[26] }"), 73, 390, 0, Color.new(255, 255, 255), Color.new(0, 0, 0, 100), true])
    else
      text.push([_INTL("#{ $game_variables[26] }"), 68, 390, 0, Color.new(255, 255, 255), Color.new(0, 0, 0, 100), true])
    end

    if pbInSafari?
      content.push(_INTL("Steps: {1}/{2}", pbSafariState.steps, Settings::SAFARI_STEPS)) if Settings::SAFARI_STEPS > 0
      content.push(_INTL("Balls: {1}", pbSafariState.ballcount))
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        content.push(_INTL("Caught: {1}", PBSpecies.getName(pbBugContestState.lastPokemon.species)))
        content.push(_INTL("Level: {1}", pbBugContestState.lastPokemon.level))
        content.push(_INTL("Balls: {1}", pbBugContestState.ballcount))
      else
        content.push("Caught: none")
      end
      content.push(_INTL("Balls: {1}", pbBugContestState.ballcount))
    end
    for i in 0...content.length
      text.push([content[i], 16, 54 + i*50, 0, Color.new(255, 255, 255), Color.new(0, 0, 0, 65)])
      @sprites["textOverlay"].bitmap.blt(-2, 92 + i*50, bmp, Rect.new(0, 0, bmp.width, bmp.height))
    end
    pbDrawTextPositions(@sprites["textOverlay"].bitmap, text)
    # initializes the scroll bar
    @sprites["scroll"] = Sprite.new(@viewport)
    # rendering elements on screen
    self.refresh
    self.update
    # memorizes the target opacities and sets them to 0
    @opacities = {}
    for key in @sprites.keys
      @opacities[key] = @sprites[key].opacity
      @sprites[key].opacity = 0
    end
    $game_temp.menuLastChoice = @index
  end
  #-----------------------------------------------------------------------------
  # hide menu
  #-----------------------------------------------------------------------------
  def pbHideMenu
    # animations for closing the menu
    @sprites["textOverlay"].end_x = -@viewport.rect.width
    8.times do
      for key in @sprites.keys
        next if !@sprites[key] || @sprites[key].disposed?
        @sprites[key].opacity -= 32
      end
      @sprites["textOverlay"].x += (@sprites["textOverlay"].end_x - @sprites["textOverlay"].x)*0.2
      Graphics.update
    end
  end
  #-----------------------------------------------------------------------------
  # show menu
  #-----------------------------------------------------------------------------
  def pbShowMenu
    # animations for opening the menu
    @sprites["textOverlay"].end_x = 0
    8.times do
      for key in @sprites.keys
        next if !@sprites[key] || @sprites[key].disposed?
        @sprites[key].opacity += 32 if @sprites[key].opacity < @opacities[key]
      end
      @sprites["textOverlay"].x += (@sprites["textOverlay"].end_x - @sprites["textOverlay"].x)*0.4
      Graphics.update
    end
  end
  #-----------------------------------------------------------------------------
  # refresh content
  #-----------------------------------------------------------------------------
  def refresh
    # index safety
    @index = ModularMenu.elements? - 1 if @index >= ModularMenu.elements?
    @oldindex = @index
    # disposes old items in the menu
    if @entries
      for i in 0...@entries.length
        @sprites["#{i}"].dispose if @sprites["#{i}"]
      end
    end
    # creates a new list of available items
    @entries = []
    for val in ModularMenu.keys
      @entries.push(val) if ModularMenu.available?(val)
    end
    # draws individual item entries
    bmp = pbBitmap("Graphics/Pictures/PauseMenu/sel")
    for i in 0...@entries.length
      key = @entries[i]
      @sprites["#{i}"] = Sprite.new(@viewport)
      @sprites["#{i}"].bitmap = Bitmap.new(bmp.width, bmp.height)
      pbSetSystemFont(@sprites["#{i}"].bitmap)
      @sprites["#{i}"].src_rect.set(0, 0, bmp.width/2, bmp.height)
      @sprites["#{i}"].bitmap.blt(0, 0, bmp, Rect.new(0, 0, bmp.width, bmp.height))
      for j in 0...2
        opac = j == 0 ? 155 : 255
        icon = pbBitmap(ModularMenu.icon(key))
        text = ModularMenu.name(key)
        text.gsub!("\\PN", "#{$player.name}")
        text.gsub!("\\CONTEST", pbInSafari? ? "Quit" : "Quit Contest")
        @sprites["#{i}"].bitmap.blt(27 + j*bmp.width/2, 6, icon, Rect.new(0, 0, 48, 48), opac)
        pbDrawOutlineText(@sprites["#{i}"].bitmap, 66 + j*bmp.width/2, 18, 136, 48, text, Color.new(255, 255, 255), Color.new(64, 64, 64), 1)
      end
      @sprites["#{i}"].x = Graphics.width - bmp.width/2 - 52
      @sprites["#{i}"].y = 49 + (bmp.height + 12)*i
      @sprites["#{i}"].opacity = 128
    end
    # configures the scroll bar
    n = (@entries.length < 4 ? 1 : @entries.length - 3)
    height = 204/n
    height += 204 - (height*n)
    height += 16
    @sprites["scroll"].bitmap = Bitmap.new(16, height)
    bmp = pbBitmap("Graphics/Pictures/Common/scrollbar_kn")
    @sprites["scroll"].bitmap.blt(0, 0, bmp, Rect.new(0, 0, 16, 6))
    @sprites["scroll"].bitmap.stretch_blt(Rect.new(0, 6, 16, height-14), bmp, Rect.new(0, 6, 16, 1))
    @sprites["scroll"].bitmap.blt(0, height-8, bmp, Rect.new(0, 8, 16, 8))
    @sprites["scroll"].x = Graphics.width - 32
    @sprites["scroll"].y = (Graphics.height - 204)/2
    @sprites["scroll"].end_y = (Graphics.height - 204)/2
  end
  #-----------------------------------------------------------------------------
  # menu update function
  #-----------------------------------------------------------------------------
  def update
    # scrolling background image
    @sprites["panorama"].update
    # calculations for updating the scrollbar position
    k = (@entries.length < 4 ? 0 : @index - 3)
    k = 0 if k < 0
    n = (@entries.length < 4 ? 1 : @entries.length - 3)
    height = 204/n
    @sprites["scroll"].end_y = (Graphics.height - 204)/2 + height*k
    @sprites["scroll"].y += (@sprites["scroll"].end_y - @sprites["scroll"].y)*0.2
    # updates for each element/entry in the menu
    for i in 0...@entries.length
      j = @entries.length < 4 ? 0 : (@index - 3)
      j = 0 if j < 0
      y = (-j)*(@sprites["#{i}"].src_rect.height + 12) + 49 + i*(@sprites["#{i}"].src_rect.height + 12)
      @sprites["#{i}"].y -= (@sprites["#{i}"].y - y)*0.1
      @sprites["#{i}"].src_rect.x = @sprites["#{i}"].src_rect.width*(@index == i ? 1 : 0)
      @sprites["#{i}"].x += 2 if @sprites["#{i}"].x < Graphics.width - @sprites["#{i}"].src_rect.width - 52
      if i.between?(j,j+3)
        @sprites["#{i}"].opacity += 15 if @sprites["#{i}"].opacity < 255
      else
        @sprites["#{i}"].opacity -= 15 if @sprites["#{i}"].opacity > 128
      end
      if @index == i
        @sprites["#{i}"].tone.gray -= 51 if @sprites["#{i}"].tone.gray > 0
      else
        @sprites["#{i}"].tone.gray += 51 if @sprites["#{i}"].tone.gray < 255
      end
    end
    # sets the index
    if @oldindex != @index
      @sprites["#{@index}"].x -= 6
      @oldindex = @index
    end
  end
  #-----------------------------------------------------------------------------
  # close out of the menu scene
  #-----------------------------------------------------------------------------
  def pbEndScene
    # disposes the sprite hash
    pbSEPlay("GUI menu close")
    pbHideMenu
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  #-----------------------------------------------------------------------------
  def pbRefresh; end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Main class used to handle the logic of the pause menu
#===============================================================================
class PokemonPauseMenu
  #-----------------------------------------------------------------------------
  # constructor
  #-----------------------------------------------------------------------------
  def initialize(scene)
    @scene = scene
  end
  #-----------------------------------------------------------------------------
  # show scene
  #-----------------------------------------------------------------------------
  def pbShowMenu
    @scene.pbShowMenu
  end

  def hide
    @visible = false
    # Logic to hide the menu visually
    # For example, you might need to adjust graphics or flags to stop drawing it
  end
  #-----------------------------------------------------------------------------
  # start menu
  #-----------------------------------------------------------------------------
  def pbStartPokemonMenu
    event_in_progress = true
    pbSEPlay("GUI menu open")
    @scene.pbStartScene
    @scene.pbShowMenu
    loop do
      # main loop
      Graphics.update
      Input.update
      @scene.update
    
      if Input.repeat?(Input::DOWN)
        @scene.index += 1
        @scene.index = 0 if @scene.index > @scene.entries.length - 1
        $game_temp.menuLastChoice = @scene.index
        pbSEPlay("SE_Select1", 75)
      elsif Input.repeat?(Input::UP)
        @scene.index -= 1
        @scene.index = @scene.entries.length - 1 if @scene.index < 0
        $game_temp.menuLastChoice = @scene.index
        pbSEPlay("SE_Select1", 75)
      
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE()
        ModularMenu.run(@scene.entries[@scene.index], @scene)
  
      elsif Input.trigger?(Input::A)
        pbPlayDecisionSE()
      
        # Variable para pausar la condición de escape o cierre
        event_in_progress = false
      
        # Comprobar el valor de la variable 28 (curaciones disponibles)
        if $game_variables[28] > 0
          msg_window = pbCreateMessageWindow # Crear la ventana de mensaje
      
          # Verificar singular o plural
          if $game_variables[28] == 1
            pbMessageDisplay(msg_window, _INTL("Tienes #{$game_variables[28]} curación disponible. ¿Quieres utilizar el Vial en tus Pokémon?"))
          else
            pbMessageDisplay(msg_window, _INTL("Tienes #{$game_variables[28]} curaciones disponibles. ¿Quieres utilizar el Vial en tus Pokémon?"))
          end
      
          # Preguntar si desea curar
          choices = [_INTL("Sí"), _INTL("No")]
          choice = pbShowCommands(msg_window, choices)
      
          if choice == 0  # Si el jugador elige "Sí"
            # Curar al equipo Pokémon
            $player.party.each do |pkmn|
              if pkmn && !pkmn.egg?
                pkmn.heal
              end
            end
      
            pbMessageDisplay(msg_window, _INTL("Todo tu equipo Pokémon ha sido curado."))
      
            # Restar una unidad de la variable 28 para gastar una curación
            $game_variables[28] -= 1
      
          else  # Si el jugador elige "No"
            pbMessageDisplay(msg_window, _INTL("No has curado a tu equipo Pokémon."))
          end
      
        else
          msg_window = pbCreateMessageWindow # Crear la ventana de mensaje
          pbMessageDisplay(msg_window, _INTL("No tienes curaciones disponibles."))
        end
      
        # Mantener la ventana de mensaje abierta hasta que se presione Input::C o Input::B
        loop do
          Graphics.update
          Input.update
  
          # Consumir el input de B o C para solo cerrar el mensaje y no afectar el menú principal
          if Input.trigger?(Input::C) || Input.trigger?(Input::B)
            break  # Salir del bucle de curación
          end
        end
  
        pbDisposeMessageWindow(msg_window) # Cerrar y eliminar la ventana de mensaje
        
        # Aquí hacemos una actualización extra de Input para que el botón B no afecte el menú principal
        Input.update
        event_in_progress = true # Volvemos al flujo del menú principal
      
      elsif  Input.trigger?(Input::Y)
        pbPlayDecisionSE()
       # Comprobar si se puede usar vuelo
        if pbCanFly?(pkmn = nil, true) # Llama al método para comprobar si se puede volar
          scene = PokemonRegionMap_Scene.new(-1, false) # Crear una nueva escena del mapa de vuelo
          screen = PokemonRegionMapScreen.new(scene) # Crear una nueva pantalla de vuelo
          ret = screen.pbStartFlyScreen # Iniciar la pantalla de selección de vuelo
          
          if ret
            @scene.pbHideMenu # Ocultar todo el menú
            $game_temp.fly_destination = ret # Guardar el destino de vuelo seleccionado
            pbFlyToNewLocation(pkmn = nil, move = :FLY)
            break
          end
        end
 
        
      end
     
      if event_in_progress
        break if @scene.close || Input.trigger?(Input::B)
      end
      
    end
    # used to dispose of the scene
    @scene.pbEndScene if @scene.endscene
  end
  
  
  #-----------------------------------------------------------------------------
end

class Game_Temp
  attr_accessor :menuLastChoice

  def pbGetLastChoice
    return @menuLastChoice
  end  

  def menuLastChoice=(value)
    @menuLastChoice = value
  end
end