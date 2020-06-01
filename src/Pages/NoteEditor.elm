module Pages.NoteEditor exposing (Model, Msg(..), init, subscriptions, update, view, viewContent)

import Components.BackButton as BackButton
import Components.DeleteButton as DeleteButton
import Components.DragHandle as DragHandle
import Components.DragPorts as DragPorts
import Components.Retry as Retry
import Components.Spinner as Spinner
import Components.TextIcon as TextIcon
import Components.TodoListIcon as TodoListButton
import Data.Note as Note exposing (Content(..), Item, Note, toText, toTodoList)
import Html.Attributes
import Html.Events.Extra.Drag as Drag exposing (Event)
import Html.Styled exposing (Attribute, Html, button, div, form, fromUnstyled, h2, input, p, span, text, textarea)
import Html.Styled.Attributes exposing (checked, class, id, type_, value)
import Html.Styled.Events exposing (keyCode, on, onClick, onInput, onSubmit)
import Json.Decode as Decode exposing (Value)
import List.Extra
import MessageToast exposing (MessageToast)
import RemoteData exposing (RemoteData(..), WebData)
import Requests.Endpoint exposing (createNoteCmd, deleteNoteCmd, updateNoteCmd)
import Utils.Html exposing (focusOn, noContent, viewIf)
import Utils.Http exposing (errorToString)


type Msg
    = DragEnd
    | DraggedItemEnteredDropZone Item Event -- the hovered item + the HTML drag event
    | DraggedItemLeftDropZone Item Event
    | DragOver Drag.DropEffect Value
    | DragStart Int Drag.EffectAllowed Value
    | Drop Item
    | MessageToastChanged (MessageToast Msg)
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
    | UserClickedItemDeleteButton Item
    | UserClickedNoteDeleteButton
    | UserPressedKey Key
    | UserSelectedNote Note
    | UserToggledItem Item
    | UserValidatedTitle


type Key
    = Backspace
    | Enter
    | Escape
    | Other



-- MODEL


type alias Model =
    { activeDropZone : Maybe Item -- The item above which the dragged item is ready to be dropped
    , content : Content
    , dragAndDropStatus : DragAndDropStatus
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


type DragAndDropStatus
    = NoDnD
    | Dragging Int


withActiveDropZone : Maybe Item -> Model -> Model
withActiveDropZone activeDropZone model =
    { model | activeDropZone = activeDropZone }


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
    { activeDropZone = Nothing
    , content = Empty
    , dragAndDropStatus = NoDnD
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
        DragEnd ->
            ( { model | dragAndDropStatus = NoDnD }, Cmd.none )

        DraggedItemEnteredDropZone item _ ->
            ( model |> withActiveDropZone (Just item), Cmd.none )

        DraggedItemLeftDropZone _ _ ->
            ( model |> withActiveDropZone Nothing, Cmd.none )

        DragOver dropEffect value ->
            let
                _ =
                    Debug.log "" value
            in
            ( model, DragPorts.dragover (Drag.overPortData dropEffect value) )

        DragStart itemOrder effectAllowed item ->
            ( { model | dragAndDropStatus = Dragging itemOrder }
            , DragPorts.dragstart (Drag.startPortData effectAllowed item)
            )

        Drop referenceItem ->
            let
                draggedItemOrder =
                    Debug.log "draggedItemOrder" <|
                        case model.dragAndDropStatus of
                            Dragging order ->
                                order

                            _ ->
                                0

                itemToMove =
                    itemAt draggedItemOrder model
                        |> Debug.log "itemToMove"

                _ =
                    Debug.log "referenceItem" referenceItem
            in
            case itemToMove of
                Just item ->
                    ( model
                        |> moveItemBefore item referenceItem
                        |> withActiveDropZone Nothing
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

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

        UserClickedItemDeleteButton item ->
            ( model |> removeItem item, Cmd.none )

        UserClickedItemText item ->
            ( { model | editedItem = Just item }, Cmd.none )

        UserClickedNoteContent ->
            ( { model | isEditingContent = True }, focusOn textEditorId NoOp )

        UserClickedNoteDeleteButton ->
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
                |> withMessageToRetry (Just UserClickedNoteDeleteButton)
            , deleteNoteCmd noteToDelete (ServerDeletedNote noteToDelete.id)
            )

        UserClickedNoteTitle ->
            ( { model | isEditingTitle = True }, focusOn titleEditorId NoOp )

        UserClickedTextButton ->
            ( convert model toText
            , Cmd.none
            )

        UserClickedTodoListButton ->
            let
                updatedModel =
                    convert model toTodoList
            in
            case updatedModel.content of
                TodoList items ->
                    if List.isEmpty items then
                        updatedModel
                            |> addItemToEmptyTodoList

                    else
                        ( updatedModel, Cmd.none )

                _ ->
                    ( updatedModel, Cmd.none )

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
                    model |> addItem

                Escape ->
                    ( model |> withEditedItem Nothing
                    , Cmd.none
                    )

                Other ->
                    ( model, Cmd.none )

        UserValidatedTitle ->
            ( { model | isEditingTitle = False }, Cmd.none )


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


convert : Model -> (Note -> Note) -> Model
convert model converter =
    case model.note of
        Success note ->
            let
                convertedNote =
                    converter note

                updatedModel =
                    model |> withNote (Success convertedNote)
            in
            updatedModel

        _ ->
            model


{-| When adding an item to an empty list,
it automaticcaly is bieng edited
-}
addItemToEmptyTodoList : Model -> ( Model, Cmd Msg )
addItemToEmptyTodoList model =
    let
        newItem =
            { checked = False
            , order = 1
            , text = ""
            }
    in
    ( model
        |> withContent (TodoList [ newItem ])
        |> withEditedItem (Just newItem)
    , focusOn (itemId newItem) NoOp
    )


addItem : Model -> ( Model, Cmd Msg )
addItem model =
    case model.editedItem of
        Nothing ->
            ( model, Cmd.none )

        Just editedItem ->
            let
                newItem =
                    { checked = False
                    , order = editedItem.order
                    , text = ""
                    }

                updatedModel =
                    insertItemBefore newItem editedItem model
            in
            ( updatedModel
                |> withEditedItem (Just newItem)
            , focusOn (itemId newItem) NoOp
            )


insertItemBefore : Item -> Item -> Model -> Model
insertItemBefore itemToInsert referenceItem model =
    let
        updatedItems =
            case model.content of
                TodoList items ->
                    items
                        |> List.map
                            (\it ->
                                if it.order >= referenceItem.order then
                                    { it | order = it.order + 1 }

                                else
                                    it
                            )
                        |> (::) itemToInsert

                _ ->
                    -- impossible case; would mean there is an editedItem when the items list is empty
                    [ itemToInsert ]
    in
    model |> withContent (TodoList updatedItems)


moveItemBefore : Item -> Item -> Model -> Model
moveItemBefore itemToMove referenceItem model =
    case model.content of
        TodoList items ->
            let
                updatedItems =
                    List.map
                        (\item ->
                            { item
                                | order =
                                    if item.order == itemToMove.order then
                                        referenceItem.order + 1

                                    else if item.order > referenceItem.order then
                                        item.order + 1

                                    else
                                        item.order
                            }
                        )
                        items
            in
            model |> withContent (TodoList updatedItems)

        _ ->
            model


removeItem : Item -> Model -> Model
removeItem itemToRemove model =
    let
        updatedContent =
            case model.content of
                TodoList items ->
                    items
                        |> List.filter (\item -> item.order /= itemToRemove.order)
                        |> TodoList

                _ ->
                    model.content
    in
    model |> withContent updatedContent


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


itemAt : Int -> Model -> Maybe Item
itemAt order model =
    case model.content of
        TodoList items ->
            items
                |> List.filter (\it -> it.order == order)
                |> List.head

        _ ->
            Nothing


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
    form
        [ class "title-form"
        , onSubmit UserValidatedTitle
        ]
        [ input
            [ id titleEditorId
            , class titleEditorId
            , value title
            , onInput UserChangedTitle
            ]
            []
        ]


viewTextButton : Html Msg
viewTextButton =
    button
        [ class "header-button"
        , onClick UserClickedTextButton
        ]
        [ TextIcon.view
        , span [ class "button-text" ] [ text "Text" ]
        ]


viewTodoListButton : Html Msg
viewTodoListButton =
    button
        [ class "header-button"
        , onClick UserClickedTodoListButton
        ]
        [ TodoListButton.view
        , span [ class "button-text" ] [ text "Todo List" ]
        ]


titleEditorId : String
titleEditorId =
    "title-input"


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
        [ text "Click or tap to edit the title" ]


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
    let
        ( checkedItems, uncheckedItems ) =
            items
                |> List.partition .checked
    in
    div []
        (viewSortedItems model uncheckedItems
            ++ viewSortedItems model checkedItems
        )


viewSortedItems : Model -> List Item -> List (Html Msg)
viewSortedItems model items =
    items
        |> List.sortBy .order
        |> List.reverse
        |> List.map (viewItem model)


viewItem : Model -> Item -> Html Msg
viewItem model item =
    let
        className =
            if item.checked then
                "editor-item-checked"

            else
                "editor-item"
    in
    div [ class "item" ]
        [ viewItemdDropZone model item
        , div
            (class className :: dragAttributes item)
            [ viewIf (not item.checked) DragHandle.view
            , input
                [ type_ "checkbox"
                , checked item.checked
                , class "item-checkbox"
                , onClick (UserToggledItem item)
                ]
                []
            , viewItemText model item
            ]
        ]


dragAttributes : Item -> List (Attribute Msg)
dragAttributes item =
    Drag.onSourceDrag (draggedSourceConfig item.order) |> List.map Html.Styled.Attributes.fromUnstyled


viewItemdDropZone : Model -> Item -> Html Msg
viewItemdDropZone model item =
    let
        activityClassName =
            case model.dragAndDropStatus of
                NoDnD ->
                    "dropZone-inactive"

                Dragging _ ->
                    "dropZone-active"

        draggedItemOrder =
            case model.dragAndDropStatus of
                NoDnD ->
                    -1

                Dragging itemOrder ->
                    itemOrder

        hoveredClassName =
            case model.activeDropZone of
                Just hoveredItem ->
                    if hoveredItem.order == item.order && draggedItemOrder /= item.order then
                        "dropzone-hover"

                    else
                        ""

                Nothing ->
                    ""
    in
    div
        (class activityClassName
            :: class hoveredClassName
            :: (Drag.onDropTarget (dropTargetConfig item)
                    |> List.map Html.Styled.Attributes.fromUnstyled
               )
        )
        []


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
    if item.text == "" then
        viewItemTextPlaceholder item

    else
        div
            [ class "item-text-readonly"
            , onClick (UserClickedItemText item)
            ]
            [ text item.text
            , DeleteButton.view (UserClickedItemDeleteButton item)
            ]


viewItemTextPlaceholder : Item -> Html Msg
viewItemTextPlaceholder item =
    div
        [ class "item-text-placeholder"
        , onClick (UserClickedItemText item)
        ]
        [ text "Click or tap to edit"
        , DeleteButton.view (UserClickedItemDeleteButton item)
        ]


viewEditedItemText : Item -> Html Msg
viewEditedItemText item =
    div [ class "item-text-edited" ]
        [ input
            [ class "item-input"
            , id (itemId item)
            , type_ "text"
            , onKeyDown UserPressedKey
            , onInput UserChangedItemText
            , value item.text
            ]
            []
        , DeleteButton.view (UserClickedItemDeleteButton item)
        ]


itemId : Item -> String
itemId item =
    "item-input-" ++ String.fromInt item.order


onKeyDown : (Key -> Msg) -> Attribute Msg
onKeyDown msgConstructor =
    on "keydown"
        (Decode.map
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
        [ text "Click or tap to edit the note content" ]



--


viewDeleteButton : Html Msg
viewDeleteButton =
    div
        [ class "deleteButton"
        ]
        [ DeleteButton.view UserClickedNoteDeleteButton ]



--


dropTargetConfig : Item -> Drag.DropTargetConfig Msg
dropTargetConfig item =
    { dropEffect = Drag.MoveOnDrop
    , onOver = DragOver
    , onDrop = always (Drop item)
    , onEnter = Just (DraggedItemEnteredDropZone item)
    , onLeave = Just (DraggedItemLeftDropZone item)
    }


draggedSourceConfig : Int -> Drag.DraggedSourceConfig Msg
draggedSourceConfig order =
    { effectAllowed = { move = True, copy = False, link = False }
    , onStart = DragStart order
    , onEnd = always DragEnd
    , onDrag = Nothing
    }



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- MessageToast provides a subscription to close automatically
          MessageToast.subscriptions model.messageToast
        ]
