#===============================================================================
# Adds/edits various Summary utilities.
#===============================================================================
class PokemonSummary_Scene
  def drawPageAllStats
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    ev_total = 0
    # Determine which stats are boosted and lowered by the Pokémon's nature
    statshadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow; ev_total += @pokemon.ev[s.id] }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(136, 96, 72) if change[1] > 0
        statshadows[change[0]] = Color.new(64, 120, 152) if change[1] < 0
      end
    end
    # Write various bits of text
    textpos = [
      [_INTL("Total"), 310, 105, :center, base, shadow],
      [_INTL("IV"), 530, 105, :center, base, shadow],
      [_INTL("EV"), 596, 105, :center, base, shadow],
      [_INTL("PS"), 289, 146, :left, base, statshadows[:HP]],
      [@pokemon.totalhp.to_s, 480, 146, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      #[sprintf("%d", @pokemon.baseStats[:HP]), 408, 126, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.iv[:HP]), 544, 146, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.ev[:HP]), 604, 146, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Ataque"), 289, 180, :left, base, statshadows[:ATTACK]],
      [@pokemon.attack.to_s, 480, 180, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      #[sprintf("%d", @pokemon.baseStats[:ATTACK]), 408, 158, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.iv[:ATTACK]), 542, 180, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.ev[:ATTACK]), 604, 180, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Defensa"), 289, 218, :left, base, statshadows[:DEFENSE]],
      [@pokemon.defense.to_s, 480, 218, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      #[sprintf("%d", @pokemon.baseStats[:DEFENSE]), 408, 190, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.iv[:DEFENSE]), 542, 218, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.ev[:DEFENSE]), 604, 218, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("At. Esp."), 291, 252, :left, base, statshadows[:SPECIAL_ATTACK]],
      [@pokemon.spatk.to_s, 480, 252, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      #[sprintf("%d", @pokemon.baseStats[:SPECIAL_ATTACK]), 408, 222, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.iv[:SPECIAL_ATTACK]), 542, 252, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.ev[:SPECIAL_ATTACK]), 604, 252, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Def Esp."), 291, 290, :left, base, statshadows[:SPECIAL_DEFENSE]],
      [@pokemon.spdef.to_s, 480, 290, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      #[sprintf("%d", @pokemon.baseStats[:SPECIAL_DEFENSE]), 408, 254, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.iv[:SPECIAL_DEFENSE]), 542, 290, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.ev[:SPECIAL_DEFENSE]), 604, 290, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Velocidad"),  290, 328, :left, base, statshadows[:SPEED]],
      [@pokemon.speed.to_s, 480, 328, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      #[sprintf("%d", @pokemon.baseStats[:SPEED]), 408, 286, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.iv[:SPEED]), 542, 328, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [sprintf("%d", @pokemon.ev[:SPEED]), 602, 328, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("EVs Totales"), 290, 370, :left, base, shadow],
      [sprintf("%d/%d", ev_total, Pokemon::EV_LIMIT), 535, 370, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Poder Oculto"), 290, 402, :left, base, shadow]
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    typebitmap = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
    hiddenpower = pbHiddenPower(@pokemon)
    type_number = GameData::Type.get(hiddenpower[0]).icon_position
    type_rect = Rect.new(0, type_number * 28, 64, 28)
    overlay.blt(500, 400, @typebitmap.bitmap, type_rect)
  end
end