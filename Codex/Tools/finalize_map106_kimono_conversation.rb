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

def message_commands(list, lines, wait_frames = 8)
  source = templates(list)
  picture_params = params(source[:picture]).dup
  picture_params[1] = "kimono"
  result = [clone_command(source[:picture], 231, picture_params)]
  lines.each_with_index do |line, index|
    result << clone_command(index.zero? ? source[:text] : source[:follow],
                            index.zero? ? 101 : 401, [line])
  end
  result << clone_command(source[:erase], 235, [1])
  result << clone_command(source[:wait], 106, [wait_frames])
  result
end

def block_bounds(list, first_text, last_text = first_text)
  first = text_index(list, first_text)
  last = text_index(list, last_text)
  start_index = first.downto(0).find { |cursor| code(list[cursor]) == 231 || code(list[cursor]) == 101 }
  start_index = first if code(list[start_index]) != 231
  end_index = (last...list.length).find { |cursor| code(list[cursor]) == 106 }
  raise "No se pudo delimitar el bloque de conversación" unless start_index && end_index
  [start_index, end_index]
end

raw = File.binread(MAP_PATH)
map = Marshal.load(raw)
event = ivar(map, :@events)[19] || raise("Map106 no contiene el evento 19")
pages = ivar(event, :@pages)
raise "El evento Kimono no conserva sus dos páginas" unless pages.length == 2
list = ivar(pages[0], :@list)

# Apertura: solo habla la chica Kimono.
opening_start, opening_end = block_bounds(list,
  "<b>Chica Kimono</b>: El Encinar está inquieto.")
list[opening_start..opening_end] = message_commands(list,
  ["<b>Chica Kimono</b>: El Encinar está demasiado callado.",
   "No es la calma de un bosque en reposo.",
   "Es la clase de silencio que queda cuando algo espera."], 8)

# Conversación junto al monumento. Se elimina cualquier narración externa.
middle_start, middle_end = block_bounds(list,
  "Las inscripciones están desgastadas.",
  "<b>Chica Kimono</b>: Antes de irme, quiero entregarte algo.")

conversation = []
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: ¿También lo sientes?",
   "Los Pokémon salvajes evitan acercarse a este lugar."], 8))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Dicen que este monumento está dedicado a Celebi,",
   "un Pokémon capaz de atravesar el tiempo."], 8))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Según la leyenda, aparece cuando el bosque",
   "necesita recuperar algo que perdió."], 8))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Aunque las leyendas cambian cada vez que alguien las cuenta…",
   "El miedo de los Pokémon no miente."], 10))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Esa mirada…",
   "Estás intentando decidir si ya nos habíamos visto."], 8))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Puede que sí.",
   "O puede que conocieras a una de mis compañeras."], 8))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Somos tres, y admito que no facilitamos que nos distingan.",
   "Pero tú sí has prestado atención. Eso me alegra."], 8))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Los Pokémon del bosque se apartan del monumento.",
   "Los tuyos, en cambio, siguen a tu lado."], 8))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: No porque no tengan miedo, sino porque confían en ti."], 8))
conversation.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Antes de irme, quiero entregarte algo."], 6))
list[middle_start..middle_end] = conversation

# Presentación sencilla de la Piedra Espíritu y pista hacia el pozo ya visitado.
stone_start, stone_end = block_bounds(list,
  "<b>Chica Kimono</b>: Encontré esta piedra atrapada entre las raíces,",
  "<b>Chica Kimono</b>: Creo que no me estaba esperando a mí.")

stone_intro = []
stone_intro.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Encontré esta piedra entre las raíces.",
   "No parece tener relación con el monumento."], 8))
stone_intro.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Una vez escuché una historia sobre piedras como esta."], 8))
stone_intro.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Dicen que despiertan cuando alcanzan el fondo",
   "de ciertos pozos antiguos."], 8))
stone_intro.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Nunca he sabido cuánto hay de verdad en esa historia."], 8))
list[stone_start..stone_end] = stone_intro

# Despedida después de añadir el objeto a la Bolsa.
outro_start, outro_end = block_bounds(list,
  "<b>Chica Kimono</b>: Guárdala.",
  "<b>Chica Kimono</b>: Nos volveremos a encontrar, \\PN.")

outro = []
outro.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Guárdala.",
   "Puede que, sin saberlo, ya hayas pasado junto al lugar adecuado."], 8))
outro.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Nos volveremos a encontrar, \\PN."], 8))
outro.concat(message_commands(list,
  ["<b>Chica Kimono</b>: Y la próxima vez quizá descubras",
   "si estás hablando con la misma de antes."], 6))
list[outro_start..outro_end] = outro

FileUtils.mkdir_p(BACKUP_DIR)
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
backup_path = File.join(BACKUP_DIR, "Map106_before_kimono_conversation_#{timestamp}.rxdata")
File.binwrite(backup_path, raw)
File.binwrite(MAP_PATH, Marshal.dump(map))

verified = Marshal.load(File.binread(MAP_PATH))
verified_event = ivar(verified, :@events)[19]
raise "La verificación perdió el evento 19" unless verified_event
raise "La verificación alteró las dimensiones" unless ivar(verified, :@width) == 130 && ivar(verified, :@height) == 60
raise "La verificación alteró el número de eventos" unless ivar(verified, :@events).length == ivar(map, :@events).length

puts "Conversación Kimono definitiva aplicada a Map106."
puts "Copia de seguridad: #{backup_path}"
