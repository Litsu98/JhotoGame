class PartyPicture
  # To create a new one just add a new element to this array, the first one will
  # be its name, the second one will be the tone effect applied.
  # example: ["Blue", Tone.new(0, 0, 255, 0)]
  # Don't forget the commas. The last element should not have a comma!
  FILTERS = [
  ["Pink", Tone.new(80, 10, 75, 0)],
  ["Sepia", Tone.new(0, 0, -85, 100)],
  ["B&W", Tone.new(-20, -20, -20, 255)],
  ["Bright", Tone.new(60, 60, 60, 0)],
  ["Dark", Tone.new(-60, -60, -60, 40)]
  ]
  
  # To create a new one just add a new element to this array, the first one will
  # be its name, the second one will be the file name. You should store your
  # overlays inside the Graphics/Pictures folder!
  # Don't forget the comma. The last element should not have a comma!
  OVERLAYS = [
  ["Pretty Pink", "Pretty Pink Overlay"],
  ["Pretty Blue", "Pretty Blue Overlay"],
  ["Sparkles", "Sparkles Overlay"],
  ["Polaroid", "Polaroid Overlay"],
  ["Vignette", "Vignette Overlay"]
  ]
  
  def initialize(ev1, ev2, ev3, ev4, ev5, ev6)
    # Checks if the map has Snap Edges on, if so, locks the camera movement.
    isSnapEdges = GameData::MapMetadata.try_get($game_map.map_id).snap_edges
    @can_move_camera = (isSnapEdges ? false : true)

    # Gets the names and effects of filters and overlays defined previously
    @filters_names   = FILTERS.map { |filter| filter[0] }
    @filters_effects = FILTERS.map { |filter| filter[1] }
    @overlays_names  = OVERLAYS.map { |overlay| overlay[0] }
    @overlays_images = OVERLAYS.map { |overlay| overlay[1] }
    
    # Starts a lot of the sprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sprites = {}
    @sprites["filter_overlay"] = Sprite.new(@viewport)
    @sprites["filter_overlay"].visible = false
    @sprites["filter_overlay"].bitmap = Bitmap.new("Graphics/Party Pictures/Polaroid Overlay")
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].visible = false
    @sprites["overlay"].bitmap = Bitmap.new("Graphics/Party Pictures/Camera Overlay.png")
    
    #Starts the scene
    pbStartPictureScene(ev1, ev2, ev3, ev4, ev5, ev6)
    
    # Starts the commands such as movement, buttons being pressed...
    main
  end
  
  def main
    # defines some variables
    currentY = 0
    currentX = 0
    maxY = 2
    minY = -2
    maxX = 2
    minX = -2
    @picture_taken = false
    loop do
      pbUpdateSceneMap
      Graphics.update
      Input.update
      if Input.press?(Input::UP) && @can_move_camera
        if currentY == maxY
          pbSEPlay("Player bump")
          pbWait(0.25)
        else
          pbScrollMap(8,1)
          currentY += 1
        end
      elsif Input.press?(Input::DOWN) && @can_move_camera
        if currentY == minY
          pbSEPlay("Player bump")
          pbWait(0.25)
        else
          pbScrollMap(2,1)
          currentY -= 1
        end
      elsif Input.press?(Input::RIGHT) && @can_move_camera
        if currentX == maxX
          pbSEPlay("Player bump")
          pbWait(0.25)
        else
          pbScrollMap(6,1)
          currentX += 1
        end
      elsif Input.press?(Input::LEFT) && @can_move_camera
        if currentX == minX
          pbSEPlay("Player bump")
          pbWait(0.25)
        else
          pbScrollMap(4,1)
          currentX -= 1
        end
      elsif Input.trigger?(Input::ACTION)
        # Displays a choice message if you want to take a picture or not
        choice = pbMessage("¿Quieres tomar una foto?", [
          _INTL("Si"),
          _INTL("No")
        ])
        
        if choice == 0 #if Yes
          pbTakePicture
        else # if No
          pbMessage("Ok!")
        end
      elsif Input.trigger?(Input::USE)
        choice = pbMessage("¿Quieres usar algunos filtros o superposiciones?", [
          _INTL("Filtros"),
          _INTL("Overlays"),
          _INTL("No")
        ])
        if choice == 0
          filter_choice = pbMessage("¿Qué filtro quieres?",
            @filters_names + [_INTL("Normal"), _INTL("No importa")
          ])
          if filter_choice != FILTERS.size + 1
            if filter_choice != FILTERS.size
              pbToneChangeAll(@filters_effects[filter_choice], 4)
            else
              pbToneChangeAll(Tone.new(0, 0, 0, 0), 4)
            end
          end
        elsif choice == 1
          overlay_choice = pbMessage("¿Qué superposición quieres?", 
            @overlays_names + [_INTL("Ninguno"), _INTL("No importa")
          ])
          if overlay_choice != OVERLAYS.size + 1
            if overlay_choice != OVERLAYS.size
              @sprites["filter_overlay"].bitmap = Bitmap.new("Graphics/Party Pictures/" + @overlays_images[overlay_choice])
              @sprites["filter_overlay"].visible = true
            else
              @sprites["filter_overlay"].visible = false
            end
            pbSEPlay("GUI naming tab swap start")
          end        
        end
      elsif Input.trigger?(Input::BACK)
        # Displays a choice message if you want to stop or not
        choice = pbMessage("¿Quieres Salir", [
          _INTL("Si"),
          _INTL("No")
        ])
        if choice == 0 # if yes
          pbMessage("Ok!")
          pbEndPictureScene
        end
      end
      break if @picture_taken
    end
  end
  
  def pbTakePicture
    # Picture taken effects
    @sprites["overlay"].visible = false
    pbSEPlay("Battle catch click")
    pbFlash(Color.new(255, 255, 255, 255), 10)
    pbWait(11.0/20)
    
    # Gets the map name
    map_name = $game_map.name
    # Specify the folder path where you want to save the images
    folder_path = "Screenshots/"
    exporter_filename = "#{map_name}_Picture.png"
    create_folder_if_not_exist(folder_path)
    # Checks if an image of the same name already exists, if so adds a (x) to its name
    counter = 0
    while File.exist?(folder_path + exporter_filename)
      counter += 1
      exporter_filename = "#{map_name}_Picture(#{counter}).png"
    end
    # Take a screenshot and save it
    bmp = Graphics.snap_to_bitmap
    bmp.save_to_png(folder_path + exporter_filename)
    bmp.dispose
    @sprites["overlay"].visible = true
    pbWait(6.0/20)
    pbEndPictureScene
  end
  
  def pbStartPictureScene(ev1, ev2, ev3, ev4, ev5, ev6)
    # Fades the screen and runs the code
    pbFadeOutIn do
      # Loop through the Player Party to change event's character sprites
      # Stores the events sprites and then make every event in the map invisible
      $game_map.store_event_character_names
      $game_map.clear_event_character_names
      party = $player.party
      party.each_with_index do |pkmn, i|
        shiny = pkmn.shiny?
        ev_id = eval("ev#{i+1}")
        next unless ev_id
        file = GameData::Species.ow_sprite_filename(pkmn.species, pkmn.form, pkmn.gender, shiny, pkmn.shadow)
        file.gsub!("Graphics/Characters/", "")
        $game_map.events[ev_id].character_name = file
        pbMoveRoute($game_map.events[ev_id], [PBMoveRoute::STEP_ANIME_ON], false)
      end
      
      # Toggles Following Pokémon if it's currently active
      if FollowingPkmn.active?
        @toggle = true
        FollowingPkmn.toggle_off
      else
        @toggle = false
      end
      
      # Forces the player to face down
      $game_player.direction = 2
      # Turns on the Camera Overlay Guide
      @sprites["overlay"].visible = true
      # Refreshes the map before Fading In
      $game_map.need_refresh = true
      pbWait(0.5)
      $scene.miniupdate
      pbWait(0.5)
    end
  end
  
  def pbEndPictureScene
    pbFadeOutIn do
      # Returns the camera back to the player in case it's not currently there
      pbScrollMapToPlayer if @can_move_camera
      # Restore all events previously made invisible
      $game_map.restore_event_character_names
      # Make all events characters invisible again
      (1..6).each do |i|
        $game_map.events[i].character_name = '' if $game_map.events[i] # Reset character name to make it invisible
        pbMoveRoute($game_map.events[i], [PBMoveRoute::STEP_ANIME_OFF], false)
      end
          
      # Returns Following Pokémon in case it was active before
      if @toggle
        FollowingPkmn.toggle_on
      end
      
      # Removes any active filters
      pbToneChangeAll(Tone.new(0, 0, 0, 0), 4)
      # Disposes all sprites and viewports
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      # Refreshes the map before fading in
      $game_map.need_refresh = true
      pbWait(0.5)
      $scene.miniupdate
      @picture_taken = true # breaks the loop
    end
  end

  def create_folder_if_not_exist(folder_path)
    # Check if the folder already exists
    unless Dir.exist?(folder_path)
      # Create the folder if it doesn't exist
      Dir.mkdir(folder_path)
    end
  end  

  def pbUpdateSceneMap
    $scene.miniupdate if $scene.is_a?(Scene_Map) && !pbIsFaded?
  end
end

class Game_Map
  attr_accessor :event_character_names

  # Method to store all event character names
  def store_event_character_names
    @event_character_names = {}
    @events.each do |event_id, event|
      @event_character_names[event_id] = event.character_name
    end
  end

  # Method to set all event characters invisible
  def clear_event_character_names
    @events.each do |event_id, event|
      event.character_name = ""
    end
  end

  # Method to restore event character names
  def restore_event_character_names
    @event_character_names.each do |event_id, character_name|
      @events[event_id].character_name = character_name
    end
  end
end