module Components.Stylesheet exposing (all)

import Components.Colors exposing (averageGreen, averageGrey, darkerGrey, lightGreen, white)
import Css exposing (Style, alignItems, auto, backgroundColor, bold, border3, borderBottom3, borderColor, borderRadius, bottom, center, color, column, cursor, displayFlex, em, fixed, flex, flexDirection, flexGrow, flexStart, fontFamilies, fontSize, fontWeight, height, justifyContent, margin, marginBottom, marginLeft, marginRight, marginTop, num, padding, paddingBottom, paddingLeft, paddingRight, paddingTop, pct, pointer, position, px, rem, right, row, solid, stretch, transform, translate2)
import Css.Global exposing (Snippet, class, global)
import Html.Styled


all : Html.Styled.Html msg
all =
    global
        classes


classes : List Snippet
classes =
    [ class "backButton"
        [ cursor pointer
        ]
    , class "body"
        [ alignItems stretch
        , displayFlex
        , flexDirection column
        , fontFamilies [ "Verdana", "Arial" ]
        , height (pct 100)
        , justifyContent flexStart
        ]
    , class "card"
        [ border3 (px 1) solid darkerGrey
        , cursor pointer
        , margin (px 5)
        , padding (px 5)
        ]
    , class "card-item"
        [ cursor pointer
        ]
    , class "deleteButton"
        [ cursor pointer
        , marginLeft (px 20)
        , marginRight (px 20)
        ]
    , class "editor"
        [ alignItems stretch
        , cursor pointer
        , displayFlex
        , flex (num 1)
        , flexDirection column
        , height (pct 100)
        , justifyContent flexStart
        , margin (px 5)
        , padding (px 5)
        , border3 (px 1) solid darkerGrey
        ]
    , class "editor-header"
        [ alignItems center
        , borderBottom3 (px 1) solid darkerGrey
        , flexDirection row
        , justifyContent flexStart
        , marginBottom (px 10)
        , displayFlex
        ]
    , class "editor-item"
        [ cursor pointer
        ]
    , class "editor-note"
        [ alignItems stretch
        , displayFlex
        , flex (num 1)
        , flexDirection column
        , height (pct 100)
        , justifyContent flexStart
        ]
    , class "editor-text-line"
        [ marginTop (em 0.5)
        , marginBottom (em 0.5)
        ]
    , class "editor-text-readonly"
        [ alignItems stretch
        , cursor pointer
        , displayFlex
        , flex (num 1)
        , flexDirection column
        , height (pct 100)
        , justifyContent flexStart
        ]
    , class "editor-text-placeholder"
        [ alignItems stretch
        , color averageGrey
        , cursor pointer
        , displayFlex
        , flex (num 1)
        , flexDirection column
        , height (pct 100)
        , justifyContent flexStart
        ]
    , class "editor-title-input"
        [ fontSize (rem 1)
        , fontWeight bold
        , marginLeft (px 6)
        , marginTop (px 16)
        , marginBottom (px 16)
        , displayFlex
        , flexGrow (num 1)
        ]
    , class "editor-title-readonly"
        [ cursor pointer
        , displayFlex
        , flexGrow (num 1)
        , marginLeft (px 20)
        , marginRight (px 10)
        ]
    , class "editor-title-placeholder"
        [ color averageGrey
        , cursor pointer
        , marginLeft (px 20)
        , marginRight (px 10)
        , displayFlex
        , flexGrow (num 1)
        ]
    , class "main"
        [ alignItems stretch
        , displayFlex
        , flex (num 1)
        , flexDirection column
        , height (pct 100)
        , justifyContent flexStart
        ]
    , class "main-notelist"
        [ flex (num 1)
        ]
    , class "main-notelist-spinner"
        [ displayFlex
        , flex (num 1)
        ]
    , class "plusButton"
        [ bottom (px 0)
        , cursor pointer
        , position fixed
        , right (px 0)
        , transform (translate2 (pct -50) (pct -100))
        ]
    , class "retry"
        [ displayFlex
        , flexDirection column
        , flex (num 1)
        , justifyContent center
        ]
    , class "retry-button"
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
        , marginLeft auto
        , marginRight auto
        ]
    , class "retry-label"
        [ marginLeft auto
        , marginRight auto
        ]
    , class "spinner"
        [ displayFlex
        , flexDirection column
        , justifyContent center
        , flex (num 1)
        ]
    , class "textEditor"
        [ displayFlex
        , flexDirection column
        , justifyContent flexStart
        , height (pct 100)
        , alignItems stretch
        ]
    , class "textEditor-textarea"
        [ flexGrow (num 1)
        , fontFamilies [ "Verdana", "Arial" ]
        , fontSize (rem 1)
        , padding (px 5)
        ]
    ]
