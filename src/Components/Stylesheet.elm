module Components.Stylesheet exposing (all)

import Components.Colors exposing (darkerGrey, red)
import Css exposing (Style, absolute, alignItems, auto, border3, bottom, column, cursor, displayFlex, flex, flexBasis, flexDirection, flexGrow, flexShrink, flexStart, fontFamilies, height, justifyContent, margin, num, padding, pct, pointer, position, px, relative, right, solid, stretch, transform, translate, translate2, width)
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
    , class "debug"
        [ border3 (px 3) solid red
        ]
    , class "fill-height"
        [ flex (num 1)
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
        [ cursor pointer
        , padding (px 5)
        ]
    ]
