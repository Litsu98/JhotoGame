#===============================================================================
# Jhoto Following Pokemon Continuity
#-------------------------------------------------------------------------------
# Preserve followers while walking between maps joined in map_connections.txt.
# Normal transfers keep the Pokemon hidden until the player walks manually.
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

# A forced move route (for example, walking out of a Pokemon Center) must not
# count as the player's first manual step after a transfer.
class FollowerData
  alias __jhoto_continuity__invisible_after_transfer= invisible_after_transfer= unless method_defined?(:__jhoto_continuity__invisible_after_transfer=)

  def invisible_after_transfer=(value)
    forced_player_movement = $game_player && $game_player.move_route_forcing
    return true if @invisible_after_transfer && value == false && forced_player_movement
    return send(:__jhoto_continuity__invisible_after_transfer=, value)
  end
end

# Game_Follower#fancy_moveto animates cardinal movement and jumps, but falls
# back to an instant moveto for a one-tile diagonal. Stair events use forced
# diagonal routes, so mirror that diagonal instead of teleporting the follower.
class Game_Follower
  alias __jhoto_continuity__fancy_moveto fancy_moveto unless method_defined?(:__jhoto_continuity__fancy_moveto)

  def fancy_moveto(new_x, new_y, leader)
    delta_x = new_x - self.x
    delta_y = new_y - self.y
    if delta_x.abs == 1 && delta_y.abs == 1
      old_through = @through
      old_direction_fix = @direction_fix
      @through = true
      @direction_fix = true
      @direction = leader.direction
      case [delta_x, delta_y]
      when [-1, 1]  then move_lower_left
      when [1, 1]   then move_lower_right
      when [-1, -1] then move_upper_left
      when [1, -1]  then move_upper_right
      end
      @through = old_through
      @direction_fix = old_direction_fix
      return
    end
    return __jhoto_continuity__fancy_moveto(new_x, new_y, leader)
  end
end
