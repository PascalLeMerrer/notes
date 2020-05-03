module Components.Stylesheet exposing (all)

import Components.Colors exposing (darkerGrey, red)
import Css exposing (Style, absolute, alignItems, auto, border3, borderBottom3, bottom, center, column, cursor, displayFlex, flex, flexBasis, flexDirection, flexGrow, flexShrink, flexStart, fontFamilies, height, justifyContent, margin, marginBottom, num, padding, paddingLeft, paddingRight, pct, pointer, position, px, relative, right, row, solid, stretch, transform, translate, translate2, width)
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
        , margin (px 5)
        , padding (px 5)
        ]
    , class "debug"
        [ border3 (px 3) solid red
        ]
    , class "fill-height"
        [ flex (num 1)
        ]
    , class "header"
        [ displayFlex
        , flexDirection row
        , alignItems center
        , borderBottom3 (px 1) solid darkerGrey
        , marginBottom (px 10)
        ]
    , class "vertical-container"
        [ displayFlex
        , flexDirection column
        , justifyContent flexStart
        , height (pct 100)
        , alignItems stretch
        ]
    , class "plus-button-container"
        [ position absolute
        , bottom (px 0)
        , right (px 0)
        , transform (translate2 (pct -50) (pct -100))
        ]
    , class "selected-note"
        [ padding (px 5)
        ]
    , class "clickable"
        [ cursor pointer
        ]
    , class "note-title"
        [ paddingLeft (px 10)
        , paddingRight (px 10)
        ]
    ]
