module NoteEditor exposing (Model, Msg(..), init, update, view, viewNoteContent, viewNoteTitle)

import Html.Styled exposing (Html, div, h2, input, text)
import Html.Styled.Attributes exposing (checked, class, type_)
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
view : Model -> Html msg
view model =
    div [ class "selected-note" ]
        [ viewNoteTitle model
        , viewNoteContent model
        ]


viewNoteTitle : Model -> Html msg
viewNoteTitle model =
    h2 [] [ text model.title ]


viewNoteContent : Model -> Html msg
viewNoteContent model =
    case model.content of
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
