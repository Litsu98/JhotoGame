class QuestMenu_Scene
    FONT_SIZE = 24
    FONT_COLOR = Color.new(255, 255, 255)
    HIGHLIGHT_COLOR = Color.new(255, 215, 0) # Amarillo dorado para resaltar la misión seleccionada
  
  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @show_details = true  # Estado para mostrar/ocultar la lista y detalles
  
    # Fondo del menú
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = Bitmap.new("Graphics/UI/quest/base.png")
    @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width) / 2
    @sprites["background"].y = (Graphics.height - @sprites["background"].bitmap.height) / 2
  
     # Título "Misiones" en la parte superior central
    @sprites["title"] = Sprite.new(@viewport)
    @sprites["title"].bitmap = Bitmap.new(Graphics.width, 50)
    @sprites["title"].bitmap.font.size = 32
    @sprites["title"].bitmap.draw_text(0, -5, Graphics.width, 50, "Misiones", 1)
    @sprites["title"].y = 10
    
    # Subtítulo "Completadas" más abajo con letra menor
    @sprites["completed"] = Sprite.new(@viewport)
    @sprites["completed"].bitmap = Bitmap.new(Graphics.width, 100)
    @sprites["completed"].bitmap.font.size = 16
    @sprites["completed"].bitmap.draw_text(-190, 18, Graphics.width, 30, "Pendientes", 1)
    @sprites["completed"].y = 60
    
      # Subtítulo "Completadas" más abajo con letra menor
    @sprites["pendientes"] = Sprite.new(@viewport)
    @sprites["pendientes"].bitmap = Bitmap.new(Graphics.width, 100)
    @sprites["pendientes"].bitmap.font.size = 16
    @sprites["pendientes"].bitmap.draw_text(-90, 18, Graphics.width, 30, "Completadas", 1)
    @sprites["pendientes"].y = 60
    
    # Sprite para mostrar la lista de misiones
    @sprites["questlist"] = Sprite.new(@viewport)
    @sprites["questlist"].bitmap = Bitmap.new(Graphics.width / 2, Graphics.height - 100)
    @sprites["questlist"].x = -50
    @sprites["questlist"].y = 120
    
      # Sprite para mostrar la lista de misiones
    @sprites["img"] = Sprite.new(@viewport)
    @sprites["img"].bitmap = Bitmap.new(Graphics.width / 2, Graphics.height - 100)
    @sprites["img"].x = 0
    @sprites["img"].y = 0

    # Sprite para mostrar la lista de misiones
    @sprites["img2"] = Sprite.new(@viewport)
    @sprites["img2"].bitmap = Bitmap.new(Graphics.width, Graphics.height - 100)
    @sprites["img2"].x = 390
    @sprites["img2"].y = 0
  
    # Texto de detalles de la misión seleccionada
    @sprites["detailtext"] = Sprite.new(@viewport)
    @sprites["detailtext"].bitmap = Bitmap.new(Graphics.width / 2, Graphics.height - 100)
    @sprites["detailtext"].x = (Graphics.width / 2) + 50
    @sprites["detailtext"].y = 50
  
    # Cargar las misiones activas
    @active_quests = QuestSystem.get_active_quests
    @quest_names = get_quest_names
    @selected_index = 0
    @scroll_offset = 0  # Desplazamiento de la lista
    @max_visible_items = 6  # Número máximo de misiones visibles a la vez
    
    if $game_variables[102] == 0
       #hide_details
      complete_quest_list  # Mostrar la lista completa de misiones
      pbShowQuestDetails(@selected_index)
     else
      #hide_details
      draw_quest_list  # Mostrar la lista normal de misiones
      pbShowQuestDetails(@selected_index)
    end
  end
  
  def hide_details
    return unless @show_details
    @show_details = false
    @sprites["questlist"].bitmap.clear
    @sprites["detailtext"].bitmap.clear
    @sprites["img"].bitmap.clear
    @sprites["img2"].bitmap.clear
  end
  
  def show_details
    return if @show_details
    @show_details = true
    draw_quest_list
    pbShowQuestDetails(@selected_index)
  end
  
  def get_quest_names
    return [] unless @active_quests.is_a?(Array) # Verificar que sea un array
    @active_quests.each_with_object([]) do |quest, names|
      quest_data = QuestSystem.get_quest(quest)
      next unless quest_data
      names << quest_data["Nombre de la Misión"]
    end
  end

  def filter_valid_quests
    return [] unless @active_quests.is_a?(Array)
    @active_quests = @active_quests.select { |quest_id| QuestSystem.get_quest(quest_id) }
  end

  
    
  def draw_quest_list
    # Ordena las misiones por su ID antes de procesarlas
    @active_quests = QuestSystem.get_active_quests.sort
    filter_valid_quests
    @quest_names = get_quest_names
    
    # Limpiar el bitmap
    @sprites["questlist"].bitmap.clear
    @sprites["img"].bitmap.clear
    @sprites["img2"].bitmap.clear
    font = @sprites["questlist"].bitmap.font
    font.size = FONT_SIZE
    y_offset = 0
    line_height = 32
    separation = 10  # Espacio entre las misiones
  
    # Asegúrate de que el bitmap tiene suficiente espacio para mostrar 300 px
    @sprites["questlist"].bitmap = Bitmap.new(600, Graphics.height - 100)
  
    # Cargar la imagen correctamente (asegúrate de que la imagen 'sel.png' sea más ancha ahora)
    sel_image = Bitmap.new("Graphics/UI/quest/sel.png")
  
    # Cargar la imagen del marcador
    marcador_image = Bitmap.new("Graphics/UI/quest/marcador.png")
  
    # Definir el desplazamiento horizontal para mover las misiones a la derecha
    horizontal_offset = 70  # Ajusta este valor para mover las misiones más a la derecha o izquierda
  
    # Mostrar solo las misiones dentro del rango de desplazamiento
    visible_quests = @quest_names[@scroll_offset, @max_visible_items] || []
  
    # Dibujar las misiones
    visible_quests.each_with_index do |name, index|
      # Dibujar la primera parte (300 px)
      @sprites["questlist"].bitmap.blt(horizontal_offset, y_offset, sel_image, Rect.new(0, 0, 300, sel_image.height))
    
      # Si la misión está seleccionada, dibujar la segunda parte (otros 300 px)
      if index == @selected_index
        @sprites["questlist"].bitmap.blt(horizontal_offset, y_offset, sel_image, Rect.new(300, 0, 300, sel_image.height))  # Parte derecha
      end
    
      # **Calcular la posición vertical para el texto**
      y_position = y_offset + (sel_image.height - line_height) / 2
    
      # **Obtener el ID de la misión y formatearlo con dos cifras**
      mission_id = @active_quests[@scroll_offset + index]  # ID real de la misión
      formatted_id = sprintf("%02d", mission_id)  # Siempre muestra dos cifras (Ej: 01, 02, ..., 10, 11)
  
      font.color = Color.new(255, 255, 0)  # Color amarillo para destacar el número
      @sprites["questlist"].bitmap.draw_text(118, y_position + 5, 40, line_height, formatted_id)  # Posición a la izquierda
    
      # Calcular la posición del texto centrado en 300 px
      text_width = @sprites["questlist"].bitmap.text_size(name).width
      x_position = (300 - text_width) / 2 + horizontal_offset  # Centrado horizontalmente y desplazado
    
      # Establecer el color y dibujar el texto centrado
      font.color = FONT_COLOR
      @sprites["questlist"].bitmap.draw_text(160, y_position + 5, 300, line_height, name)
    
      # Mover la posición para la siguiente misión
      y_offset += sel_image.height + separation
    end
  
      # **Agregar el marcador en la posición deseada**
      # Puedes mover la posición del marcador según lo necesites
      marcador_x = 83  # Ajusta la posición horizontal
      marcador_y = 80  # Ajusta la posición vertical
      @sprites["img"].bitmap.blt(marcador_x, marcador_y, marcador_image, marcador_image.rect)
    
    # Liberar la imagen después de usarla
      sel_image.dispose
      marcador_image.dispose

    # Si no hay misiones, limpiar detalles para evitar datos antiguos
    @sprites["detailtext"].bitmap.clear if @quest_names.empty?
  end
  
  
  
  def complete_quest_list
    # Ordena las misiones por su ID antes de procesarlas
    @active_quests = QuestSystem.get_completed_quests.sort
    filter_valid_quests
    @quest_names = get_quest_names
    
    # Limpiar el bitmap
    @sprites["questlist"].bitmap.clear
    @sprites["img"].bitmap.clear
    @sprites["img2"].bitmap.clear
    font = @sprites["questlist"].bitmap.font
    font.size = FONT_SIZE
    y_offset = 0
    line_height = 32
    separation = 10  # Espacio entre las misiones
    
    
    # Asegúrate de que el bitmap tiene suficiente espacio para mostrar 300 px
    @sprites["questlist"].bitmap = Bitmap.new(600, Graphics.height - 100)
  
    # Cargar la imagen correctamente (asegúrate de que la imagen 'sel.png' sea más ancha ahora)
    sel_image = Bitmap.new("Graphics/UI/quest/sel2.png")
    
    marcador_image = Bitmap.new("Graphics/UI/quest/marcador.png")
    marcador_image2 = Bitmap.new("Graphics/UI/quest/completada.png")
  
    # Definir el desplazamiento horizontal para mover las misiones a la derecha
    horizontal_offset = 70  # Ajusta este valor para mover las misiones más a la derecha o izquierda
  
    # Mostrar solo las misiones dentro del rango de desplazamiento
    visible_quests = @quest_names[@scroll_offset, @max_visible_items] || []

    visible_quests.each_with_index do |name, index|
      # Dibujar la primera parte (300 px)
      @sprites["questlist"].bitmap.blt(horizontal_offset, y_offset, sel_image, Rect.new(0, 0, 300, sel_image.height))
    
      # Si la misión está seleccionada, dibujar la segunda parte (otros 300 px)
      if index == @selected_index
        @sprites["questlist"].bitmap.blt(horizontal_offset, y_offset, sel_image, Rect.new(300, 0, 300, sel_image.height))  # Parte derecha
      end
    
      # **Calcular la posición vertical para el texto**
      y_position = y_offset + (sel_image.height - line_height) / 2
    
      # **Obtener el ID de la misión y formatearlo con dos cifras**
      mission_id = @active_quests[@scroll_offset + index]  # ID real de la misión
      formatted_id = sprintf("%02d", mission_id)  # Siempre muestra dos cifras (Ej: 01, 02, ..., 10, 11)
  
      font.color = Color.new(255, 255, 0)  # Color amarillo para destacar el número
      @sprites["questlist"].bitmap.draw_text(118, y_position + 5, 40, line_height, formatted_id)  # Posición a la izquierda
    
      # Calcular la posición del texto centrado en 300 px
      text_width = @sprites["questlist"].bitmap.text_size(name).width
      x_position = (300 - text_width) / 2 + horizontal_offset  # Centrado horizontalmente y desplazado
    
      # Establecer el color y dibujar el texto centrado
      font.color = FONT_COLOR
      @sprites["questlist"].bitmap.draw_text(160, y_position + 5, 300, line_height, name)
    
      # Mover la posición para la siguiente misión
      y_offset += sel_image.height + separation
    end
  
      # **Agregar el marcador en la posición deseada**
      # Puedes mover la posición del marcador según lo necesites
      marcador_x = 183  # Ajusta la posición horizontal
      marcador_y = 80  # Ajusta la posición vertical
      @sprites["img"].bitmap.blt(marcador_x, marcador_y, marcador_image, marcador_image.rect)

      # **Agregar el marcador en la posición deseada**
      # Puedes mover la posición del marcador según lo necesites
      marcador_x2 = 0  # Ajusta la posición horizontal
      marcador_y2 = 160  # Ajusta la posición vertical
      @sprites["img2"].bitmap.blt(marcador_x2, marcador_y2, marcador_image2, marcador_image2.rect)
      
    # Liberar la imagen después de usarla
    sel_image.dispose

    # Si no hay misiones, limpiar detalles para evitar datos antiguos
    @sprites["detailtext"].bitmap.clear if @quest_names.empty?
  end
  
    def pbShowQuestDetails(index)
      return @sprites["detailtext"].bitmap.clear if @active_quests.empty?
      quest_number = @active_quests[@scroll_offset + index]  # ID real de la misión
      return @sprites["detailtext"].bitmap.clear unless quest_number
      quest = QuestSystem.get_quest(quest_number)
      if quest
        @sprites["detailtext"].bitmap.clear
        font = @sprites["detailtext"].bitmap.font
        font.color = FONT_COLOR
        font.size = FONT_SIZE
        y_offset = 50  # Posición inicial del texto
        line_height = 32  # Altura normal de línea
    
        # **Mostrar el ID REAL de la misión en color azul oscuro**
        mission_id = sprintf("%02d", quest_number)  # Formato con 2 cifras
        font.color = Color.new(0, 0, 64)  # Azul oscuro
        font.size = FONT_SIZE - 2  # Hacerlo un poco más pequeño
        @sprites["detailtext"].bitmap.draw_text(0, y_offset - 30, 400, line_height, "#{mission_id}")
        y_offset += line_height
    
        # **Nombre de la misión**
        font.size = FONT_SIZE  # Restaurar tamaño normal
        font.color = FONT_COLOR
        @sprites["detailtext"].bitmap.draw_text(0, y_offset - 40, 400, line_height, "#{quest["Nombre de la Misión"]}")
        y_offset += line_height
    
        # **Objetivo**
        font.size = FONT_SIZE - 2
        @sprites["detailtext"].bitmap.draw_text(0, y_offset - 40, 400, line_height, "Objetivo:")
        y_offset += line_height  
    
        # **Descripción**
        font.size = FONT_SIZE - 9  # Fuente más pequeña
        desc_line_height = 14  # Reducir la separación entre líneas
        wrapped_text = wrap_text(quest["Descripcion de la Misión"], 260)
    
        wrapped_text.each do |line|
          @sprites["detailtext"].bitmap.draw_text(0, y_offset - 40, 400, desc_line_height, line)
          y_offset += desc_line_height  
        end
    
        # **Entrega de la misión**
        font.size = FONT_SIZE - 2  
        @sprites["detailtext"].bitmap.draw_text(0, 230, 400, line_height, "#{quest["Entrega de la misión"]}")
        y_offset += line_height
    
        # **Dibujar los iconos de los ítems en "Recompensa"**
        item_names = quest["Recompensa"].split(",")  # Separar múltiples ítems
        x_offset = 0  
        y_offset = 260  
        
        item_names.each do |item_name|
          item_name.strip!  
          item_icon_path = "Graphics/Items/#{item_name}.png"  
        
          if File.exist?(item_icon_path)
            item_icon = Bitmap.new(item_icon_path)
            icon_width = item_icon.width
        
            @sprites["detailtext"].bitmap.blt(x_offset, y_offset, item_icon, item_icon.rect)
            item_icon.dispose  
        
            x_offset += icon_width + 10  # Espacio entre íconos
          else
            @sprites["detailtext"].bitmap.draw_text(x_offset, y_offset, 400, line_height, "¡Icono no encontrado!")
          end
        end
      end
    end
  
  
  
    # Método para dividir el texto en varias líneas según el ancho máximo permitido
    def wrap_text(text, max_width)
      words = text.split(" ")
      lines = []
      current_line = ""
    
      words.each do |word|
        test_line = current_line.empty? ? word : "#{current_line} #{word}"
        text_width = @sprites["detailtext"].bitmap.text_size(test_line).width
    
        if text_width > max_width
          lines << current_line
          current_line = word
        else
          current_line = test_line
        end
      end
    
      lines << current_line unless current_line.empty?
      return lines
    end
  
  
    def update_scrollbar
      total_items = @quest_names.length
      total_visible = @max_visible_items
      scrollbar_height = 204  # Altura fija de la imagen de la barra
      thumb_height = [scrollbar_height * (total_visible.to_f / total_items), 40].min  # Tamaño mínimo del thumb
      thumb_width = @sprites["scrollthumb"].bitmap.width
    
      # Redibujar el bitmap del thumb
      @sprites["scrollthumb"].bitmap.dispose if @sprites["scrollthumb"].bitmap
      @sprites["scrollthumb"].bitmap = Bitmap.new(thumb_width, thumb_height)
    
      # Cargar la imagen del thumb
      thumb_image = Bitmap.new("Graphics/UI/quest/scrollthumb.png")
      @sprites["scrollthumb"].bitmap.blt(0, 0, thumb_image, thumb_image.rect)
      thumb_image.dispose
    
      # **Cálculo de la posición del "thumb"**
      total_scrollable = [total_items - total_visible, 1].max  # Evita valores negativos o 0
      
      # Evitar la división por cero
      if total_items > 1
        progress = (@scroll_offset + @selected_index) / (total_items - 1).to_f
      else
        progress = 0  # Si hay solo una misión, no se desplaza
      end
    
      progress = 0 if progress < 0  # Evitar valores negativos
      progress = 1 if progress > 1  # Garantiza que llegue al final exacto
    
      thumb_y_position = 135 + (progress * (scrollbar_height - thumb_height))  # Usa la altura de 204px
    
      # Aplicar la nueva posición
      @sprites["scrollthumb"].y = thumb_y_position
    end
  
  
  def toggle_details
    @show_details = !@show_details
    if @show_details
      draw_quest_list
      pbShowQuestDetails(@selected_index)
    else
      @sprites["questlist"].bitmap.clear
      @sprites["detailtext"].bitmap.clear
      @sprites["img"].bitmap.clear
      @sprites["img2"].bitmap.clear
    end
  end
  
  def pbShowCommands
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
  
      if Input.trigger?(Input::BACK)  # Salir del menú con B
        break
      elsif Input.trigger?(Input::RIGHT)  # Cambiar a la lista completa
        if $game_variables[103] == 0
        else
          hide_details
          @showing_complete_list = true  # Indicamos que estamos mostrando la lista completa
          @selected_index = 0
          @scroll_offset = 0
          complete_quest_list  # Mostrar la lista completa de misiones
          pbShowQuestDetails(@selected_index)
        end
      elsif Input.trigger?(Input::LEFT)
        hide_details
        @showing_complete_list = false  # Indicamos que estamos mostrando la lista normal
        @selected_index = 0
        @scroll_offset = 0
        draw_quest_list  # Mostrar la lista normal de misiones
        pbShowQuestDetails(@selected_index)
      elsif Input.trigger?(Input::UP)  # Mover hacia arriba en la lista
        if @showing_complete_list
          if @selected_index > 0
            @selected_index -= 1
          elsif @scroll_offset > 0
            @scroll_offset -= 1
          end
          complete_quest_list
          pbShowQuestDetails(@selected_index)
        else
          if @selected_index > 0
            @selected_index -= 1
          elsif @scroll_offset > 0
            @scroll_offset -= 1
          end
          draw_quest_list
          pbShowQuestDetails(@selected_index)
        end
      elsif Input.trigger?(Input::DOWN)  # Mover hacia abajo en la lista
        if @showing_complete_list
          if @selected_index < @max_visible_items - 1 && @selected_index < @quest_names.length - 1
            @selected_index += 1
          elsif @scroll_offset + @max_visible_items < @quest_names.length
            @scroll_offset += 1
          end
          complete_quest_list
          pbShowQuestDetails(@selected_index)
        else
          if @selected_index < @max_visible_items - 1 && @selected_index < @quest_names.length - 1
            @selected_index += 1
          elsif @scroll_offset + @max_visible_items < @quest_names.length
            @scroll_offset += 1
          end
          draw_quest_list
          pbShowQuestDetails(@selected_index)
        end
      end
    end
  end
  
  
  
  
  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  end
  
  class QuestMenu
    def initialize(scene)
      @scene = scene
    end
  
    def pbShowMenu
      if $game_variables[102] == 0
        # Si la variable 102 es igual a 0, no se ejecuta el menú y muestra un mensaje
        if $game_variables[103] == 0
          # Si la variable 102 es igual a 0, no se ejecuta el menú y muestra un mensaje
          pbMessage("No tienes ninguna misión disponible.")
        else
          # Si la variable 102 no es igual a 0, se ejecuta el menú normalmente
          @scene.pbStartScene
          @scene.pbShowCommands
          @scene.pbEndScene
        end
      else
        # Si la variable 102 no es igual a 0, se ejecuta el menú normalmente
        @scene.pbStartScene
        @scene.pbShowCommands
        @scene.pbEndScene
      end
    end
  end
  
  