module View.Common.Indicator exposing (indicator)

import Element
import Svg exposing (rect, svg)
import Svg.Attributes as SA


indicator barWidth barHeight color fraction =
    Element.html (indicator_ barWidth barHeight color fraction)


indicator_ barWidth barHeight color fraction =
    svg
        [ SA.height <| String.fromInt barHeight
        ]
        [ horizontalBar barWidth barHeight "black" 1.0
        , horizontalBar barWidth barHeight color fraction
        ]


horizontalBar barWidth barHeight color fraction =
    svg
        [ SA.height <| String.fromInt (barHeight + 2) ]
        [ hRect barWidth barHeight color fraction ]


hRect barWidth barHeight color fraction =
    rect
        [ SA.width <| String.fromFloat <| fraction * barWidth
        , SA.height <| String.fromInt barHeight
        , SA.fill color
        ]
        []
