module Components.DeleteButton exposing (view)

import Color exposing (black)
import Html.Styled exposing (Html, fromUnstyled)
import TypedSvg as Svg exposing (g, path)
import TypedSvg.Attributes exposing (fill, viewBox)
import TypedSvg.Attributes.InPx exposing (height, width)
import TypedSvg.Events exposing (onClick)
import TypedSvg.Types exposing (Paint(..), Transform(..))



-- TODO factorise with Back button


view : msg -> Html msg
view message =
    Svg.svg
        [ viewBox 0 0 buttonWidth buttonHeight
        , width buttonWidth
        , height buttonHeight
        , onClick message
        ]
        [ g []
            [ path
                [ TypedSvg.Attributes.d svgPath
                , fill <| Paint black
                ]
                []
            ]
        ]
        |> fromUnstyled


svgPath : String
svgPath =
    "M 2 1 L 14 13 L 13 14 L 1 2 Z M 1 13 L 13 1 L 14 2 L 2 14 Z"


buttonWidth : Float
buttonWidth =
    16


buttonHeight : Float
buttonHeight =
    15
