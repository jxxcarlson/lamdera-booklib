module Examples exposing (colors)

import Time


colors =
    [ c1, c2, c3, c4, c5, c6 ]


c1 =
    { content = "alizarin yellow", dateTime = june }


c2 =
    { content = "brown umber", dateTime = july }


c3 =
    { content = "yellow ochre", dateTime = august }


c4 =
    { content = "pthalo blue", dateTime = september }


c5 =
    { content = "french yellow", dateTime = october }


c6 =
    { content = "alizarin crimson, cadmium purple", dateTime = november }


june =
    Time.millisToPosix 1622591999000


july =
    Time.millisToPosix 1625183999000


august =
    Time.millisToPosix 1627862399000


september =
    Time.millisToPosix 1630540799000


october =
    Time.millisToPosix 1633132799000


november =
    Time.millisToPosix 1635811199000
