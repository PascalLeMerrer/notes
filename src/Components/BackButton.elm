module Components.BackButton exposing (view)

import Color exposing (black)
import Html.Styled exposing (Html, fromUnstyled)
import TypedSvg as Svg exposing (g, path)
import TypedSvg.Attributes exposing (class, fill, viewBox)
import TypedSvg.Attributes.InPx exposing (height, width)
import TypedSvg.Events exposing (onClick)
import TypedSvg.Types exposing (Paint(..), Transform(..))


view : msg -> Html msg
view message =
    Svg.svg
        [ viewBox 0 0 buttonWidth buttonHeight
        , width buttonWidth
        , height buttonHeight
        , onClick message
        , class [ "backButton" ]
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
    "M 0 12 L 12 24 L 18 24 L 9 15 L 36 15 L 36 9 L 9 9 L 18 0 L 12 0 Z"


buttonWidth : Float
buttonWidth =
    36


buttonHeight : Float
buttonHeight =
    24
