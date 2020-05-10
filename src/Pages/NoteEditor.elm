module Pages.NoteEditor exposing (Model, Msg(..), init, subscriptions, update, view, viewContent)

import Components.BackButton as BackButton
import Components.DeleteButton as DeleteButton
import Components.Spinner as Spinner
import Data.Note as Note exposing (Content(..), Note)
import Html.Attributes
import Html.Styled exposing (Html, div, fromUnstyled, h2, input, text, textarea)
import Html.Styled.Attributes exposing (checked, class, id, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import MessageToast exposing (MessageToast)
import RemoteData exposing (RemoteData(..), WebData)
import Requests.Endpoint exposing (createNote, deleteNote, updateNote)
import Utils.Html exposing (focusOn, noContent, viewIf)
import Utils.Http exposing (errorToString)


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



-- MODEL


type alias Model =
    { note : WebData Note
    , isEditingContent : Bool
    , isEditingTitle : Bool
    , isSaving : Bool
    , messageToast : MessageToast Msg
    }


withNote : WebData Note -> Model -> Model
withNote webData model =
    { model | note = webData }


withNoteTitle : String -> Model -> Model
withNoteTitle title model =
    let
        currentNote =
            getNote model

        updatedNote =
            { currentNote | title = title }
    in
    model |> withNote (Success updatedNote)


withNoteContent : Content -> Model -> Model
withNoteContent content model =
    let
        currentNote =
            getNote model

        updatedNote =
            { currentNote | content = content }
    in
    model |> withNote (Success updatedNote)


getNote : Model -> Note
getNote model =
    case model.note of
        Success note ->
            note

        _ ->
            Note.empty


withIsSaving : Bool -> Model -> Model
withIsSaving status model =
    { model | isSaving = status }


withMessageToast : MessageToast Msg -> Model -> Model
withMessageToast messageToast model =
    { model | messageToast = messageToast }


init : Model
init =
    { note = NotAsked
    , isEditingContent = False
    , isEditingTitle = False
    , isSaving = False
    , messageToast = MessageToast.init MessageToastChanged
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MessageToastChanged updatedMessageToast ->
            ( model
                |> withMessageToast updatedMessageToast
            , Cmd.none
            )

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
            ( model
                |> withMessageToast toast
                |> withIsSaving False
            , Cmd.none
            )

        ServerSavedNewNote _ ->
            ( model, Cmd.none )

        ServerSavedNote (Failure err) ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( model
                |> withMessageToast toast
                |> withIsSaving False
            , Cmd.none
            )

        ServerSavedNote webData ->
            -- TODO handle these cases
            ( model, Cmd.none )

        UserChangedContent string ->
            if String.trim string == "" then
                ( model |> withNoteContent Empty
                , Cmd.none
                )

            else
                ( model |> withNoteContent (Text string)
                , Cmd.none
                )

        UserChangedTitle string ->
            ( model |> withNoteTitle string, Cmd.none )

        UserClickedBackButton ->
            let
                note =
                    getNote model
            in
            if note.id == "" then
                ( model |> withIsSaving True
                , createNote note ServerSavedNewNote
                )

            else
                ( model |> withIsSaving True
                , updateNote note ServerSavedNote
                )

        UserClickedNoteContent ->
            ( { model | isEditingContent = True }, focusOn textEditorId NoOp )

        UserClickedNoteTitle ->
            ( { model | isEditingTitle = True }, focusOn titleEditorId NoOp )

        UserSelectedNote note ->
            ( model |> withNote (Success note)
            , Cmd.none
            )

        UserClickedDeleteButton ->
            let
                note =
                    getNote model

                noteToDelete =
                    -- there is no need to send title and content, the server just needs the note Id
                    { id = note.id
                    , title = ""
                    , content = Empty
                    }
            in
            ( model |> withIsSaving True
            , deleteNote noteToDelete (ServerDeletedNote noteToDelete.id)
            )


{-| displays a note in full screen
-}
view : Model -> Html Msg
view model =
    div [ class "selected-note vertical-container fill-height" ]
        [ viewHeader model
        , viewContent model
        , viewIf model.isSaving Spinner.view
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
    let
        title =
            (getNote model).title
    in
    if model.isEditingTitle then
        viewEditableTitle title

    else if String.isEmpty title then
        viewTitlePlaceholder

    else
        viewReadOnlyTitle title


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
    let
        content =
            model |> getNote |> .content
    in
    case content of
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
