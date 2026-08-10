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

def narration_commands(list, lines, wait_frames = 8)
  source = templates(list)
  result = []
  lines.each_with_index do |line, index|
    result << clone_command(index.zero? ? source[:text] : source[:follow],
                            index.zero? ? 101 : 401, [line])
  end
  result << clone_command(source[:wait], 106, [wait_frames])
  result
end

raw = File.binread(MAP_PATH)
map = Marshal.load(raw)
event = ivar(map, :@events)[19] || raise("Map106 no contiene el evento 19")
pages = ivar(event, :@pages)
raise "El evento Kimono no conserva sus dos páginas" unless pages.length == 2
list = ivar(pages[0], :@list)

# Primer comentario: establece que el bosque está inquieto sin explicarlo todo.
opening_index = text_index(list,
  "<b>Chica Kimono</b>: Este bosque tiene algo especial… Incluso para alguien acostumbrada a viajar por lugares como este.")
params(list[opening_index])[0] = "<b>Chica Kimono</b>: El Encinar está inquieto."
list.insert(opening_index + 1,
  clone_command(templates(list)[:follow], 401,
    ["Normalmente, el viento atraviesa sus copas. Hoy parece detenerse alrededor de este monumento."]))

# Reemplaza toda la exposición y elimina las ramas de género duplicadas.
monument_start = text_index(list, "El monumento representa a Celebi, el guardián de este bosque.")
monument_picture = monument_start.downto(0).find { |cursor| code(list[cursor]) == 231 }
farewell_index = text_index(list,
  "<b>Chica Kimono</b>: Será mejor que me marche. Todavía tengo que reunirme con las demás.")
monument_end = (farewell_index...list.length).find { |cursor| code(list[cursor]) == 235 }
raise "No se pudo delimitar el bloque del monumento" unless monument_picture && monument_end

monument_dialogue = []
monument_dialogue.concat(narration_commands(list,
  ["Las inscripciones están desgastadas.",
   "Solo consigues distinguir tres símbolos: un brote, una hoja seca",
   "y algo parecido a un reloj de arena."], 8))
monument_dialogue.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: En Johto dicen que Celebi aparece cuando un bosque",
   "necesita recuperar algo que el tiempo le arrebató."], 8))
monument_dialogue.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: No sé si la historia es cierta…",
   "pero aquí hay algo observándonos."], 8))
monument_dialogue.concat(narration_commands(list,
  ["Una brisa atraviesa las hojas, aunque el resto del bosque permanece inmóvil.",
   "Por un instante, sientes una mirada procedente de otro momento."], 10))
monument_dialogue.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Esa mirada… Estás intentando decidir si ya nos conocemos."], 8))
monument_dialogue.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Puede que hablaras conmigo.",
   "O quizá con una de mis compañeras."], 8))
monument_dialogue.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Somos tres, pero nuestros caminos se cruzan tantas veces",
   "que algunos terminan viéndonos como una sola."], 8))
monument_dialogue.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Los Pokémon del bosque quieren alejarse de este lugar."], 8))
monument_dialogue.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Los tuyos, en cambio, permanecen a tu lado.",
   "Eso resulta… interesante."], 8))
monument_dialogue.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Antes de irme, quiero entregarte algo."], 6))
list[monument_picture..monument_end] = monument_dialogue

# La piedra se presenta antes de añadirse a la Bolsa.
item_script = list.index { |command| code(command) == 355 && params(command)[0] == 'pbGetKeyItem("ODDKEYSTONE")' } ||
  raise("No se encontró la entrega de ODDKEYSTONE")
item_intro = []
item_intro.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Encontré esta piedra atrapada entre las raíces,",
   "al pie del monumento."], 8))
item_intro.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Desde que la recogí, parece más pesada",
   "cada vez que el bosque queda en silencio."], 8))
item_intro.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Creo que no me estaba esperando a mí."], 8))
list.insert(item_script, *item_intro)

# La despedida posterior a la entrega se divide en dos mensajes con pausa.
old_item_text = "<b>Chica Kimono</b>: Encontré esto durante uno de mis viajes. Todavía no sé qué significa, pero quizá tú puedas descubrirlo."
old_item_index = text_index(list, old_item_text)
old_picture = old_item_index.downto(0).find { |cursor| code(list[cursor]) == 231 }
old_erase = (old_item_index...list.length).find { |cursor| code(list[cursor]) == 235 }
raise "No se pudo delimitar la despedida antigua" unless old_picture && old_erase

item_outro = []
item_outro.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Guárdala.",
   "Quizá, cuando llegue el momento, sepas dónde debe estar."], 8))
item_outro.concat(message_commands(list, "kimono",
  ["<b>Chica Kimono</b>: Nos volveremos a encontrar, \\PN."], 6))
list[old_picture..old_erase] = item_outro

FileUtils.mkdir_p(BACKUP_DIR)
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
backup_path = File.join(BACKUP_DIR, "Map106_before_kimono_rewrite_#{timestamp}.rxdata")
File.binwrite(backup_path, raw)
File.binwrite(MAP_PATH, Marshal.dump(map))

verified = Marshal.load(File.binread(MAP_PATH))
verified_event = ivar(verified, :@events)[19]
raise "La verificación perdió el evento 19" unless verified_event
raise "La verificación alteró las dimensiones" unless ivar(verified, :@width) == 130 && ivar(verified, :@height) == 60
raise "La verificación alteró el número de eventos" unless ivar(verified, :@events).length == ivar(map, :@events).length

puts "Evento Kimono de Map106 actualizado correctamente."
puts "Copia de seguridad: #{backup_path}"
