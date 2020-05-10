module Main exposing (main)

import Browser exposing (Document)
import Components.PlusButton as PlusButton
import Components.Stylesheet as Stylesheet
import Data.Note as Note exposing (Note)
import Fixtures exposing (allNotes)
import Html
import Html.Styled exposing (Html, div, fromUnstyled, h1, text, toUnstyled)
import Html.Styled.Attributes exposing (class)
import Pages.NoteEditor as NoteEditor exposing (Msg(..))
import Pages.NoteList as NoteList exposing (Msg(..))
import RemoteData exposing (RemoteData(..))


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Msg
    = NoteEditorMsg NoteEditor.Msg
    | NoteListMsg NoteList.Msg
    | UserClickedPlusButton



-- MODEL --


type alias Model =
    { noteEditorModel : NoteEditor.Model
    , noteListModel : NoteList.Model
    , notes : List Note
    , selectedNote : Maybe Note
    }


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
    let
        ( noteListModel, noteListCmd ) =
            NoteList.init
    in
    ( { noteEditorModel = NoteEditor.init
      , noteListModel = noteListModel
      , notes = allNotes
      , selectedNote = Nothing
      }
    , Cmd.map NoteListMsg noteListCmd
    )



-- UPDATE --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoteEditorMsg (ServerDeletedNote noteId (Success _)) ->
            let
                ( updatedNoteListModel, cmd ) =
                    NoteList.update (UserDeletedNote noteId) model.noteListModel
            in
            ( model
                |> withNoteList updatedNoteListModel
                |> withSelectedNote Nothing
                |> withNoteEditor NoteEditor.init
            , Cmd.map NoteListMsg cmd
            )

        NoteEditorMsg (ServerSavedNewNote (Success note)) ->
            let
                ( updatedNoteListModel, cmd ) =
                    NoteList.update (UserCreatedNote note) model.noteListModel
            in
            ( model
                |> withNoteList updatedNoteListModel
                |> withSelectedNote Nothing
                |> withNoteEditor NoteEditor.init
            , Cmd.map NoteListMsg cmd
            )

        NoteEditorMsg (ServerSavedNote (Success note)) ->
            let
                ( updatedNoteListModel, cmd ) =
                    NoteList.update (UserUpdatedNote note) model.noteListModel
            in
            ( model
                |> withNoteList updatedNoteListModel
                |> withSelectedNote Nothing
                |> withNoteEditor NoteEditor.init
            , Cmd.map NoteListMsg cmd
            )

        NoteEditorMsg noteEditorMsg ->
            let
                ( updatedNoteEditorModel, cmd ) =
                    NoteEditor.update noteEditorMsg model.noteEditorModel
            in
            ( model |> withNoteEditor updatedNoteEditorModel, Cmd.map NoteEditorMsg cmd )

        NoteListMsg (NoteList.UserClickedNote note) ->
            selectNote model note

        NoteListMsg noteListMsg ->
            let
                ( updatedNoteListModel, cmd ) =
                    NoteList.update noteListMsg model.noteListModel
            in
            ( model |> withNoteList updatedNoteListModel, Cmd.map NoteListMsg cmd )

        UserClickedPlusButton ->
            selectNote model Note.empty


selectNote : Model -> Note -> ( Model, Cmd Msg )
selectNote model note =
    let
        ( updatedNoteEditorModel, cmd ) =
            NoteEditor.update (NoteEditor.UserSelectedNote note) model.noteEditorModel
    in
    ( model
        |> withSelectedNote (Just note)
        |> withNoteEditor updatedNoteEditorModel
    , Cmd.map NoteEditorMsg cmd
    )



-- VIEW --


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
        div [ class "body vertical-container fill-height" ]
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
    div [ class "vertical-container fill-height" ]
        [ viewTitle model
        , Html.Styled.map NoteListMsg (NoteList.view model.noteListModel)
        , PlusButton.view UserClickedPlusButton
        ]



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ NoteEditor.subscriptions model.noteEditorModel |> Sub.map NoteEditorMsg
        , NoteList.subscriptions model.noteListModel |> Sub.map NoteListMsg
        ]
