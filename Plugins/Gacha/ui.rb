# Módulo Keyboard para detección de teclas ASCII
module Keyboard
  @keys = Win32API.new('user32', 'GetAsyncKeyState', ['i'], 'i')

  def self.press?(key)
    return (@keys.call(key) & 0x01) != 0
  end
end




def pbShowGachaImage(filename = "imagenbase")
  # Guardar el BGM actual
  current_bgm = $game_system.getPlayingBGM

  # Reproducir música del gacha
  pbBGMPlay("gachamusic")

  # Selección de tier e ítem
  def select_random_tier_and_item
    tier_items = {
      1 => [:POTION, :POKEBALL, :ANTIDOTE],
      2 => [:SUPERPOTION, :GREATBALL, :AWAKENING],
      3 => [:HYPERPOTION, :ULTRABALL, :REVIVE],
      4 => [:FULLRESTORE, :RARECANDY, :MAXREVIVE],
      5 => [:MASTERBALL, :ABILITYCAPSULE, :BOTTLECAP]
    }

    tier_probabilities = {
      1 => 50,
      2 => 25,
      3 => 15,
      4 => 8,
      5 => 2
    }

    rand_val = rand(1..100)
    accumulated = 0
    selected_tier = 1

    tier_probabilities.each do |tier, chance|
      accumulated += chance
      if rand_val <= accumulated
        selected_tier = tier
        break
      end
    end

    item = tier_items[selected_tier].sample
    return selected_tier, item
  end

def show_gacha_animation(sprite)
    base_path = "Graphics/UI/Gacha/"
    transition_images = %w[imagenbase2 imagenbase3 imagenbase4 imagenbase5 imagenbase6]

    # Reproducir SE menibela al empezar la transición
    pbSEPlay("menibela")

    transition_images.each do |img|
        path = "#{base_path}#{img}.png"
        if FileTest.exist?(path)
            sprite.bitmap.dispose if sprite.bitmap
            sprite.bitmap = Bitmap.new(path)
        end
            60.times do  # 1 segundo
            Graphics.update
            Input.update
        end
    end

    # Esperar 4 segundos antes de la animación por tier
    240.times do
      Graphics.update
      Input.update
    end

    # Seleccionar tier y el ítem
    tier, item = select_random_tier_and_item

    # Mostrar animación por tier
    tier_images = case tier
      when 1 then %w[tier1_1 tier1_2 tier1_3]
      when 2 then %w[tier2_1 tier2_2 tier2_3]
      when 3 then %w[tier3_1 tier3_2 tier3_3]
      when 4 then %w[tier4_1 tier4_2 tier4_3]
      when 5 then %w[tier5_1 tier5_2 tier5_3]
      else []
    end

    tier_images.each do |img|
      path = "#{base_path}#{img}.png"
      if FileTest.exist?(path)
        sprite.bitmap.dispose if sprite.bitmap
        sprite.bitmap = Bitmap.new(path)
      end
      60.times do
        Graphics.update
        Input.update
      end
    end

    # Volver a mostrar imagenbase
    base_image = "#{base_path}imagenbase.png"
    if FileTest.exist?(base_image)
      sprite.bitmap.dispose if sprite.bitmap
      sprite.bitmap = Bitmap.new(base_image)
    end

    # Dar el ítem al jugador
    if $bag.add(item)
        #pbSEPlay("ItemGet")  # Sonido al obtener el ítem
        pbGetKeyItem(item.to_s)
    else
        pbMessage("Tu bolsa está llena. No puedes recibir el ítem.")
    end
  end

  # Mostrar la imagen base inicial
  path = "Graphics/UI/Gacha/#{filename}.png"
  unless FileTest.exist?(path)
    pbMessage("No se encontró la imagen: #{filename}")
    return
  end

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 999
  sprite = Sprite.new(viewport)
  sprite.bitmap = Bitmap.new(path)

  animation_in_progress = false

   showing_info = false   # Añade esto ANTES del loop (solo una vez)

    loop do
    Graphics.update
    Input.update

    next if animation_in_progress

    if Keyboard.press?(73) && !showing_info   # Tecla I (código 73)
        showing_info = true
        pbMessage("\\l[3]★ Tiers del Gacha ★\n\n" +
                "Tier 1 (50%)\n  Pociones, Poké Balls, Antídotos\n\n" +
                "Tier 2 (25%)\n  Superpociones, Great Balls, Despertar\n\n" +
                "Tier 3 (15%)\n  Hiperpociones, Ultra Balls, Revivir\n\n" +
                "Tier 4 (8%)\n  Restaurar Todo, Caramelos Raros, Revivir Máx\n\n" +
                "Tier 5 (2%)\n  Master Ball, Cápsula Habilidad, Tapón Plateado")
        showing_info = false
    elsif Input.trigger?(Input::Y)   # Tecla S
        animation_in_progress = true
        show_gacha_animation(sprite)
        animation_in_progress = false
    elsif Input.trigger?(Input::A)   # Z o X
        break
    end
    end


  # Restaurar BGM anterior
  pbBGMPlay(current_bgm)

  sprite.bitmap.dispose
  sprite.dispose
  viewport.dispose
end
