module Components.Stylesheet exposing (all)

import Components.Colors exposing (averageGreen, averageGrey, darkerGrey, lightGreen, lightGrey, white)
import Css exposing (Style, alignItems, alignSelf, auto, backgroundColor, bold, border3, borderBottom3, borderColor, borderRadius, bottom, center, color, column, cursor, dashed, display, displayFlex, em, fixed, flex, flexDirection, flexGrow, flexStart, fontFamilies, fontSize, fontStyle, fontWeight, height, hover, italic, justifyContent, lineThrough, margin, marginBottom, marginLeft, marginRight, marginTop, maxWidth, none, num, padding, paddingBottom, paddingLeft, paddingRight, paddingTop, pct, pointer, position, px, rem, right, row, solid, spaceBetween, stretch, textDecoration, transform, translate2, width)
import Css.Global exposing (Snippet, class, global)
import Css.Media exposing (only, screen, withMedia)
import Html.Styled


computerBreakpoint : Css.Px
computerBreakpoint =
    px 992


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
    , class "button-icon"
        []
    , class "button-text"
        [ withMedia [ only screen [ Css.Media.maxWidth computerBreakpoint ] ]
            [ display none
            ]
        , paddingLeft (px 10)
        ]
    , class "card"
        [ border3 (px 1) solid darkerGrey
        , cursor pointer
        , margin (px 5)
        , maxWidth computerBreakpoint
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
    , class "draghandle"
        [ marginLeft (px 20)
        ]
    , class "dropZone-active"
        [ height (px 5)
        , hover
            [ height (px 40)
            , border3 (px 1) dashed lightGrey
            ]
        , width (pct 100)
        ]
    , class "dropZone-inactive"
        [ height (px 5)
        , width (pct 100)
        ]
    , class "editor"
        [ alignItems stretch
        , cursor pointer
        , displayFlex
        , flexDirection column
        , height (pct 100)
        , justifyContent flexStart
        , margin (px 5)
        , padding (px 5)
        , border3 (px 1) solid darkerGrey
        , withMedia [ only screen [ Css.Media.minWidth computerBreakpoint ] ]
            [ marginLeft (pct 25)
            , marginRight (pct 25)
            ]
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
        , displayFlex
        , flexDirection row
        , alignItems center
        , marginTop (em 0.75)
        , marginBottom (em 0.75)
        ]
    , class "editor-item-checked"
        [ cursor pointer
        , displayFlex
        , flexDirection row
        , alignItems center
        , marginTop (em 0.75)
        , marginBottom (em 0.75)
        , color lightGrey
        , textDecoration lineThrough
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
        , fontStyle italic
        , marginLeft (px 20)
        , marginRight (px 10)
        , displayFlex
        , flexGrow (num 1)
        ]
    , class "header-button"
        [ alignItems center
        , borderRadius (px 5)
        , displayFlex
        , flexDirection row
        , fontSize (rem 1)
        , justifyContent spaceBetween
        , paddingTop (px 5)
        , paddingBottom (px 5)
        , paddingLeft (px 10)
        , paddingRight (px 10)
        ]
    , class "item"
        [ displayFlex
        , flexDirection column
        ]
    , class "item-checkbox"
        [ marginLeft (px 20)
        , marginRight (px 20)
        ]
    , class "item-input"
        [ fontSize (rem 1)
        , flexGrow (num 1)
        , marginRight (px 20)
        ]
    , class "item-text-edited"
        [ alignItems center
        , displayFlex
        , flexGrow (num 1)
        , justifyContent spaceBetween
        , paddingRight (px 20)
        ]
    , class "item-text-placeholder"
        [ color averageGrey
        , displayFlex
        , fontStyle italic
        , flexGrow (num 1)
        , justifyContent spaceBetween
        , paddingRight (px 20)
        ]
    , class "item-text-readonly"
        [ alignItems center
        , displayFlex
        , flexGrow (num 1)
        , justifyContent spaceBetween
        , paddingRight (px 20)
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
    , class "title-form"
        [ displayFlex
        , flexDirection row
        , flexGrow (num 1)
        ]
    , class "title-input"
        [ fontSize (rem 1.5)
        , fontWeight bold
        , flexGrow (num 1)
        , margin (px 16)
        ]
    ]
