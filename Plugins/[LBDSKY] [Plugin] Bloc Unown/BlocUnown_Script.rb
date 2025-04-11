################################################################
#                          Bloc Unown                          #
#                        Autor : Bezier                        #
#                                                              #
# Script plug&play para Pokémon Essentials (v 16.2 ~ 16.3)     #
# Controla los Unown AVISTADOS y permite componer una palabra  #
# mediante un interfaz que podrá ser consultada desde eventos  #
#                                                              #
# Si se añade el script en una versión avanzada del juego, no  #
# hay problema con los Unown ya avistados, el script los       #
# buscará y 
################################################################


# Variable en la que se almacena la palabra Unown
# Se puede cambiar sin problema
UNOWN_WORD_VARIABLE = 59


# Permite consultar la palabra desde eventos de forma cómoda
def unownWord
  $game_variables[UNOWN_WORD_VARIABLE]="" if $game_variables[UNOWN_WORD_VARIABLE].is_a?(Numeric)
  return $game_variables[UNOWN_WORD_VARIABLE].to_s
end

# Función para mostrar el interfaz del Bloc de Unown
def showBlocUnown
  pbFadeOutIn(99990)  {
    scene=BlocUnownScene.new
    scene.showScene
  }
end

# ID del Unown en los PBS
UNWON_ID=201

# Formas de los Unown
UNOWN_SHAPE="ABCDEFGHIJKLMNOPQRSTUVWXYZ?!"

# Número máximo de letras que tiene la palabra Unown
# Se puede cambiar pero habrá que editar el interfaz
UNOWN_WORD_LENGTH=10

# Interfaz para componer la palabra Unown
class BlocUnownScene

  # Posición del primer carácter de la palabra
  WORD_XY=[110,104]
  # Separación de las letras en la palabra
  # Si se aumenta UNOWN_WORD_LENGTH, habrá que reducir la separación entre letras
  LETTER_SEPARATION=45

  # Posición del primer sprite del Unown
  UNOWN_FIRST_XY=[115,183]
  # Separación de los sprites [x, y]
  UNOWN_SEPARATION=[67,64]
  # Número de sprites por fila
  NUM_COLUMNS=7

  def initialize
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}

    # Carga las formas de Unown avistadas
    loadForms

    # Sprites de la palabra compuesta
    @wordSprites=[]

    # Índice de forma seleccionada
    @selIdx=0
    # Contiene las posiciones de los sprites de las formas
    @positions=[]

    @sprites["bg"]=IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap("Graphics/Plugins/BlocUnown/bg")

    x=UNOWN_FIRST_XY[0]
    y=UNOWN_FIRST_XY[1]

    @sprites["cursor"]=AnimatedSprite.create("Graphics/Plugins/BlocUnown/cursor",2,8,@viewport)
    @sprites["cursor"].src_rect.width=@sprites["cursor"].bitmap.width/2
    @sprites["cursor"].ox=@sprites["cursor"].src_rect.width/2
    @sprites["cursor"].oy=@sprites["cursor"].src_rect.height/2

    # Carga los sprites de las formas de los Unown
    UNOWN_SHAPE.length.times do |i|
      if @forms[i]
        @sprites["form#{i}"]=PokemonSpeciesIconSprite.new(nil,@viewport)
        @sprites["form#{i}"].pbSetParams(:UNOWN, 0, i)
        @sprites["form#{i}"].form=i
        @sprites["form#{i}"].x=x+1
        @sprites["form#{i}"].y=y-6
        @sprites["form#{i}"].ox=@sprites["form#{i}"].bitmap.width/4
        @sprites["form#{i}"].oy=@sprites["form#{i}"].bitmap.height/2
      end
      @positions.push([x,y])
      x+=UNOWN_SEPARATION[0]
      if i>0 && @positions.length%NUM_COLUMNS==0
        x=UNOWN_FIRST_XY[0]
        y+=UNOWN_SEPARATION[1]
      end
    end

    moveCursor(0)

    # Carga los sprites de la palabra actual
    @ommitLetter=true
    unownWord.length.times do |i|
      ch=unownWord[i].chr
      idx=UNOWN_SHAPE.index(ch)
      if idx>=0
        addLetter(idx)
      end
    end
    @ommitLetter=false
  end

  # Carga las formas vistas de Unown
  def loadForms
    @forms={}
    if $player.pokedex.seen?(:UNOWN)
      UNOWN_SHAPE.length.times do |i|
        @forms[i] = true if $player.pokedex.seen_form?(:UNOWN, 0, i) 
      end
    end
  end


  # Añade el sprite de la letra al panel superior y la concatena a la palabra del Bloc 
  def addLetter(idx)
    if idx>=0 && idx<@positions.length && @wordSprites.length<UNOWN_WORD_LENGTH && @sprites["form#{idx}"]
      x=@wordSprites.length==0 ? WORD_XY[0] : @wordSprites[@wordSprites.length-1].x+LETTER_SEPARATION
      y=WORD_XY[1]
      key="letter#{@wordSprites.length}"
      @sprites[key]=IconSprite.new(x,y,@viewport)
      path=idx==0 ? "Graphics/Pokemon/Icons/UNOWN" : "Graphics/Pokemon/Icons/UNOWN_#{idx}"
      @sprites[key].setBitmap(path)
      @sprites[key].src_rect.width=@sprites[key].bitmap.width/2
      @sprites[key].ox=@sprites[key].src_rect.width/2
      @sprites[key].oy=@sprites[key].src_rect.height/2
      @wordSprites.push(@sprites[key])
      if !@ommitLetter
        $game_variables[UNOWN_WORD_VARIABLE]+=UNOWN_SHAPE[idx].chr
      end
    end
  end
  
  # Borra la última letra
  def backspace
    if @wordSprites.length>0
      idx=@wordSprites.length-1
      @sprites["letter#{idx}"].dispose
      @sprites["letter#{idx}"]=nil
      @wordSprites.pop
      if $game_variables[UNOWN_WORD_VARIABLE].length==1
        $game_variables[UNOWN_WORD_VARIABLE]=""
      else
        $game_variables[UNOWN_WORD_VARIABLE]=$game_variables[UNOWN_WORD_VARIABLE][0..$game_variables[UNOWN_WORD_VARIABLE].length-2]
      end
    end
  end
  
  # Borra toda la palabra
  def clearWord
    if @wordSprites.length>0
      if Kernel.pbConfirmMessage(_INTL("¿Quieres borrar la palabra Unown?"))
        $game_variables[UNOWN_WORD_VARIABLE]=""
        num=@wordSprites.length
        num.times do |i|
          @sprites["letter#{i}"].dispose
          @sprites["letter#{i}"]=nil
        end
        @wordSprites.clear
      end
    end
  end

  # Mueve el cursor a la posición indicada
  def moveCursor(idx)
    if idx>=0 && idx<@positions.length
      @sprites["cursor"].x=@positions[idx][0]
      @sprites["cursor"].y=@positions[idx][1]
      @selIdx=idx
      if @sprites["form#{@selIdx}"]
        @sprites["cursor"].play
      else
        @sprites["cursor"].stop
        @sprites["cursor"].frame=0
      end
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def showScene
    update
    Graphics.update
    pbWait(1)
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::USE)
        addLetter(@selIdx)
      elsif Input.trigger?(Input::BACK)
        break
      elsif Input.trigger?(Input::ACTION)
        backspace
      elsif Input.trigger?(Input::SPECIAL)
        clearWord
      elsif Input.trigger?(Input::LEFT)
        moveCursor(@selIdx-1)
      elsif Input.trigger?(Input::RIGHT)
        moveCursor(@selIdx+1)
      elsif Input.trigger?(Input::UP)
        moveCursor(@selIdx-NUM_COLUMNS)
      elsif Input.trigger?(Input::DOWN)
        moveCursor(@selIdx+NUM_COLUMNS)
      end
    end
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end