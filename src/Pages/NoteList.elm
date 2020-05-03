module Pages.NoteList exposing (..)

import Data.Note as Note exposing (Content(..), Note)
import Fixtures exposing (allNotes)
import Html.Styled exposing (Html, div, h2, input, text)
import Html.Styled.Attributes exposing (checked, class, type_)
import Html.Styled.Events exposing (onClick)


type alias Model =
    { notes : List Note
    }


type Msg
    = UserClickedNote Note
    | NoOp


init : Model
init =
    { notes = allNotes
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view model =
    div [ class "fill-height" ] <|
        List.map viewNote model.notes


viewNote : Note -> Html Msg
viewNote note =
    div
        [ class "clickable card"
        , onClick (UserClickedNote note)
        ]
        [ viewNoteTitle note
        , viewNoteContent note
        ]


viewNoteTitle : Note -> Html Msg
viewNoteTitle note =
    h2 [] [ text note.title ]


viewNoteContent : Note -> Html Msg
viewNoteContent note =
    case note.content of
        Note.TodoList items ->
            viewItems items

        Note.Text text ->
            viewNoteText text

        Empty ->
            noContent


noContent =
    text ""


viewItems : List Note.Item -> Html msg
viewItems items =
    div [] <| List.map viewItem items


viewItem : Note.Item -> Html msg
viewItem item =
    div []
        [ input [ type_ "checkbox", checked item.checked ] []
        , text item.text
        ]


viewNoteText : String -> Html msg
viewNoteText noteContent =
    div [] [ text noteContent ]
