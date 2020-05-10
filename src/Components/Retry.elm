module Components.Retry exposing (..)

import Html.Styled exposing (Html, button, div, p, text)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (onClick)


view : String -> msg -> Html msg
view errorLabel msg =
    div [ class "vertically-centered fill-height" ]
        [ p [ class "horizontally-centered" ] [ text errorLabel ]
        , button [ class "horizontally-centered retry", onClick msg ] [ text "Retry" ]
        ]
