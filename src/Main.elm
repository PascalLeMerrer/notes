module Main exposing (main)

import Browser exposing (Document)
import Fixtures exposing (allNotes)
import Html
import Html.Styled exposing (Html, div, h1, text, toUnstyled)
import Html.Styled.Attributes exposing (class)
import Note exposing (Note)
import NoteEditor
import NoteList
import PlusButton
import Stylesheet


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { noteEditorModel : NoteEditor.Model
    , noteListModel : NoteList.Model
    , notes : List Note
    , selectedNote : Maybe Note
    }


type Msg
    = NoteEditorMsg NoteEditor.Msg
    | NoteListMsg NoteList.Msg


withNoteList : NoteList.Model -> Model -> Model
withNoteList noteListModel model =
    { model | noteListModel = noteListModel }


withNoteEditor : NoteEditor.Model -> Model -> Model
withNoteEditor noteEditorModel model =
    { model | noteEditorModel = noteEditorModel }


withSelectedNote : Maybe Note -> Model -> Model
withSelectedNote maybeNote model =
    { model | selectedNote = maybeNote }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { noteEditorModel = NoteEditor.init
      , noteListModel = NoteList.init
      , notes = allNotes
      , selectedNote = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoteEditorMsg noteEditorMsg ->
            let
                ( updatedNoteEditorModel, cmd ) =
                    NoteEditor.update noteEditorMsg model.noteEditorModel
            in
            ( model |> withNoteEditor updatedNoteEditorModel, Cmd.map NoteEditorMsg cmd )

        NoteListMsg (NoteList.UserClickedNote note) ->
            let
                ( updatedNoteEditorModel, cmd ) =
                    NoteEditor.update (NoteEditor.UserSelectedNote note) model.noteEditorModel
            in
            ( model
                |> withSelectedNote
                    (Just note)
                |> withNoteEditor updatedNoteEditorModel
            , Cmd.map NoteEditorMsg cmd
            )

        NoteListMsg noteListMsg ->
            let
                ( updatedNoteListModel, cmd ) =
                    NoteList.update noteListMsg model.noteListModel
            in
            ( model |> withNoteList updatedNoteListModel, Cmd.map NoteListMsg cmd )


view : Model -> Document Msg
view model =
    { title = "Notes"
    , body = viewBody model
    }


viewTitle : Model -> Html Msg
viewTitle model =
    h1 [] [ text "Notes" ]


viewBody : Model -> List (Html.Html Msg)
viewBody model =
    [ toUnstyled <|
        div [ class "body" ]
            [ Stylesheet.all
            , case model.selectedNote of
                Just _ ->
                    Html.Styled.map NoteEditorMsg (NoteEditor.view model.noteEditorModel)

                Nothing ->
                    viewMain model
            ]
    ]


viewMain : Model -> Html Msg
viewMain model =
    div []
        [ viewTitle model
        , Html.Styled.map NoteListMsg (NoteList.view model.noteListModel)
        , PlusButton.view
        ]
