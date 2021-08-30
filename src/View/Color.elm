module View.Color exposing
    ( black
    , blue
    , blueGray
    , darkBlue
    , darkRed
    , lightBlue
    , lightBlue2
    , lightGray
    , medBlue
    , medGray
    , paleBlue
    , paleBlueGray
    , paleGray
    , palePink
    , paleViolet
    , red
    , transparentBlue
    , veryPaleBlue
    , violet
    , white
    )

import Element as E


lightBlue2 : E.Color
lightBlue2 =
    E.rgb255 160 160 200


white : E.Color
white =
    E.rgb 255 255 255


lightGray : E.Color
lightGray =
    gray 0.9


paleGray : E.Color
paleGray =
    gray 0.94


medGray : E.Color
medGray =
    gray 0.5


black : E.Color
black =
    E.rgb255 20 20 20


red : E.Color
red =
    E.rgb255 255 0 0


darkRed : E.Color
darkRed =
    E.rgb255 140 0 0


palePink =
    E.rgb255 255 230 230


blue : E.Color
blue =
    E.rgb255 0 0 140


darkBlue : E.Color
darkBlue =
    E.rgb255 0 0 200


medBlue : E.Color
medBlue =
    E.rgb255 93 98 252


blueGray : E.Color
blueGray =
    E.rgb255 140 140 210


paleBlueGray : E.Color
paleBlueGray =
    E.rgb255 220 220 240


lightBlue : E.Color
lightBlue =
    E.rgb255 182 184 250


paleBlue : E.Color
paleBlue =
    E.rgb255 217 218 252


veryPaleBlue : E.Color
veryPaleBlue =
    E.rgb255 240 240 250


transparentBlue : E.Color
transparentBlue =
    E.rgba 0.9 0.9 1 0.9


paleViolet : E.Color
paleViolet =
    E.rgb255 225 225 255


violet : E.Color
violet =
    E.rgb255 200 160 250


gray : Float -> E.Color
gray g =
    E.rgb g g g
