module Pages.NoteEditor exposing (Model, Msg(..), init, subscriptions, update, view, viewContent)

import Components.BackButton as BackButton
import Components.DeleteButton as DeleteButton
import Components.Retry as Retry
import Components.Spinner as Spinner
import Data.Note as Note exposing (Content(..), Item, Note, toText, toTodoList)
import Html.Attributes
import Html.Styled exposing (Html, button, div, fromUnstyled, h2, input, p, text, textarea)
import Html.Styled.Attributes exposing (checked, class, id, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import MessageToast exposing (MessageToast)
import RemoteData exposing (RemoteData(..), WebData)
import Requests.Endpoint exposing (createNoteCmd, deleteNoteCmd, updateNoteCmd)
import Utils.Html exposing (focusOn, noContent)
import Utils.Http exposing (errorToString)


type Msg
    = MessageToastChanged (MessageToast Msg)
    | NoOp
    | ServerDeletedNote String (WebData String)
    | ServerSavedNewNote (WebData Note)
    | ServerSavedNote (WebData Note)
    | UserClickedBackButton
    | UserClickedTextButton
    | UserClickedTodoListButton
    | UserClickedNoteContent
    | UserClickedNoteTitle
    | UserChangedContent String
    | UserChangedTitle String
    | UserClickedDeleteButton
    | UserSelectedNote Note
    | UserToggledItem Item



-- MODEL


type alias Model =
    { content : Content
    , id : String
    , isEditingContent : Bool
    , isEditingTitle : Bool
    , messageToast : MessageToast Msg
    , msgToRetry : Maybe Msg
    , note : WebData Note
    , order : Int
    , title : String
    }


withContent : Content -> Model -> Model
withContent content model =
    { model | content = content }
        |> updateNote


withId : String -> Model -> Model
withId id model =
    { model | id = id }
        |> updateNote


withOrder : Int -> Model -> Model
withOrder order model =
    { model | order = order }
        |> updateNote


withTitle : String -> Model -> Model
withTitle title model =
    { model | title = title }
        |> updateNote


{-| updates the note according to the content of the model fields
-}
updateNote : Model -> Model
updateNote model =
    let
        note : Note
        note =
            { id = model.id
            , title = model.title
            , content = model.content
            , order = model.order
            }
    in
    { model | note = Success note }


withMessageToRetry : Maybe Msg -> Model -> Model
withMessageToRetry msg model =
    { model | msgToRetry = msg }


withNote : WebData Note -> Model -> Model
withNote webData model =
    let
        updatedModel =
            case webData of
                Success note ->
                    model
                        |> withId note.id
                        |> withContent note.content
                        |> withTitle note.title
                        |> withOrder note.order

                _ ->
                    -- when the server request failed, or is not finished yet, let the model unchanged
                    model
    in
    { updatedModel | note = webData }


withMessageToast : MessageToast Msg -> Model -> Model
withMessageToast messageToast model =
    { model | messageToast = messageToast }


init : Model
init =
    { content = Empty
    , id = ""
    , isEditingContent = False
    , isEditingTitle = False
    , messageToast = MessageToast.init MessageToastChanged
    , msgToRetry = Nothing
    , note = NotAsked
    , order = 0
    , title = ""
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

        ServerDeletedNote noteId (Failure err) ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( model
                |> withMessageToast toast
                -- TODO verify this; is it the right content for the note?
                |> withNote (Failure err)
            , Cmd.none
            )

        ServerDeletedNote _ _ ->
            ( model, Cmd.none )

        ServerSavedNewNote (Failure err) ->
            let
                -- TODO factorize with other (Failure err) branches
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( model
                |> withMessageToast toast
                --TODO this causes an issue, when succeeding after a retry an empty note is added to noteList
                |> withNote (Failure err)
            , Cmd.none
            )

        ServerSavedNewNote webDataNote ->
            ( model |> withNote webDataNote, Cmd.none )

        ServerSavedNote (Failure err) ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( model
                |> withMessageToast toast
                |> withNote (Failure err)
            , Cmd.none
            )

        ServerSavedNote webDataNote ->
            ( model |> withNote webDataNote, Cmd.none )

        UserChangedContent string ->
            if String.trim string == "" then
                ( model |> withContent Empty
                , Cmd.none
                )

            else
                ( model
                    |> withContent (Text string)
                , Cmd.none
                )

        UserChangedTitle string ->
            ( model
                |> withTitle string
            , Cmd.none
            )

        UserClickedBackButton ->
            let
                note : Note
                note =
                    { id = model.id
                    , title = model.title
                    , content = model.content
                    , order = model.order
                    }

                updatedModel =
                    model
                        |> withNote Loading
                        |> withMessageToRetry (Just UserClickedBackButton)
            in
            if note.id == "" then
                ( updatedModel
                , createNoteCmd note ServerSavedNewNote
                )

            else
                ( updatedModel
                , updateNoteCmd note ServerSavedNote
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
                noteToDelete =
                    -- there is no need to send title and content, the server just needs the note Id
                    { id = model.id
                    , title = ""
                    , content = Empty
                    , order = 0
                    }
            in
            ( model
                |> withNote Loading
                |> withMessageToRetry (Just UserClickedDeleteButton)
            , deleteNoteCmd noteToDelete (ServerDeletedNote noteToDelete.id)
            )

        UserToggledItem item ->
            --TODO implement
            ( model, Cmd.none )

        UserClickedTextButton ->
            convert model toText

        UserClickedTodoListButton ->
            convert model toTodoList


convert : Model -> (Note -> Note) -> ( Model, Cmd Msg )
convert model converter =
    case model.note of
        Success note ->
            let
                convertedNote =
                    converter note
            in
            ( model |> withNote (Success convertedNote), Cmd.none )

        _ ->
            ( model, Cmd.none )


{-| displays a note in full screen
-}
view : Model -> Html Msg
view model =
    let
        mainContent =
            case model.note of
                NotAsked ->
                    noContent

                Loading ->
                    Spinner.view

                Failure e ->
                    div []
                        [ viewHeader model
                        , Retry.view "Oops. Something went wrong" (model.msgToRetry |> Maybe.withDefault NoOp)
                        ]

                Success _ ->
                    viewNote model
    in
    div [ class "editor" ]
        [ mainContent
        , model.messageToast
            |> MessageToast.overwriteContainerAttributes [ Html.Attributes.class "message-toast-container" ]
            |> MessageToast.view
            |> fromUnstyled
        ]


viewNote : Model -> Html Msg
viewNote model =
    div [ class "editor-note" ]
        [ viewHeader model
        , viewContent model
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    div [ class "editor-header" ]
        [ BackButton.view UserClickedBackButton
        , viewTitle model
        , case model.content of
            TodoList _ ->
                viewTextButton

            _ ->
                viewTodoListButton
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


viewTextButton : Html Msg
viewTextButton =
    button [ onClick UserClickedTextButton ] [ text "Text" ]


viewTodoListButton : Html Msg
viewTodoListButton =
    button [ onClick UserClickedTodoListButton ] [ text "Todo List" ]


titleEditorId : String
titleEditorId =
    "editor-title-input"


viewReadOnlyTitle : String -> Html Msg
viewReadOnlyTitle title =
    h2
        [ class "editor-title-readonly"
        , onClick UserClickedNoteTitle
        ]
        [ text title ]


viewTitlePlaceholder : Html Msg
viewTitlePlaceholder =
    h2
        [ class "editor-title-placeholder"
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


viewItems : List Item -> Html Msg
viewItems items =
    items
        |> List.sortWith checkedComparison
        |> List.map viewItem
        |> div []


checkedComparison : Item -> Item -> Order
checkedComparison a b =
    if a.checked && not b.checked then
        GT

    else if b.checked && not a.checked then
        LT

    else
        EQ


{-| TODO: move in a dedicated module in order to share with noteList?
-}
viewItem : Item -> Html Msg
viewItem item =
    let
        className =
            if item.checked then
                "checked-item"

            else
                ""
    in
    div [ class className ]
        [ input
            [ type_ "checkbox"
            , class "editor-item"
            , checked item.checked
            , onClick (UserToggledItem item)
            ]
            []
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
    div [ class "textEditor" ]
        [ textarea
            [ class "textEditor-textarea"
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
        [ class "editor-text-readonly"
        , class textEditorId
        , onClick UserClickedNoteContent
        ]
        (noteContent
            |> String.lines
            |> List.map (\line -> p [ class "editor-text-line" ] [ text line ])
        )


viewTextPlaceholder : Html Msg
viewTextPlaceholder =
    div
        [ class "editor-text-placeholder"
        , onClick UserClickedNoteContent
        ]
        [ text "Texte" ]


viewDeleteButton : Html Msg
viewDeleteButton =
    div
        [ class "deleteButton"
        ]
        [ DeleteButton.view UserClickedDeleteButton ]



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- MessageToast provides a subscription to close automatically
          MessageToast.subscriptions model.messageToast
        ]
