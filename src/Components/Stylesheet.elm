module Components.Stylesheet exposing (all)

import Components.Colors exposing (averageGreen, averageGrey, darkerGrey, lightGreen, red, white)
import Css exposing (Style, absolute, alignItems, alignSelf, auto, backgroundColor, bold, border3, borderBottom3, borderColor, borderRadius, bottom, center, color, column, cursor, displayFlex, fixed, flex, flexBasis, flexDirection, flexEnd, flexGrow, flexShrink, flexStart, fontFamilies, fontSize, fontWeight, height, justifyContent, left, lineThrough, margin, marginBottom, marginLeft, marginRight, marginTop, num, padding, paddingBottom, paddingLeft, paddingRight, paddingTop, pct, pointer, position, px, relative, rem, right, row, solid, stretch, textDecorationLine, transform, translate, translate2, width)
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
    , class "checked-item"
        [ color averageGrey
        , textDecorationLine lineThrough
        ]
    , class "clickable"
        [ cursor pointer
        ]
    , class "delete-button"
        [ marginLeft (px 20)
        , marginRight (px 20)
        ]
    , class "message-toast-container"
        [ left (px 20)
        ]
    , class "debug"
        [ border3 (px 3) solid red
        ]
    , class "fill-height"
        [ flex (num 1)
        ]
    , class "flex-container"
        [ displayFlex
        ]
    , class "header"
        [ displayFlex
        , flexDirection row
        , alignItems center
        , justifyContent flexStart
        , borderBottom3 (px 1) solid darkerGrey
        , marginBottom (px 10)
        ]
    , class "note-title"
        [ marginLeft (px 20)
        , marginRight (px 10)
        , displayFlex
        , flexGrow (num 1)
        ]
    , class "placeholder"
        [ color averageGrey ]
    , class "plus-button-container"
        [ position fixed
        , bottom (px 0)
        , right (px 0)
        , transform (translate2 (pct -50) (pct -100))
        ]
    , class "horizontally-centered"
        [ marginLeft auto
        , marginRight auto
        ]
    , class "retry"
        [ backgroundColor lightGreen
        , color white
        , paddingTop (px 10)
        , paddingBottom (px 10)
        , paddingLeft (px 20)
        , paddingRight (px 20)
        , fontSize (rem 1.5)
        , borderRadius (px 5)
        , borderColor averageGreen
        , cursor pointer
        ]
    , class "selected-note"
        [ padding (px 5)
        ]
    , class "selected-note"
        [ alignSelf center
        ]
    , class "text-editor"
        [ fontFamilies [ "Verdana", "Arial" ]
        , fontSize (rem 1)
        , padding (px 5)
        ]
    , class "title-editor"
        [ fontSize (rem 1)
        , fontWeight bold
        , marginLeft (px 6)
        , marginTop (px 16)
        , marginBottom (px 16)
        , displayFlex
        , flexGrow (num 1)
        ]
    , class "vertically-centered"
        [ displayFlex
        , flexDirection column
        , justifyContent center
        ]
    , class "vertical-container"
        [ displayFlex
        , flexDirection column
        , justifyContent flexStart
        , height (pct 100)
        , alignItems stretch
        ]
    ]
