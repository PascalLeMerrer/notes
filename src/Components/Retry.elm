module Components.Retry exposing (..)

import Html.Styled exposing (Html, button, div, p, text)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (onClick)


view : String -> msg -> Html msg
view errorLabel msg =
    div [ class "retry" ]
        [ p [ class "retry-label" ] [ text errorLabel ]
        , button [ class "retry-button", onClick msg ] [ text "Retry" ]
        ]
