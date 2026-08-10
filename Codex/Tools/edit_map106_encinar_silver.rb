# frozen_string_literal: true
# encoding: UTF-8

require "fileutils"
require "time"

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

def command_code(command)
  ivar(command, :@code)
end

def command_params(command)
  ivar(command, :@parameters)
end

def text_index(list, text)
  list.index do |command|
    [101, 401].include?(command_code(command)) && command_params(command)[0] == text
  end || raise("No se encontró el texto esperado: #{text}")
end

def replace_text(list, old_text, new_text)
  index = text_index(list, old_text)
  command_params(list[index])[0] = new_text
  index
end

def cloned_command(template, code, parameters, indent = 0)
  command = template.dup
  set_ivar(command, :@code, code)
  set_ivar(command, :@indent, indent)
  set_ivar(command, :@parameters, parameters)
  command
end

def templates_for(list)
  {
    picture: list.find { |command| command_code(command) == 231 },
    text:    list.find { |command| command_code(command) == 101 },
    follow:  list.find { |command| command_code(command) == 401 },
    erase:   list.find { |command| command_code(command) == 235 },
    wait:    list.find { |command| command_code(command) == 106 }
  }
end

def message_commands(list, portrait, lines, wait_frames = 8)
  templates = templates_for(list)
  picture_parameters = command_params(templates[:picture]).dup
  picture_parameters[1] = portrait
  commands = [cloned_command(templates[:picture], 231, picture_parameters)]
  lines.each_with_index do |line, index|
    template = index.zero? ? templates[:text] : templates[:follow]
    commands << cloned_command(template, index.zero? ? 101 : 401, [line])
  end
  commands << cloned_command(templates[:erase], 235, [1])
  commands << cloned_command(templates[:wait], 106, [wait_frames])
  commands
end

def insert_after_text(list, text, commands)
  index = text_index(list, text)
  list.insert(index + 1, *commands)
end

raw = File.binread(MAP_PATH)
map = Marshal.load(raw)
event = ivar(map, :@events)[8] || raise("Map106 no contiene el evento 8")
pages = ivar(event, :@pages)
raise "El evento 8 no conserva sus tres páginas" unless pages.length == 3

page1 = ivar(pages[0], :@list)
page2 = ivar(pages[1], :@list)

# Interrogatorio: Silver busca a Giovanni, pero aún no revela su parentesco.
replace_text(page1,
             "<b>Silver</b>: Habla. ¿Quién dio la orden de movilizar otra vez al Team Rocket?",
             "\\sh<b>Silver</b>: ¡Habla! ¿Dónde está Giovanni?")
replace_text(page1,
             "<b>Recluta</b>: No lo sé. A los reclutas solo nos dicen dónde estar y qué hacer.",
             "<b>Recluta</b>: ¿Giovanni? Nadie sabe dónde está. Desapareció hace años.")
silver_denial = replace_text(page1,
                             "<b>Silver</b>: ¿Atenea dirige todo esto?",
                             "<b>Silver</b>: No me tomes por idiota.")
page1.insert(silver_denial + 1,
             cloned_command(templates_for(page1)[:follow], 401,
                            ["El Team Rocket vuelve a moverse. Giovanni está detrás."]))
replace_text(page1,
             "<b>Recluta</b>: Atenea se encarga de la operación del pozo.",
             "<b>Recluta</b>: Los reclutas solo recibimos órdenes de los ejecutivos.")
replace_text(page1,
             "Pero la orden de reunirnos vino de más arriba.",
             "Nunca vemos al líder.")
replace_text(page1,
             "<b>Silver</b>: ¿De quién?",
             "<b>Silver</b>: Entonces Atenea sabe cómo encontrarlo.")
recruit_denial = replace_text(page1,
                              "<b>Recluta</b>: Ya te he dicho que no lo sé.",
                              "<b>Recluta</b>: Ella dirige la operación del pozo, nada más.")
page1.insert(recruit_denial + 1,
             cloned_command(templates_for(page1)[:follow], 401,
                            ["Te juro que no sé dónde está Giovanni."]))

player_turn = page1.index do |command|
  command_code(command) == 207 && command_params(command) == [7, 3]
end || raise("No se encontró la entrada del jugador en la primera página")
page1.insert(player_turn,
             *message_commands(page1, "Silver",
                               ["\\sh<b>Silver</b>: ¡Mientes! ¡Alguien de esta organización sabe dónde se esconde!"], 5))

replace_text(page1,
             "<b>Silver</b>: ¿Tú otra vez? No estoy de humor para perder el tiempo contigo.",
             "<b>Silver</b>: ¿Tú otra vez? Estaba a punto de hacerlo hablar.")
replace_text(page1,
             "<b>Silver</b>: Estaba a punto de averiguar quién está moviendo los hilos.",
             "<b>Silver</b>: Estaba a punto de descubrir dónde se esconde Giovanni.")

# Derrota: Silver pierde el control y amenaza al jugador antes de avanzar.
replace_text(page2,
             "<b>Silver</b>: No sabes cómo trabaja el Team Rocket.",
             "<b>Silver</b>: No entiendes cómo trabaja el Team Rocket.")
replace_text(page2,
             "<b>Silver</b>: Cuando un Pokémon deja de serles útil, lo apartan como si nunca hubiera significado nada.",
             "<b>Silver</b>: Cuando un Pokémon deja de serles útil, lo desechan como si nunca hubiera significado nada.")
replace_text(page2,
             "<b>Silver</b>: No voy a permitir que vuelva a ocurrir.",
             "\\sh<b>Silver</b>: ¡No voy a permitir que vuelva a ocurrir!")
replace_text(page2,
             "Aunque tenga que acabar con todos ellos yo solo.",
             "¡Aunque tenga que acabar con todos ellos yo solo!")

advance_index = page2.index do |command|
  command_code(command) == 209 && command_params(command)[0] == 7
end || raise("No se encontró el avance amenazante de Silver")
page2.insert(advance_index,
             *message_commands(page2, "Silver",
                               ["<b>Silver</b>: No pongas esa cara. Esto no ha terminado."], 5),
             *message_commands(page2, "Silver",
                               ["\\sh<b>Silver</b>: ¡Apártate ahora o te apartaré yo mismo!"], 5))
replace_text(page2, "<b>Blue</b>: ¡Silver!", "\\sh<b>Blue</b>: ¡Silver!")

# Blue conoce parte del pasado de Silver y ya conoció al protagonista en Malva.
replace_text(page2,
             "<b>Silver</b>: No sabes lo que me hicieron.",
             "<b>Silver</b>: Tú no estuviste allí desde el principio. No sabes todo lo que me hicieron.")

blue_here = text_index(page2, "<b>Blue</b>: Lo sé. Por eso estoy aquí.")
blue_erase = (blue_here...page2.length).find { |index| command_code(page2[index]) == 235 }
blue_wait = (blue_erase...page2.length).find { |index| command_code(page2[index]) == 106 }
page2.insert(blue_wait + 1,
             *message_commands(page2, "Blue",
                               ["<b>Blue</b>: Cada vez que alguien menciona a Giovanni, dejas de pensar con claridad."], 8),
             *message_commands(page2, "Silver",
                               ["<b>Silver</b>: No vuelvas a decirme cómo debo enfrentarme a él."], 8),
             *message_commands(page2, "Blue",
                               ["<b>Blue</b>: Entonces deja de comportarte exactamente como él te enseñó."], 8))

[
  "<b>Blue</b>: Tú debes de ser \\PN."
].each do |old_text|
  while page2.any? { |command| [101, 401].include?(command_code(command)) && command_params(command)[0] == old_text }
    replace_text(page2, old_text,
                 "<b>Blue</b>: Vaya, \\PN. No esperaba volver a encontrarte tan pronto.")
  end
end
[
  "He oído lo que ocurrió en el Pozo Slowpoke. Al parecer, te enfrentaste a Atenea y ayudaste a expulsar al Team Rocket."
].each do |old_text|
  while page2.any? { |command| [101, 401].include?(command_code(command)) && command_params(command)[0] == old_text }
    replace_text(page2, old_text,
                 "Silver, te presento a \\PN. Nos conocimos en Ciudad Malva.")
  end
end
[
  "No está nada mal para alguien que acaba de empezar su aventura."
].each do |old_text|
  while page2.any? { |command| [101, 401].include?(command_code(command)) && command_params(command)[0] == old_text }
    replace_text(page2, old_text,
                 "Antes habéis mencionado a Atenea. ¿Qué ocurrió en el Pozo Slowpoke?")
  end
end

replace_text(page2,
             "<b>Blue</b>: No te confíes, \\PN. Atenea no es la única persona peligrosa dentro de la organización.",
             "<b>Blue</b>: Así que Atenea dirigía la operación del pozo…")
replace_text(page2,
             "<b>Blue</b>: Si el Team Rocket está reuniendo otra vez a sus miembros, las colas de Slowpoke solo son el principio.",
             "<b>Blue</b>: Si están reuniendo otra vez a sus miembros, las colas de Slowpoke solo son el principio.")
replace_text(page2,
             "<b>Silver</b>: Encontraré al responsable de todo esto.",
             "<b>Silver</b>: Encontraré a Giovanni.")
replace_text(page2,
             "<b>Silver</b>: Y cuando lo haga, el Team Rocket dejará de existir.",
             "\\sh<b>Silver</b>: ¡Y cuando lo haga, el Team Rocket dejará de existir!")
replace_text(page2,
             "<b>Blue</b>: Pero si realmente quisiera hacerte daño, no se habría marchado así.",
             "<b>Blue</b>: No excuses lo que acaba de hacer. Cuando oye el nombre de Giovanni, deja de pensar con claridad.")

FileUtils.mkdir_p(BACKUP_DIR)
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
backup_path = File.join(BACKUP_DIR, "Map106_before_giovanni_#{timestamp}.rxdata")
File.binwrite(backup_path, raw)

updated = Marshal.dump(map)
File.binwrite(MAP_PATH, updated)

# Verificación inmediata del archivo reserializado.
verified = Marshal.load(File.binread(MAP_PATH))
verified_event = ivar(verified, :@events)[8]
raise "La verificación perdió el evento 8" unless verified_event
raise "La verificación alteró las dimensiones del mapa" unless ivar(verified, :@width) == 130 && ivar(verified, :@height) == 60
raise "La verificación alteró el número de eventos" unless ivar(verified, :@events).length == ivar(map, :@events).length

puts "Map106 actualizado correctamente."
puts "Copia de seguridad: #{backup_path}"
