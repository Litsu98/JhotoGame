#===============================================================================
# Jhoto Following Pokemon Continuity
#-------------------------------------------------------------------------------
# Following Pokemon EX refreshes (removes and recreates) the follower whenever
# :on_enter_map fires. Essentials also fires that event when the player walks
# over the edge of two maps joined in map_connections.txt.
#
# Preserve the follower only for those genuinely connected maps. Transfers made
# by events (doors, caves and intersection maps) keep Essentials' normal
# behaviour: the Pokemon remains hidden on arrival and comes out after the
# player takes a step.
#===============================================================================
EventHandlers.remove(:on_enter_map, :erase_following_pkmn)
EventHandlers.add(:on_enter_map, :erase_following_pkmn, proc { |old_map_id|
  new_map_id = $game_map&.map_id
  maps_connected = old_map_id && new_map_id && $map_factory &&
                   $map_factory.areConnected?(old_map_id, new_map_id)
  next if maps_connected

  event = FollowingPkmn.get_data
  next if !event
  FollowingPkmn.refresh(false)
  $map_factory.maps.each do |map|
    map.events[event.event_id]&.erase if event.original_map_id == event.current_map_id
  end
})

# Essentials reveals followers as soon as the player starts moving after a
# transfer. A forced move route (for example, walking out of a Pokemon Center)
# must not count as the player's first step.
class FollowerData
  alias __jhoto_continuity__invisible_after_transfer= invisible_after_transfer= unless method_defined?(:__jhoto_continuity__invisible_after_transfer=)

  def invisible_after_transfer=(value)
    forced_player_movement = $game_player && $game_player.move_route_forcing
    return true if @invisible_after_transfer && value == false && forced_player_movement
    return send(:__jhoto_continuity__invisible_after_transfer=, value)
  end
end
