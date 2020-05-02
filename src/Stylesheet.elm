module Stylesheet exposing (all)

import Colors exposing (darkerGrey)
import Css exposing (Style, border3, cursor, fontFamilies, margin, padding, pointer, px, solid)
import Css.Global exposing (Snippet, class, global)
import Html.Styled


all : Html.Styled.Html msg
all =
    global
        classes


classes : List Snippet
classes =
    [ class "body"
        [ fontFamilies [ "Verdana", "Arial" ]
        ]
    , class "card"
        [ border3 (px 1) solid darkerGrey
        , cursor pointer
        , margin (px 5)
        , padding (px 5)
        ]
    , class "selected-note"
        [ cursor pointer
        , margin (px 5)
        ]
    ]
