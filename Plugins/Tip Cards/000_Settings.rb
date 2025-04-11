module Settings
    #====================================================================================
    #=============================== Tip Cards Settings =================================
    #====================================================================================
    
        #--------------------------------------------------------------------------------
        #  Set the default background for tip cards.
        #  The files are located in Graphics/Pictures/Tip Cards
        #--------------------------------------------------------------------------------	
        TIP_CARDS_DEFAULT_BG            = "bg"

        #--------------------------------------------------------------------------------
        #  If set to true, if only one group is shown when calling pbRevisitTipCardsGrouped,
        #  the group header will still appear. Otherwise, the header won't appear.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_SINGLE_GROUP_SHOW_HEADER = false

        #--------------------------------------------------------------------------------
        #  If set to true, when the player uses the SPECIAL control, a list of all
        #  groups available to view will appear for the player to jump to one.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_GROUP_LIST = true

        #--------------------------------------------------------------------------------
        #  Set the default text colors
        #--------------------------------------------------------------------------------	
        TIP_CARDS_TEXT_MAIN_COLOR       = Color.new(80, 80, 88)
        TIP_CARDS_TEXT_SHADOW_COLOR     = Color.new(160, 160, 168)

        #--------------------------------------------------------------------------------
        #  Set the sound effect to play when showing, dismissing, and switching tip cards.
        #  For TIP_CARDS_SWITCH_SE, set to nil to use the default cursor sound effect.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_SHOW_SE               = "GUI menu open"
        TIP_CARDS_DISMISS_SE            = "GUI menu close"
        TIP_CARDS_SWITCH_SE             = nil

        #--------------------------------------------------------------------------------
        #  Define your tips in this hash. The :EXAMPLE describes what some of the 
        #  parameters do.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_CONFIGURATION = {
            :EXAMPLE => { # ID of the tip
                    # Required Settings
                    :Title => _INTL("Example Tip"),
                    :Text => _INTL("This is the text of the tip. You can include formatting."),
                    # Optional Settings
                    :Image => "example", # An image located in Graphics/Pictures/Tip Cards/Images
                    :ImagePosition => :Top, # Set to :Top, :Bottom, :Left, or :Right.
                        # If not defined, it will place wider images to :Top, and taller images to :Left.
                    :Background => "bg2", # A replacement background image located in Graphics/Pictures/Tip Cards
                    :YAdjustment => 0, # Adjust the vertical spacing of the tip's text (in pixels)
                    :HideRevisit => true # Set to true if you don't want the player to see the tip again when revisiting seen tips.
            },
            :CATCH => {
                :Title => _INTL("Catching Pokémon"),
                :Text => _INTL("This is the text of the tip. You catch Pokémon by throwing a <c2=0999367C><b>Poké Ball</b></c2> at them."),
                :Image => "catch",
                :Background => "bg2"
            },
            :CATCH2 => {
                :Title => _INTL("Catching Pokémon"),
                :Text => _INTL("This is the text of the tip with a bottom picture. You catch Pokémon by throwing a <c2=0999367C><b>Poké Ball</b></c2> at them."),
                :Image => "catch",
                :ImagePosition => :Bottom,
                :Background => "bg2"
				
				            },
            :CATCH3 => {
                :Title => _INTL("Base Secreta"),
                :Text => _INTL("Noah a preparado una <c2=0999367C><b>base secreta</b></c2>, en ella"),
                :Image => "catch",
                :ImagePosition => :Bottom,
                :Background => "bg2"
				
            },
            :ITEMS => {
                :Title => _INTL("Items"),
                :Text => _INTL("This is the text of the other tip. You may find items lying around."),
                :Image => "items",
                :YAdjustment => 64
            },
            :ITEMS2 => {
                :Title => _INTL("Items"),
                :Text => _INTL("This is the text of the other tip with a right picture. You may find items lying around."),
                :Image => "items",
                :ImagePosition => :Right,
                :YAdjustment => 64
            },
            :BOOK1PAGE1 => {
                :Title => _INTL("Pagina 1"),
                :Text => _INTL("<b>Claros Ocultos</b>.
En algunas zonas podrás encontrar estos <c2=0999367C><b>claros</b>."),
				:Image => "img1",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
            :BOOK1PAGE2 => {
                :Title => _INTL("Pagina 2"),
                :Text => _INTL("El Pokémon en su interior será mas poderoso de lo normal.
No podrás huir ni capturar al Pokémon Dominante. "),
				:Image => "img1",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
            :BOOK1PAGE3 => {
                :Title => _INTL("Pagina 3"),
                :Text => _INTL("Una vez <c2=0999367C><b>Derrotado</b></c2> al Pokémon, el nido no se volverá a activar. Además obtendrás recompensas si logras derrotarlo."),
				:Image => "img2",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
			:BOOK1PAGE4 => {
                :Title => _INTL("Pagina 1"),
                :Text => _INTL("<b>Misiones</b>.
En algunas ocasiones, encontrarás NPC con signos de exclamación sobre su cabeza."),
				:Image => "misiones",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
            :BOOK1PAGE5 => {
                :Title => _INTL("Pagina 2"),
                :Text => _INTL("Hablando con ellos, tendrás la opción de aceptar la misión."),
				:Image => "misiones2",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
            :BOOK1PAGE6 => {
                :Title => _INTL("Pagina 3"),
                :Text => _INTL("En el apartado 'Misiones', podrás ver los detalles y las recompensas de todas las misiones."),
				:Image => "misiones3",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
            :BOOK1PAGE7 => {
                :Title => _INTL("Pagina 4"),
                :Text => _INTL("Encontrarás diferentes símbolos, y cada uno de ellos tiene un significado."),
				:Image => "misiones4",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
            :BOOK1PAGE8 => {
                :Title => _INTL("Pagina 5"),
                :Text => _INTL("<b>Disponible</b>
Indica que la misión se puede aceptar."),
				:Image => "misiones5",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
            :BOOK1PAGE9 => {
                :Title => _INTL("Pagina 6"),
                :Text => _INTL("<b>Pendiente</b>
Indica que la misión ha sido aceptada, pero no finalizada."),
				:Image => "misiones6",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            },
            :BOOK1PAGE10 => {
                :Title => _INTL("Pagina 7"),
                :Text => _INTL("<b>Completada</b>
ndica que has cumplido la misión y está lista para ser finalizada."),
				:Image => "misiones7",
				:ImagePosition => :Bottom,
                :Background => "bg_book"
            }
        }

        TIP_CARDS_GROUPS = {
            :BEGINNER => {
                :Title => _INTL("Beginner Tips"),
                :Tips => [:CATCH, :CATCH2, :ITEMS, :ITEMS2]
            },
            :CATCHING => {
                :Title => _INTL("Catching Tips"),
                :Tips => [:CATCH, :CATCH2]
            },
            :ITEMS => {
                :Title => _INTL("Item Tips"),
                :Tips => [:ITEMS, :ITEMS2]
            },
            :BOOK1 => {
                :Title => _INTL("Book Alpha"),
                :Tips => [:BOOK1PAGE1, :BOOK1PAGE2, :BOOK1PAGE3, :BOOK1PAGE4]
            }
        }

end