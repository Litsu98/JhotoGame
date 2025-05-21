#-------------------------------------------------------------------------------
# Reload challenge data upon save reload
#-------------------------------------------------------------------------------
class PokemonLoadScreen
  alias __challenge__pbStartLoadScreen pbStartLoadScreen unless method_defined?(:__challenge__pbStartLoadScreen)
  def pbStartLoadScreen
    ret = __challenge__pbStartLoadScreen
    ChallengeModes.toggle(true) if ChallengeModes.running?
    return ret
  end
end

alias __challenge__pbTrainerName pbTrainerName unless defined?(__challenge__pbTrainerName)
def pbTrainerName(*args)
  ret = __challenge__pbTrainerName(*args)
  ChallengeModes.reset
  $PokemonGlobal.challenge_state = {}
  return ret
end

#-------------------------------------------------------------------------------
# Starts challenge only after obtaining a Pokeball
#-------------------------------------------------------------------------------
class PokemonBag
  alias __challenge__add add unless method_defined?(:__challenge__add)
  def add(*args)
    ret = __challenge__add(*args)
    item = args[0]
    return ret if !$PokemonGlobal || !$PokemonGlobal.challenge_qued || !GameData::Item.get(item).is_poke_ball?
    ChallengeModes.begin_challenge
   
    return ret
  end
end


#-------------------------------------------------------------------------------
# Add Game Over methods
#-------------------------------------------------------------------------------
alias __challenge__pbStartOver pbStartOver unless defined?(__challenge__pbStartOver)
def pbStartOver(*args)
  return __challenge__pbStartOver(*args) if !ChallengeModes.on?
  resume = false
  pbEachPokemon do |pkmn, _|
    next if pkmn.fainted? || pkmn.egg?
    resume = true
    break
  end
  if resume && !ChallengeModes.on?(:GAME_OVER_WHITEOUT)
    loop do
      pbMessage("\\w[]\\wm\\c[8]\\l[3]" + 
        _INTL("Todos tus Pokémon se han debilitado. Pero aún tienes Pokémon en tu PC con los que puedes continuar."))
      pbFadeOutIn(99999) {
        scene = PokemonStorageScene.new
        screen = PokemonStorageScreen.new(scene, $PokemonStorage)
        screen.pbStartScreen(0)
      }
      break if $player.able_pokemon_count != 0
    end
  else
    eliminar_jugador($player.name, $player.id)
    pbMessage("\\w[]\\wm\\c[8]\\l[3]" +
      _INTL("Todos tus Pokémon se han debilitado. Has perdido."))
    ChallengeModes.set_loss

    # --- Borrado de la partida en AppData/Roaming/La Base de Sky ---
    begin
      # Ruta a %APPDATA%\La Base de Sky\Game.rxdata
      appdata = ENV["APPDATA"]
      save_dir = File.join(appdata, "La Base de Sky")
      save_file = File.join(save_dir, "Game.rxdata")
      bak_file  = save_file + "bak"

      if File.exist?(save_file)
        File.delete(save_file)
       
      elsif File.exist?(bak_file)
        File.delete(bak_file)
      else
      end
    rescue => e
    end
    Kernel.exit
  end

  return __challenge__pbStartOver(*args)
end