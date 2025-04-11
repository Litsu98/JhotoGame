#***********************************************************
# OBJETOS RANDOM
#
# Por Skyflyer
#***********************************************************

def getRandomItem(category)
  items = case category
          when :tm then RandomizedChallenge::MTLIST_RANDOM
          when :normal then GameData::Item.all.select { |item| !RandomizedChallenge::MTLIST_RANDOM.include?(item.id) }
          end
  item_num = rand(items.size)
  items[item_num]
end


# Al llamar a esta función, si el interruptor ITEMS_RANDOM está activo, el objeto
# que encontramos es uno al azar.
def getItemRandomFromPokeball()
  objeto_elegido = 0
  loop do
    objeto_elegido = getRandomItem
    # Comprobamos si está en la Blacklist.
    for blacklist_item in RandomizedChallenge::BLACK_LIST
      item = GameData::Item.get(blacklist_item)
      enBlackList = true if objeto_elegido==item
      break if enBlackList
    end
    # Revisión de MTs.
    for mt in RandomizedChallenge::MTLIST_RANDOM
      item = GameData::Item.get(mt)
      mtRepetida = true if (objeto_elegido==item && $bag.has?(objeto_elegido))
      break if mtRepetida
    end
    break if !enBlackList && !mtRepetida
  end
  Kernel.pbItemBall(objeto_elegido)
end

def getRandomMT()
  mt_items = RandomizedChallenge::MTLIST_RANDOM.map { |id| GameData::Item.get(id) }
  return nil if mt_items.empty?
  mt_items.sample
end

def getItemRandomMTFromPokeball()
  # Obtener todas las MTs del jugador
  all_mt_in_bag = RandomizedChallenge::MTLIST_RANDOM.all? { |id| $bag.has?(GameData::Item.get(id)) }

  # Si el jugador ya tiene todas las MTs, no hacer nada
  return if all_mt_in_bag

  objeto_elegido = nil
  loop do
    objeto_elegido = getRandomMT()
    next if objeto_elegido.nil?  # Si no hay MTs disponibles, continuar el loop

    enBlackList = RandomizedChallenge::BLACK_LIST.include?(objeto_elegido.id)
    mtRepetida = $bag.has?(objeto_elegido)

    break unless enBlackList || mtRepetida
  end

  if objeto_elegido
    Kernel.pbItemBall(objeto_elegido)
  else
    pbMessage("No se pudo encontrar una MT válida.")
  end
end
