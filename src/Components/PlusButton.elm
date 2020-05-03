module Components.PlusButton exposing (view)

import Color exposing (black, green, white)
import Html.Styled exposing (Html, div, fromUnstyled)
import Html.Styled.Attributes exposing (class)
import TypedSvg as Svg
import TypedSvg.Attributes exposing (fill, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (cx, cy, height, r, rx, width, x, y)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (Paint(..), Transform(..))


view : Html msg
view =
    div [ class "plus-button-container" ]
        [ fromUnstyled <|
            Svg.svg
                [ width buttonDiameter
                , height buttonDiameter
                , viewBox 0 0 buttonDiameter buttonDiameter
                ]
                [ Svg.circle
                    [ cx buttonRadius
                    , cy buttonRadius
                    , r buttonRadius
                    , fill <| Paint green
                    ]
                    []
                , viewRectangle [ Rotate 90 buttonRadius buttonRadius ] -- rotation in degrees + coordinates of the rotation center
                , viewRectangle []
                ]
        ]


viewRectangle : List Transform -> Svg msg
viewRectangle transformations =
    Svg.rect
        [ width barLength
        , height barWidth
        , fill <| Paint white
        , x <| (buttonDiameter - barLength) / 2
        , y (buttonRadius - barWidth / 2)
        , rx 3
        , transform transformations
        ]
        []


buttonDiameter : Float
buttonDiameter =
    40


buttonRadius : Float
buttonRadius =
    buttonDiameter / 2


barWidth : Float
barWidth =
    4


barLength : Float
barLength =
    20
