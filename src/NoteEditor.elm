module NoteEditor exposing (Model, Msg(..), init, update, view, viewNoteContent, viewNoteTitle)

import Html.Styled exposing (Html, div, h2, input, text, textarea)
import Html.Styled.Attributes exposing (checked, class, type_, value)
import Html.Styled.Events exposing (onClick)
import Note exposing (Content(..), Note)


type alias Model =
    { title : String
    , content : Content
    , isEditionActive : Bool
    }


type Msg
    = UserClickedNote
    | UserSelectedNote Note


init : Model
init =
    { title = ""
    , content = Empty
    , isEditionActive = False
    }


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        UserClickedNote ->
            ( { model | isEditionActive = True }, Cmd.none )

        UserSelectedNote note ->
            ( { model
                | title = note.title
                , content = note.content
              }
            , Cmd.none
            )


{-| displays a note in full screen
-}
view : Model -> Html Msg
view model =
    div [ class "selected-note vertical-container fill-height" ]
        [ viewNoteTitle model
        , viewNoteContent model
        ]


viewNoteTitle : Model -> Html Msg
viewNoteTitle model =
    h2 [] [ text model.title ]


viewNoteContent : Model -> Html Msg
viewNoteContent model =
    case model.content of
        Note.TodoList items ->
            viewItems items

        Note.Text text ->
            if model.isEditionActive then
                viewEditableText text

            else
                viewReadOnlyText text

        Empty ->
            noContent


noContent =
    text ""


viewItems : List Note.Item -> Html Msg
viewItems items =
    div [] <| List.map viewItem items


viewItem : Note.Item -> Html Msg
viewItem item =
    div []
        [ input [ type_ "checkbox", checked item.checked ] []
        , text item.text
        ]


viewEditableText : String -> Html Msg
viewEditableText noteContent =
    div [ class "vertical-container fill-height" ]
        [ textarea
            [ value noteContent
            , class "fill-height"
            ]
            []
        ]


viewReadOnlyText : String -> Html Msg
viewReadOnlyText noteContent =
    div
        [ class "vertical-container fill-height"
        , onClick UserClickedNote
        ]
        [ text noteContent ]
