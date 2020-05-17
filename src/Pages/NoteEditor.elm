module Pages.NoteEditor exposing (Model, Msg(..), init, subscriptions, update, view, viewContent)

import Components.BackButton as BackButton
import Components.DeleteButton as DeleteButton
import Components.Retry as Retry
import Components.Spinner as Spinner
import Components.TextIcon as TextIcon
import Components.TodoListIcon as TodoListButton
import Data.Note as Note exposing (Content(..), Item, Note, toText, toTodoList)
import Html.Attributes
import Html.Styled exposing (Attribute, Html, button, div, fromUnstyled, h2, input, p, span, text, textarea)
import Html.Styled.Attributes exposing (checked, class, id, type_, value)
import Html.Styled.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode
import List.Extra
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
    | UserChangedContent String
    | UserChangedItemText String
    | UserChangedTitle String
    | UserClickedBackButton
    | UserClickedItemText Item
    | UserClickedTextButton
    | UserClickedTodoListButton
    | UserClickedNoteContent
    | UserClickedNoteTitle
    | UserClickedDeleteButton
    | UserPressedKey Key
    | UserSelectedNote Note
    | UserToggledItem Item


type Key
    = Backspace
    | Enter
    | Escape
    | Other



-- MODEL


type alias Model =
    { content : Content
    , editedItem : Maybe Item
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


withEditedItem : Maybe Item -> Model -> Model
withEditedItem editedItem model =
    { model | editedItem = editedItem }


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
    , editedItem = Nothing
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

        UserChangedItemText string ->
            case model.editedItem of
                Just editedItem ->
                    let
                        updatedItem =
                            { editedItem | text = string }

                        updatedModel =
                            model |> withEditedItem (Just updatedItem)
                    in
                    ( updateItemInContent updatedModel updatedItem
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

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

        UserClickedItemText item ->
            ( { model | editedItem = Just item }, Cmd.none )

        UserClickedNoteTitle ->
            ( { model | isEditingTitle = True }, focusOn titleEditorId NoOp )

        UserClickedTextButton ->
            convert model toText

        UserClickedTodoListButton ->
            convert model toTodoList

        UserSelectedNote note ->
            ( model |> withNote (Success note)
            , Cmd.none
            )

        UserToggledItem item ->
            let
                updatedItem =
                    { item | checked = not item.checked }
            in
            ( updateItemInContent model updatedItem
            , Cmd.none
            )

        UserPressedKey key ->
            case key of
                Backspace ->
                    ( removeEditedItemIfEmpty model, Cmd.none )

                Enter ->
                    ( model
                        |> addItem
                    , Cmd.none
                    )

                Escape ->
                    ( model
                        |> withEditedItem Nothing
                    , Cmd.none
                    )

                Other ->
                    ( model, Cmd.none )


updateItemInContent : Model -> Item -> Model
updateItemInContent model item =
    case model.content of
        TodoList items ->
            let
                content =
                    List.Extra.setIf (\it -> it.order == item.order) item items
                        |> TodoList
            in
            model |> withContent content

        _ ->
            model


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


addItem : Model -> Model
addItem model =
    case model.editedItem of
        Nothing ->
            -- TODO: this is probably the case of creating a first item to an empty note
            model

        Just editedItem ->
            let
                newItem =
                    { checked = False
                    , order = editedItem.order
                    , text = ""
                    }

                updatedItems =
                    case model.content of
                        TodoList items ->
                            items
                                |> List.map
                                    (\it ->
                                        if it.order >= editedItem.order then
                                            { it | order = it.order + 1 }

                                        else
                                            it
                                    )
                                |> (::) newItem

                        _ ->
                            -- impossible case; would mean there is an editedItem when the items list is empty
                            [ newItem ]
            in
            model
                |> withContent (TodoList updatedItems)
                |> withEditedItem (Just newItem)


removeEditedItemIfEmpty : Model -> Model
removeEditedItemIfEmpty model =
    case model.editedItem of
        Just editedItem ->
            let
                updatedContent =
                    if String.isEmpty editedItem.text then
                        case model.content of
                            TodoList items ->
                                items
                                    |> List.filter (\item -> item.order /= editedItem.order)
                                    |> TodoList

                            _ ->
                                model.content

                    else
                        model.content

                updatedEditedItem =
                    if String.isEmpty editedItem.text then
                        Nothing

                    else
                        model.editedItem
            in
            model
                |> withContent updatedContent
                |> withEditedItem updatedEditedItem

        Nothing ->
            model


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
    button
        [ class "header-button"
        , onClick UserClickedTextButton
        ]
        [ TextIcon.view
        , text "Text"
        ]


viewTodoListButton : Html Msg
viewTodoListButton =
    button
        [ class "header-button"
        , onClick UserClickedTodoListButton
        ]
        [ TodoListButton.view
        , text "Todo List"
        ]


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
            viewItems model items

        Note.Text text ->
            viewText model text

        Empty ->
            viewText model ""


viewItems : Model -> List Item -> Html Msg
viewItems model items =
    items
        |> List.sortWith checkedComparison
        |> List.sortWith descendingOrder
        |> List.map (viewItem model)
        |> div []


checkedComparison : Item -> Item -> Order
checkedComparison a b =
    if a.checked && not b.checked then
        GT

    else if b.checked && not a.checked then
        LT

    else
        EQ


descendingOrder : Item -> Item -> Order
descendingOrder a b =
    if a.order < b.order then
        GT

    else if b.order > a.order then
        LT

    else
        EQ


{-| TODO: move in a dedicated module in order to share with noteList?
-}
viewItem : Model -> Item -> Html Msg
viewItem model item =
    let
        className =
            if item.checked then
                "editor-item-checked"

            else
                "editor-item"
    in
    div [ class className ]
        [ input
            [ type_ "checkbox"
            , checked item.checked
            , class "item-checkbox"
            , onClick (UserToggledItem item)
            ]
            []
        , viewItemText model item
        ]


viewItemText : Model -> Item -> Html Msg
viewItemText model item =
    case model.editedItem of
        Just editedItem ->
            if item.order == editedItem.order then
                viewEditedItemText editedItem

            else
                viewReadonlyItemText item

        Nothing ->
            viewReadonlyItemText item


viewReadonlyItemText : Item -> Html Msg
viewReadonlyItemText item =
    span [ onClick (UserClickedItemText item) ] [ text item.text ]


viewEditedItemText : Item -> Html Msg
viewEditedItemText item =
    input
        [ class "item-input"
        , type_ "text"
        , onKeyDown UserPressedKey
        , onInput UserChangedItemText
        , value item.text
        ]
        []


onKeyDown : (Key -> Msg) -> Attribute Msg
onKeyDown msgConstructor =
    on "keydown"
        (Json.Decode.map
            (\code ->
                case code of
                    8 ->
                        msgConstructor Backspace

                    13 ->
                        msgConstructor Enter

                    27 ->
                        msgConstructor Escape

                    _ ->
                        msgConstructor Other
            )
            keyCode
        )


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



--


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
