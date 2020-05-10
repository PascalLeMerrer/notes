module Pages.NoteEditor exposing (Model, Msg(..), init, subscriptions, update, view, viewContent)

import Components.BackButton as BackButton
import Components.DeleteButton as DeleteButton
import Data.Note as Note exposing (Content(..), Note)
import Html.Attributes
import Html.Styled exposing (Html, div, fromUnstyled, h2, input, text, textarea)
import Html.Styled.Attributes exposing (checked, class, id, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import List.Extra exposing (indexedFoldr)
import MessageToast exposing (MessageToast)
import RemoteData exposing (RemoteData(..), WebData)
import Requests.Endpoint exposing (createNote, deleteNote, updateNote)
import Utils.Html exposing (focusOn)
import Utils.Http exposing (errorToString)


type alias Model =
    { noteId : String
    , title : String
    , content : Content
    , isEditingContent : Bool
    , isEditingTitle : Bool
    , messageToast : MessageToast Msg
    }


type Msg
    = MessageToastChanged (MessageToast Msg)
    | NoOp
    | ServerDeletedNote String (WebData String)
    | ServerSavedNewNote (WebData Note)
    | ServerSavedNote (WebData Note)
    | UserClickedBackButton
    | UserClickedNoteContent
    | UserClickedNoteTitle
    | UserChangedContent String
    | UserChangedTitle String
    | UserClickedDeleteButton
    | UserSelectedNote Note


init : Model
init =
    { noteId = ""
    , title = ""
    , content = Empty
    , isEditingContent = False
    , isEditingTitle = False
    , messageToast = MessageToast.init MessageToastChanged
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MessageToastChanged updatedMessageToast ->
            ( { model | messageToast = updatedMessageToast }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        ServerDeletedNote _ _ ->
            ( model, Cmd.none )

        ServerSavedNewNote (Failure err) ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( { model | messageToast = toast }, Cmd.none )

        ServerSavedNewNote webdata ->
            -- TODO handle these cases
            ( model, Cmd.none )

        ServerSavedNote (Failure err) ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( { model | messageToast = toast }, Cmd.none )

        ServerSavedNote webData ->
            -- TODO handle these cases
            ( model, Cmd.none )

        UserChangedContent string ->
            if String.trim string == "" then
                ( { model | content = Empty }, Cmd.none )

            else
                ( { model | content = Text string }, Cmd.none )

        UserChangedTitle string ->
            ( { model | title = string }, Cmd.none )

        UserClickedBackButton ->
            let
                note =
                    { id = model.noteId
                    , content = model.content
                    , title = model.title
                    }
            in
            if note.id == "" then
                ( model, createNote note ServerSavedNewNote )

            else
                ( model, updateNote note ServerSavedNote )

        UserClickedNoteContent ->
            ( { model | isEditingContent = True }, focusOn textEditorId NoOp )

        UserClickedNoteTitle ->
            ( { model | isEditingTitle = True }, focusOn titleEditorId NoOp )

        UserSelectedNote note ->
            ( { model
                | noteId = note.id
                , title = note.title
                , content = note.content
              }
            , Cmd.none
            )

        UserClickedDeleteButton ->
            let
                noteToDelete =
                    -- there is no need to send title and content, the server just needs the noteId
                    { id = model.noteId
                    , title = ""
                    , content = Empty
                    }
            in
            ( model
            , deleteNote noteToDelete (ServerDeletedNote noteToDelete.id)
            )


{-| displays a note in full screen
-}
view : Model -> Html Msg
view model =
    div [ class "selected-note vertical-container fill-height" ]
        [ viewHeader model
        , viewContent model
        , model.messageToast
            |> MessageToast.overwriteContainerAttributes [ Html.Attributes.class "message-toast-container" ]
            |> MessageToast.view
            |> fromUnstyled
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    div [ class "header" ]
        [ BackButton.view UserClickedBackButton
        , viewTitle model
        , viewDeleteButton
        ]


viewTitle : Model -> Html Msg
viewTitle model =
    if model.isEditingTitle then
        viewEditableTitle model.title

    else if String.isEmpty model.title then
        viewTitlePlaceholder

    else
        viewReadOnlyTitle model.title


viewEditableTitle : String -> Html Msg
viewEditableTitle title =
    input
        [ id titleEditorId
        , class titleEditorId
        , value title
        , onInput UserChangedTitle
        ]
        []


titleEditorId : String
titleEditorId =
    "title-editor"


viewReadOnlyTitle : String -> Html Msg
viewReadOnlyTitle title =
    h2
        [ class "note-title clickable"
        , onClick UserClickedNoteTitle
        ]
        [ text title ]


viewTitlePlaceholder : Html Msg
viewTitlePlaceholder =
    h2
        [ class "note-title placeholder clickable"
        , onClick UserClickedNoteTitle
        ]
        [ text "Titre" ]


viewContent : Model -> Html Msg
viewContent model =
    case model.content of
        Note.TodoList items ->
            viewItems items

        Note.Text text ->
            viewText model text

        Empty ->
            viewText model ""


viewItems : List Note.Item -> Html Msg
viewItems items =
    div [] <| List.map viewItem items


viewItem : Note.Item -> Html Msg
viewItem item =
    div []
        [ input [ type_ "checkbox", class "clickable", checked item.checked ] []
        , text item.text
        ]


viewText : Model -> String -> Html Msg
viewText model text =
    if model.isEditingContent then
        viewEditableText text

    else if String.isEmpty text then
        viewTextPlaceholder

    else
        viewReadOnlyText text


viewEditableText : String -> Html Msg
viewEditableText noteContent =
    div [ class "vertical-container fill-height" ]
        [ textarea
            [ class "fill-height"
            , class textEditorId
            , id textEditorId
            , onInput UserChangedContent
            , value noteContent
            ]
            []
        ]


textEditorId : String
textEditorId =
    "text-editor"


viewReadOnlyText : String -> Html Msg
viewReadOnlyText noteContent =
    div
        [ class "vertical-container fill-height clickable"
        , class textEditorId
        , onClick UserClickedNoteContent
        ]
        [ text noteContent ]


viewTextPlaceholder : Html Msg
viewTextPlaceholder =
    div
        [ class "vertical-container fill-height placeholder clickable"
        , onClick UserClickedNoteContent
        ]
        [ text "Texte" ]


viewDeleteButton : Html Msg
viewDeleteButton =
    div
        [ class "delete-button clickable"
        ]
        [ DeleteButton.view UserClickedDeleteButton ]



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- MessageToast provides a subscription to close automatically
          MessageToast.subscriptions model.messageToast
        ]
