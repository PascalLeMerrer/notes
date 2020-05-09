module Pages.NoteEditor exposing (Model, Msg(..), init, subscriptions, update, view, viewContent)

import Components.BackButton as BackButton
import Data.Note as Note exposing (Content(..), Note)
import Html.Attributes
import Html.Styled exposing (Html, div, fromUnstyled, h2, input, text, textarea)
import Html.Styled.Attributes exposing (checked, class, id, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import MessageToast exposing (MessageToast)
import RemoteData exposing (RemoteData(..), WebData)
import Requests.Endpoint exposing (createNote)
import Utils.Html exposing (focusOn)
import Utils.Http exposing (errorToString)


type alias Model =
    { title : String
    , content : Content
    , isEditingContent : Bool
    , isEditingTitle : Bool
    , messageToast : MessageToast Msg
    }


type Msg
    = MessageToastChanged (MessageToast Msg)
    | NoOp
    | ServerSavedNewNote (WebData Note)
    | UserClickedBackButton
    | UserClickedNoteContent
    | UserClickedNoteTitle
    | UserChangedContent String
    | UserChangedTitle String
    | UserSelectedNote Note


init : Model
init =
    { title = ""
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

        ServerSavedNewNote (Failure err) ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( { model | messageToast = toast }, Cmd.none )

        ServerSavedNewNote webdata ->
            ( model, Cmd.none )

        UserChangedContent string ->
            if String.trim string == "" then
                ( { model | content = Empty }, Cmd.none )

            else
                ( { model | content = Text string }, Cmd.none )

        UserChangedTitle string ->
            ( { model | title = string }, Cmd.none )

        UserClickedBackButton ->
            -- TODO test if id is defined and then update if the note was modified
            let
                newNote =
                    { id = ""
                    , content = model.content
                    , title = model.title
                    }
            in
            ( model, createNote newNote ServerSavedNewNote )

        UserClickedNoteContent ->
            ( { model | isEditingContent = True }, focusOn contentEditorId NoOp )

        UserClickedNoteTitle ->
            ( { model | isEditingTitle = True }, focusOn titleEditorId NoOp )

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
    div [ class "clickable selected-note vertical-container fill-height" ]
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
        [ class "note-title"
        , onClick UserClickedNoteTitle
        ]
        [ text title ]


viewTitlePlaceholder : Html Msg
viewTitlePlaceholder =
    h2
        [ class "note-title placeholder"
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
        [ input [ type_ "checkbox", checked item.checked ] []
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
            , id contentEditorId
            , onInput UserChangedContent
            , value noteContent
            ]
            []
        ]


contentEditorId : String
contentEditorId =
    "content-editor"


viewReadOnlyText : String -> Html Msg
viewReadOnlyText noteContent =
    div
        [ class "vertical-container fill-height"
        , onClick UserClickedNoteContent
        ]
        [ text noteContent ]


viewTextPlaceholder : Html Msg
viewTextPlaceholder =
    div
        [ class "vertical-container fill-height placeholder"
        , onClick UserClickedNoteContent
        ]
        [ text "Texte" ]



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- MessageToast provides a subscription to close automatically
          MessageToast.subscriptions model.messageToast
        ]
