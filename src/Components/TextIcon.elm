module Components.TextIcon exposing (view)

import Color exposing (darkCharcoal)
import Html.Styled exposing (Html, fromUnstyled)
import TypedSvg as Svg exposing (g, rect)
import TypedSvg.Attributes exposing (class, fill, viewBox)
import TypedSvg.Attributes.InPx exposing (height, rx, ry, width, x, y)
import TypedSvg.Types exposing (Paint(..), Transform(..))


view : Html msg
view =
    Svg.svg
        [ viewBox 0 0 buttonWidth buttonHeight
        , width buttonWidth
        , height buttonHeight
        , class [ "button-icon" ]
        ]
        [ g [ fill <| Paint darkCharcoal ]
            [ rect [ x 2, y 1, width 24, height 4, rx 1, ry 1 ] []
            , rect [ x 2, y 7, width 24, height 4, rx 1, ry 1 ] []
            , rect [ x 2, y 13, width 16, height 4, rx 1, ry 1 ] []
            ]
        ]
        |> fromUnstyled


buttonWidth : Float
buttonWidth =
    25


buttonHeight : Float
buttonHeight =
    18
