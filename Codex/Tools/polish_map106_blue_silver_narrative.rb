# frozen_string_literal: true
# encoding: UTF-8

require "fileutils"

class Table
  def self._load(data)
    object = allocate
    object.instance_variable_set(:@_marshal_data, data)
    object
  end

  def _dump(_depth = 0)
    @_marshal_data
  end
end

class Color < Table; end
class Tone < Table; end

module RPG
  class Map; end
  class Event
    class Page
      class Condition; end
      class Graphic; end
    end
  end
  class EventCommand; end
  class MoveRoute; end
  class MoveCommand; end
  class AudioFile; end
end

ROOT = File.expand_path("../..", __dir__)
MAP_PATH = File.join(ROOT, "Data", "Map106.rxdata")
BACKUP_DIR = File.join(ROOT, "Codex", "Backups")

def ivar(object, name)
  object.instance_variable_get(name)
end

def set_ivar(object, name, value)
  object.instance_variable_set(name, value)
end

def code(command)
  ivar(command, :@code)
end

def params(command)
  ivar(command, :@parameters)
end

def text_index(list, text)
  list.index { |command| [101, 401].include?(code(command)) && params(command)[0] == text } ||
    raise("No se encontró el texto esperado: #{text}")
end

def replace_text(list, old_text, new_text)
  params(list[text_index(list, old_text)])[0] = new_text
end

def clone_command(template, command_code, parameters, indent = 0)
  command = template.dup
  set_ivar(command, :@code, command_code)
  set_ivar(command, :@indent, indent)
  set_ivar(command, :@parameters, parameters)
  command
end

def templates(list)
  {
    picture: list.find { |command| code(command) == 231 },
    text:    list.find { |command| code(command) == 101 },
    follow:  list.find { |command| code(command) == 401 },
    erase:   list.find { |command| code(command) == 235 },
    wait:    list.find { |command| code(command) == 106 }
  }
end

def message_commands(list, portrait, lines, wait_frames = 8)
  source = templates(list)
  picture_params = params(source[:picture]).dup
  picture_params[1] = portrait
  result = [clone_command(source[:picture], 231, picture_params)]
  lines.each_with_index do |line, index|
    result << clone_command(index.zero? ? source[:text] : source[:follow],
                            index.zero? ? 101 : 401, [line])
  end
  result << clone_command(source[:erase], 235, [1])
  result << clone_command(source[:wait], 106, [wait_frames])
  result
end

def message_block_bounds(list, text)
  index = text_index(list, text)
  start_index = index.downto(0).find { |cursor| code(list[cursor]) == 231 }
  end_index = (index...list.length).find { |cursor| code(list[cursor]) == 106 }
  raise "No se pudo delimitar el mensaje: #{text}" unless start_index && end_index
  [start_index, end_index]
end

raw = File.binread(MAP_PATH)
map = Marshal.load(raw)
event = ivar(map, :@events)[8] || raise("Map106 no contiene el evento 8")
pages = ivar(event, :@pages)
raise "El evento 8 no conserva sus tres páginas" unless pages.length == 3
page2 = ivar(pages[1], :@list)

# Sustituye toda la conversación central sin tocar la llegada ni los movimientos.
conversation_start, = message_block_bounds(page2, "<b>Silver</b>: ¿Blue…? ¿Qué haces aquí?")
_, conversation_end = message_block_bounds(page2, "<b>Blue</b>: Entonces deja de comportarte como te enseñaron.")

conversation = []
conversation.concat(message_commands(page2, "Silver",
  ["<b>Silver</b>: ¿Blue…? ¿Qué haces en Johto?"]))
conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Seguir al Team Rocket.",
   "Aunque admito que tu rastro ha sido bastante más fácil de seguir."]))
conversation.concat(message_commands(page2, "Silver",
  ["<b>Silver</b>: No te metas. Esto no tiene nada que ver contigo."]))
conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Acabas de amenazar a alguien porque perdiste un combate.",
   "Empieza a tener que ver conmigo."]))
conversation.concat(message_commands(page2, "Silver",
  ["<b>Silver</b>: No sabes lo que está en juego."]))
conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Sé que, en cuanto oyes hablar del jefe, vuelves a actuar",
   "como si aún estuvieras encerrado allí."]))
conversation.concat(message_commands(page2, "Silver",
  ["<b>Silver</b>: No vuelvas a hablar de ese lugar."]))
conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Entonces deja de permitir que siga decidiendo por ti."]))
conversation.concat(message_commands(page2, "Silver",
  ["<b>Silver</b>: Ellos están volviendo.",
   "No pienso esperar a que destruyan a más Pokémon."]))
conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Y yo no te he pedido que esperes.",
   "Te estoy pidiendo que pienses."]))
conversation.concat(message_commands(page2, "Silver",
  ["<b>Silver</b>: Pensar no detuvo a nadie entonces."]))
conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: No. Pero confiar en alguien fue lo que te permitió salir."]))
conversation.concat(message_commands(page2, "Silver",
  ["<b>Silver</b>: …Eso fue diferente."]))
conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Claro. Porque entonces todavía eras capaz de pedir ayuda."]))
conversation.concat(message_commands(page2, "Silver",
  ["<b>Silver</b>: No necesito que vuelvas a salvarme."]))
conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Nunca te salvé, Silver. Tú elegiste escapar.",
   "No lo olvides ahora."], 10))
page2[conversation_start..conversation_end] = conversation

# Blue reconoce al protagonista sin atribuirle problemas que aún no ha causado.
replace_text(page2,
             "<b>Blue</b>: Vaya, \\PN. No esperaba volver a encontrarte aquí.",
             "<b>Blue</b>: Vaya, \\PN… No esperaba volver a encontrarte tan pronto.")

# Se elimina la explicación redundante de que ya se conocieron en Ciudad Malva.
known_start, known_end = message_block_bounds(page2, "<b>Blue</b>: Nos conocimos en Ciudad Malva.")
page2.slice!(known_start..known_end)

replace_text(page2,
             "<b>Blue</b>: Entiendo. Así que ella dirigía la operación del pozo.",
             "<b>Blue</b>: Entiendo. Atenea no se expondría por unas simples colas de Slowpoke.")
replace_text(page2,
             "<b>Blue</b>: Si el Team Rocket está reuniendo otra vez a sus miembros, las colas de Slowpoke solo son el principio.",
             "<b>Blue</b>: Si están reuniendo reclutas de nuevo, aquello solo era el principio.")
replace_text(page2,
             "<b>Silver</b>: Te debo una, Blue. Pero esto sigue siendo asunto mío.",
             "<b>Silver</b>: Pensad lo que queráis. Yo seguiré buscando.")

# Despedida de Blue: cada idea dispone de su propia ventana y pausa.
replace_text(page2,
             "<b>Blue</b>: Silver nunca ha sabido disculparse.",
             "<b>Blue</b>: No pongas esa cara. Silver siempre ha sido pésimo disculpándose.")

rage_index = text_index(page2,
  "<b>Blue</b>: Su rabia no va dirigida contra ti, pero eso no justifica lo que acaba de hacer.")
params(page2[rage_index])[0] = "<b>Blue</b>: Eso no justifica lo que ha hecho."
page2.insert(rage_index + 1,
             clone_command(templates(page2)[:follow], 401,
                           ["Pero su rabia no iba dirigida contra ti."]))

replace_text(page2,
             "<b>Blue</b>: Cuando sigue el rastro del jefe del Team Rocket, deja de pensar con claridad.",
             "<b>Blue</b>: Cuando el Team Rocket aparece, deja de ver lo que tiene delante.")

blind_text = "<b>Blue</b>: Cuando el Team Rocket aparece, deja de ver lo que tiene delante."
blind_index = text_index(page2, blind_text)
blind_wait = (blind_index...page2.length).find { |cursor| code(page2[cursor]) == 106 }
page2.insert(blind_wait + 1,
             *message_commands(page2, "Blue",
               ["<b>Blue</b>: Y si está buscando al jefe…",
                "esto es mucho más serio de lo que pensaba."], 8))

replace_text(page2,
             "<b>Blue</b>: Toma. Puede que esto te ayude a avanzar por el bosque.",
             "<b>Blue</b>: Toma. Te servirán para avanzar por el bosque.")

# El bloque posterior a la entrega ya no encadena tres párrafos sin pausa.
item_start = text_index(page2,
  "<b>Blue</b>: Con esto podrás usar Corte y retirar los árboles que bloquean el camino.")
item_picture = item_start.downto(0).find { |cursor| code(page2[cursor]) == 231 }
item_erase = (item_start...page2.length).find { |cursor| code(page2[cursor]) == 235 }
raise "No se pudo delimitar el diálogo posterior a las Tijeras" unless item_picture && item_erase

item_dialogue = []
item_dialogue.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Con ellas podrás usar Corte y retirar los árboles que bloquean el camino."], 8))
item_dialogue.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Ten cuidado, \\PN.",
   "El Team Rocket no se movilizaría por unas simples colas de Slowpoke."], 8))
item_dialogue.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Nos volveremos a ver."], 5))
page2[item_picture..item_erase] = item_dialogue

FileUtils.mkdir_p(BACKUP_DIR)
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
backup_path = File.join(BACKUP_DIR, "Map106_before_narrative_polish_#{timestamp}.rxdata")
File.binwrite(backup_path, raw)
File.binwrite(MAP_PATH, Marshal.dump(map))

verified = Marshal.load(File.binread(MAP_PATH))
verified_event = ivar(verified, :@events)[8]
raise "La verificación perdió el evento 8" unless verified_event
raise "La verificación alteró las dimensiones" unless ivar(verified, :@width) == 130 && ivar(verified, :@height) == 60
raise "La verificación alteró el número de eventos" unless ivar(verified, :@events).length == ivar(map, :@events).length

puts "Map106 actualizado con el diálogo narrativo definitivo."
puts "Copia de seguridad: #{backup_path}"
