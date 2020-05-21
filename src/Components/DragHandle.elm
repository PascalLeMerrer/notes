module Components.DragHandle exposing (view)

import Color exposing (charcoal, lightCharcoal)
import Html.Styled exposing (Html, fromUnstyled)
import TypedSvg as Svg exposing (g, rect)
import TypedSvg.Attributes exposing (class, fill, viewBox)
import TypedSvg.Attributes.InPx exposing (height, rx, ry, width, x, y)
import TypedSvg.Types exposing (Paint(..), Transform(..))


view : Html msg
view =
    Svg.svg
        [ viewBox 0 0 handleWidth handleHeight
        , width handleWidth
        , height handleHeight
        , class [ "draghandle" ]
        ]
        [ g [ fill <| Paint lightCharcoal ]
            (List.map drawSquare coordinates)
        ]
        |> fromUnstyled


coordinates =
    [ ( 2, 0 )
    , ( 2, 6 )
    , ( 2, 12 )
    , ( 2, 18 )
    , ( 9, 0 )
    , ( 9, 6 )
    , ( 9, 12 )
    , ( 9, 18 )
    ]


drawSquare ( x_, y_ ) =
    rect [ x x_, y y_, width 4, height 4, rx 1, ry 1 ] []


handleWidth : Float
handleWidth =
    18


handleHeight : Float
handleHeight =
    22
