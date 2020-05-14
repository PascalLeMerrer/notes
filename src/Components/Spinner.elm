module Components.Spinner exposing (..)

import Html.Styled exposing (Html, div, fromUnstyled)
import Html.Styled.Attributes exposing (class)
import Loading exposing (LoaderType(..), defaultConfig)


view : Html msg
view =
    div
        [ class "spinner" ]
        [ div
            []
            [ Loading.render
                Bars
                { defaultConfig | color = "#333" }
                Loading.On
                |> fromUnstyled
            ]
        ]
