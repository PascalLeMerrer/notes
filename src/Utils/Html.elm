module Utils.Html exposing (..)

import Browser.Dom
import Html.Styled exposing (Html, fromUnstyled, text)
import Loading exposing (LoaderType(..), defaultConfig)
import Task


viewIf : Bool -> Html msg -> Html msg
viewIf condition html =
    if condition then
        html

    else
        noContent


noContent : Html msg
noContent =
    text ""


{-| Sets focus on an HTML element, then sends a msg when done (even if the element is not found)
-}
focusOn : String -> msg -> Cmd msg
focusOn elementId msg =
    Browser.Dom.focus elementId |> Task.attempt (\_ -> msg)
