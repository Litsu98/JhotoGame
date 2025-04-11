class QuestSystem
    QUESTS_FILE = "quests/quests.txt"  # Archivo de misiones fijo
  
    def self.load_quests
      quests = {}
      current_quest = nil
      
      File.foreach(QUESTS_FILE) do |line|
        line.strip!
        next if line.empty?  # Ignorar líneas vacías
        
        if line.match(/^\[(\d+)\]$/)  # Detectar nueva misión
          current_quest = $1.to_i
          quests[current_quest] = {}
        elsif current_quest
          key, value = line.split(":", 2).map(&:strip)  # Dividir clave y valor
          quests[current_quest][key] = value if key && value
        end
      end
      
      return quests
    end
  
    def self.get_quest(quest_number)
      quests = load_quests
      return quests[quest_number] if quests.key?(quest_number)
      return nil  # Si la misión no existe
    end
  
    def self.get_active_quests
      $game_variables[102] || []
    end
  
    def self.get_completed_quests
      $game_variables[103] || []
    end
  
    def self.save_active_quests
      $game_variables[102] = @active_quests
    end
  
    def self.save_completed_quests
      $game_variables[103] = @completed_quests
    end
  
    def self.load_active_quests
      $game_variables ||= []
      $game_variables[102] ||= []
      @active_quests = $game_variables[102]
    end
  
    def self.load_completed_quests
      $game_variables ||= []
      $game_variables[103] ||= []
      @completed_quests = $game_variables[103]
    end
  
    def self.reset_active_quests
      @active_quests = []
      save_active_quests
    end
  
    @active_quests = []
    @completed_quests = []
    load_active_quests
    load_completed_quests
  
    def self.activate_quest(quest_number)
      quest = get_quest(quest_number)
      if quest && !@active_quests.include?(quest_number) && !@completed_quests.include?(quest_number)
        @active_quests << quest_number
        save_active_quests
        pbMessage("Misión activada: #{quest["Nombre de la Misión"]}")
      else
        pbMessage("La misión ya está activada, completada o no existe.")
      end
    end
  
    def self.list_active_quests
      active_quests = get_active_quests
      if active_quests.empty?
        pbMessage("No tienes misiones activas.")
      else
        msg = "Misiones activas:\n"
        active_quests.each do |quest_number|
          quest = get_quest(quest_number)
          msg += "- #{quest["Nombre de la Misión"]}\n" if quest
        end
        pbMessage(msg)
      end
    end
  
    def self.list_completed_quests
      completed_quests = get_completed_quests
      if completed_quests.empty?
        pbMessage("No tienes misiones completadas.")
      else
        msg = "Misiones completadas:\n"
        completed_quests.each do |quest_number|
          quest = get_quest(quest_number)
          msg += "- #{quest["Nombre de la Misión"]}\n" if quest
        end
        pbMessage(msg)
      end
    end
  
    def self.complete_quest(quest_number)
      active_quests = get_active_quests  # Cargar las misiones activas
  
      if active_quests.include?(quest_number)  # Comprobar si la misión está activa
        quest = get_quest(quest_number)
        if quest
          # Mover la misión a la lista de misiones completadas
          @completed_quests << quest_number unless @completed_quests.include?(quest_number)
          save_completed_quests
          
          # Eliminarla de las misiones activas
          active_quests.delete(quest_number)
          #save_active_quests
  
          # Mensaje de éxito
          pbMessage("¡Misión completada: #{quest["Nombre de la Misión"]}!")
        else
          pbMessage("Misión no encontrada.")
        end
      else
        pbMessage("La misión no está activa o ya ha sido completada.")
      end
    end
  
    def self.has_completed_quest?(quest_number)
      get_completed_quests.include?(quest_number)
    end
  
    def self.show_quest(quest_number)
      quest = get_quest(quest_number)
      if quest
        pbMessage("Misión: #{quest["Nombre de la Misión"]}\n" +
                  "Descripción: #{quest["Descripcion de la Misión"]}\n" +
                  "Entrega: #{quest["Entrega de la misión"]}\n" +
                  "Recompensa: #{quest["Recompensa"]}")
      else
        pbMessage("Misión no encontrada.")
      end
    end
  end