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

def message_commands(list, portrait, lines, wait_frames)
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

raw = File.binread(MAP_PATH)
map = Marshal.load(raw)
event = ivar(map, :@events)[8] || raise("Map106 no contiene el evento 8")
pages = ivar(event, :@pages)
raise "El evento 8 no conserva sus tres páginas" unless pages.length == 3
page1 = ivar(pages[0], :@list)
page2 = ivar(pages[1], :@list)

# El nombre de Giovanni permanece oculto. Todos hablan del jefe o de él.
replace_text(page1, "\\sh<b>Silver</b>: ¡Habla! ¿Dónde está Giovanni?",
                    "\\sh<b>Silver</b>: ¡Habla! ¿Dónde se esconde vuestro jefe?")
replace_text(page1, "<b>Recluta</b>: ¿Giovanni? Nadie sabe dónde está. Desapareció hace años.",
                    "<b>Recluta</b>: Nadie sabe dónde está. Desapareció hace años.")
replace_text(page1, "El Team Rocket vuelve a moverse. Giovanni está detrás.",
                    "El Team Rocket vuelve a moverse. Él está detrás de esto.")
replace_text(page1, "Te juro que no sé dónde está Giovanni.",
                    "Te juro que no sé dónde está.")
replace_text(page1, "<b>Silver</b>: ¿Tú otra vez? Estaba a punto de hacerlo hablar.",
                    "<b>Silver</b>: ¿Tú otra vez? No te metas en esto.")
replace_text(page1, "<b>Silver</b>: Genial… Se ha escapado.",
                    "<b>Silver</b>: ¡Maldición! Se ha escapado.")
replace_text(page1, "<b>Silver</b>: Estaba a punto de descubrir dónde se esconde Giovanni.",
                    "<b>Silver</b>: Estaba a punto de descubrir dónde se esconde el jefe.")
replace_text(page1,
             "<b>Silver</b>: Si vas a seguir interponiéndote en mi camino, demuéstrame que al menos puedes defenderte.",
             "<b>Silver</b>: Ya que no piensas apartarte, comprobaré si eres fuerte o solo otro estorbo.")

# Silver se sorprende al reconocer a Blue antes de que ella lo confronte.
blue_reproach = text_index(page2, "<b>Blue</b>: Después de todo este tiempo, sigues intentando resolverlo todo a golpes.")
blue_picture = (blue_reproach - 1).downto(0).find { |index| code(page2[index]) == 231 }
raise "No se encontró el retrato previo al reproche de Blue" unless blue_picture
page2.insert(blue_picture,
             *message_commands(page2, "Silver", ["<b>Silver</b>: ¿Blue…? ¿Qué haces aquí?"], 8))

replace_text(page2, "<b>Blue</b>: Después de todo este tiempo, sigues intentando resolverlo todo a golpes.",
                    "<b>Blue</b>: Evitar que cometas otra estupidez. Parece que he llegado justo a tiempo.")
replace_text(page2, "<b>Silver</b>: No necesito que vengas a salvarme.",
                    "<b>Silver</b>: No necesito que me vigiles.")
replace_text(page2, "<b>Blue</b>: Tranquilo. No he venido a salvarte.",
                    "<b>Blue</b>: No te estoy vigilando.")
replace_text(page2, "He venido para evitar que ellos sigan decidiendo por ti.",
                    "Intento evitar que vuelvas a convertirte en lo que ellos querían.")
replace_text(page2, "<b>Blue</b>: Sé más de lo que crees.",
                    "<b>Blue</b>: Sé lo suficiente. Estuve allí contigo, ¿recuerdas?")
replace_text(page2, "Y también sé que convertirte en lo que ellos querían no va a arreglar nada.",
                    "No tienes que demostrarme lo que te hicieron.")
replace_text(page2, "<b>Silver</b>: No pienso quedarme quieto mientras hacen lo mismo con otros Pokémon.",
                    "<b>Silver</b>: Entonces sabes por qué no voy a detenerme.")
replace_text(page2, "<b>Blue</b>: Lo sé. Por eso estoy aquí.",
                    "<b>Blue</b>: Lo sé. Pero atacar a cualquiera que se cruce en tu camino")

blue_line = text_index(page2, "<b>Blue</b>: Lo sé. Pero atacar a cualquiera que se cruce en tu camino")
page2.insert(blue_line + 1,
             clone_command(templates(page2)[:follow], 401, ["no te acerca a él."]))

# Se elimina la explicación redundante de Blue y se conserva el choque final.
redundant_text = "<b>Blue</b>: Cada vez que alguien menciona a Giovanni, dejas de pensar con claridad."
redundant_index = text_index(page2, redundant_text)
block_start = redundant_index.downto(0).find { |index| code(page2[index]) == 231 }
block_end = (redundant_index...page2.length).find { |index| code(page2[index]) == 106 }
raise "No se pudo delimitar el bloque redundante de Blue" unless block_start && block_end
page2.slice!(block_start..block_end)

replace_text(page2, "<b>Silver</b>: No vuelvas a decirme cómo debo enfrentarme a él.",
                    "<b>Silver</b>: No vuelvas a decirme cómo debo enfrentarme a ese hombre.")
replace_text(page2, "<b>Blue</b>: Entonces deja de comportarte exactamente como él te enseñó.",
                    "<b>Blue</b>: Entonces deja de comportarte como te enseñaron.")

# Las dos ramas de género eran innecesarias y provocaban texto duplicado.
condition_start = page2.index do |command|
  code(command) == 111 && params(command) == [1, 51, 0, 1, 0]
end || raise("No se encontró la rama duplicada de Blue")
picture_start = condition_start.downto(0).find { |index| code(page2[index]) == 231 }
outer_end = (condition_start...page2.length).find do |index|
  code(page2[index]) == 412 && ivar(page2[index], :@indent) == 0
end
erase_end = ((outer_end + 1)...page2.length).find { |index| code(page2[index]) == 235 }
raise "No se pudo delimitar la presentación duplicada de Blue" unless picture_start && outer_end && erase_end

single_conversation = []
single_conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Vaya, \\PN. No esperaba volver a encontrarte aquí."], 8))
single_conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Nos conocimos en Ciudad Malva.",
   "Estaba siguiendo el rastro de este cabezota."], 8))
single_conversation.concat(message_commands(page2, "Blue",
  ["<b>Blue</b>: Antes habéis mencionado a Atenea.",
   "¿Qué ocurrió en el Pozo Slowpoke?"], 14))
page2[picture_start..erase_end] = single_conversation

replace_text(page2, "<b>Blue</b>: Así que Atenea dirigía la operación del pozo…",
                    "<b>Blue</b>: Entiendo. Así que ella dirigía la operación del pozo.")
replace_text(page2, "<b>Blue</b>: Si están reuniendo otra vez a sus miembros, las colas de Slowpoke solo son el principio.",
                    "<b>Blue</b>: Si el Team Rocket está reuniendo otra vez a sus miembros, las colas de Slowpoke solo son el principio.")
replace_text(page2, "<b>Silver</b>: Te debo una, Blue. Pero esto es asunto mío.",
                    "<b>Silver</b>: Te debo una, Blue. Pero esto sigue siendo asunto mío.")
replace_text(page2, "<b>Silver</b>: Encontraré a Giovanni.",
                    "<b>Silver</b>: Encontraré a ese hombre.")

# Blue no justifica la amenaza de Silver y evita nombrar al jefe.
replace_text(page2, "<b>Blue</b>: Sigues siendo igual de cabezota…",
                    "<b>Blue</b>: Silver nunca ha sabido disculparse.")
replace_text(page2, "<b>Blue</b>: Silver nunca ha sabido disculparse.",
                    "<b>Blue</b>: Su rabia no va dirigida contra ti, pero eso no justifica lo que acaba de hacer.")
# La sustitución anterior encuentra primero el texto recién cambiado. Se corrige el
# segundo mensaje mediante su posición relativa antes de establecer el cierre.
apology_messages = page2.each_index.select do |index|
  [101, 401].include?(code(page2[index])) &&
    params(page2[index])[0] == "<b>Blue</b>: Su rabia no va dirigida contra ti, pero eso no justifica lo que acaba de hacer."
end
if apology_messages.length == 1
  old_apology = page2.each_index.find do |index|
    [101, 401].include?(code(page2[index])) &&
      params(page2[index])[0] == "<b>Blue</b>: Silver nunca ha sabido disculparse."
  end
  params(page2[old_apology])[0] = "<b>Blue</b>: Su rabia no va dirigida contra ti, pero eso no justifica lo que acaba de hacer." if old_apology
end
replace_text(page2,
             "<b>Blue</b>: No excuses lo que acaba de hacer. Cuando oye el nombre de Giovanni, deja de pensar con claridad.",
             "<b>Blue</b>: Cuando sigue el rastro del jefe del Team Rocket, deja de pensar con claridad.")

# Normaliza los tres mensajes finales de Blue por orden para evitar duplicados.
final_blue_texts = [
  "<b>Blue</b>: Su rabia no va dirigida contra ti, pero eso no justifica lo que acaba de hacer.",
  "<b>Blue</b>: Su rabia no va dirigida contra ti, pero eso no justifica lo que acaba de hacer.",
  "<b>Blue</b>: Cuando sigue el rastro del jefe del Team Rocket, deja de pensar con claridad."
]
first_final = text_index(page2, final_blue_texts[0])
second_final = ((first_final + 1)...page2.length).find do |index|
  [101, 401].include?(code(page2[index])) && params(page2[index])[0] == final_blue_texts[1]
end
if second_final
  params(page2[first_final])[0] = "<b>Blue</b>: Silver nunca ha sabido disculparse."
end

FileUtils.mkdir_p(BACKUP_DIR)
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
backup_path = File.join(BACKUP_DIR, "Map106_before_continuity_refine_#{timestamp}.rxdata")
File.binwrite(backup_path, raw)
File.binwrite(MAP_PATH, Marshal.dump(map))

verified = Marshal.load(File.binread(MAP_PATH))
verified_event = ivar(verified, :@events)[8]
raise "La verificación perdió el evento 8" unless verified_event
raise "La verificación alteró las dimensiones" unless ivar(verified, :@width) == 130 && ivar(verified, :@height) == 60
raise "La verificación alteró el número de eventos" unless ivar(verified, :@events).length == ivar(map, :@events).length

puts "Map106 refinado correctamente."
puts "Copia de seguridad: #{backup_path}"
