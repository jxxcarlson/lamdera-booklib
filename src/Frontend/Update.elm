module Frontend.Update exposing (updateWithViewport)

import Element
import Types exposing (..)


updateWithViewport vp model =
    let
        w =
            round vp.viewport.width

        h =
            round vp.viewport.height

        device =
            Element.classifyDevice { width = w, height = h }

        viewMode =
            case device.class of
                Element.Phone ->
                    SmallView

                _ ->
                    LargeView
    in
    ( { model
        | windowWidth = w
        , windowHeight = h
        , device = device.class
        , viewMode = viewMode
      }
    , Cmd.none
    )
