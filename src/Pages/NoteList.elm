module Pages.NoteList exposing (..)

import Components.Retry as Retry
import Components.Spinner as Spinner
import Data.Note as Note exposing (Content(..), Note)
import Fixtures exposing (todoBuyingList)
import Html.Styled exposing (Html, button, div, fromUnstyled, h2, input, p, text)
import Html.Styled.Attributes exposing (checked, class, type_)
import Html.Styled.Events exposing (onClick)
import List.Extra
import MessageToast exposing (MessageToast)
import RemoteData exposing (RemoteData(..), WebData)
import Requests.Endpoint exposing (getAllNotes)
import Utils.Html exposing (noContent)
import Utils.Http exposing (errorToString)


type Msg
    = ServerReturnedNoteList (WebData (List Note))
    | UserClickedNote Note
    | UserClickedRetry
    | UserCreatedNote Note
    | UserDeletedNote String
    | UserUpdatedNote Note
    | MessageToastChanged (MessageToast Msg)



-- MODEL


type alias Model =
    { messageToast : MessageToast Msg
    , notes : WebData (List Note)
    }


withMessageToast : MessageToast Msg -> Model -> Model
withMessageToast messageToast model =
    { model | messageToast = messageToast }


withNotes : WebData (List Note) -> Model -> Model
withNotes webDataNotes model =
    { model | notes = webDataNotes }


allNotes : Model -> List Note
allNotes model =
    case model.notes of
        NotAsked ->
            []

        Loading ->
            []

        Failure e ->
            []

        Success notes ->
            notes


init : ( Model, Cmd Msg )
init =
    ( { messageToast = MessageToast.init MessageToastChanged
      , notes = Success [ todoBuyingList ]
      }
    , Cmd.none
      --, getAllNotes ServerReturnedNoteList
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserClickedRetry ->
            ( model |> withNotes Loading
            , getAllNotes ServerReturnedNoteList
            )

        MessageToastChanged updatedMessageToast ->
            ( { model | messageToast = updatedMessageToast }, Cmd.none )

        UserClickedNote _ ->
            ( model, Cmd.none )

        UserCreatedNote note ->
            ( model |> withNotes (Success (note :: allNotes model))
            , Cmd.none
            )

        UserDeletedNote noteId ->
            let
                newNotes =
                    removeNoteWithId noteId (allNotes model)
            in
            ( model |> withNotes (Success newNotes)
            , Cmd.none
            )

        UserUpdatedNote updatedNote ->
            let
                newNotes =
                    List.Extra.setIf (\note -> note.id == updatedNote.id) updatedNote (allNotes model)
            in
            ( model |> withNotes (Success newNotes)
            , Cmd.none
            )

        ServerReturnedNoteList (Success notes) ->
            let
                sortedNotes =
                    List.sortWith orderComparison notes
            in
            ( model |> withNotes (Success sortedNotes)
            , Cmd.none
            )

        ServerReturnedNoteList (Failure err) ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( model
                |> withMessageToast toast
                |> withNotes (Failure err)
            , Cmd.none
            )

        ServerReturnedNoteList _ ->
            -- TODO handle other cases
            ( model, Cmd.none )


orderComparison : Note -> Note -> Order
orderComparison a b =
    if a.order < b.order then
        GT

    else if a.order > b.order then
        LT

    else
        EQ


{-| Remove an element with the given id
-}
removeNoteWithId : String -> List Note -> List Note
removeNoteWithId id =
    List.foldr
        (\note acc ->
            if note.id == id then
                acc

            else
                note :: acc
        )
        []



-- VIEW


view : Model -> Html Msg
view model =
    let
        toaster =
            fromUnstyled <| MessageToast.view model.messageToast
    in
    case model.notes of
        NotAsked ->
            div [ class "main-notelist" ] [ toaster ]

        Loading ->
            div [] [ Spinner.view, toaster ]

        Failure e ->
            div [ class "main-notelist" ]
                [ Retry.view "Ooops. Note loading failed. Is your device online?" UserClickedRetry
                , toaster
                ]

        Success notes ->
            div [ class "main-notelist" ]
                (List.map viewNote notes)


viewNote : Note -> Html Msg
viewNote note =
    div
        [ class "card"
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


{-| TODO: factorize with NoteEditor.viewItems.
-}
viewItems : List Note.Item -> Html Msg
viewItems items =
    items
        |> List.sortWith checkedComparison
        |> List.map viewItem
        |> div []


checkedComparison : Note.Item -> Note.Item -> Order
checkedComparison a b =
    if a.checked && not b.checked then
        GT

    else if b.checked && not a.checked then
        LT

    else
        EQ


viewItem : Note.Item -> Html msg
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
            , class "card-item"
            , checked item.checked
            ]
            []
        , text item.text
        ]


viewNoteText : String -> Html msg
viewNoteText noteContent =
    div [] [ text noteContent ]



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- MessageToast provides a subscription to close automatically
          MessageToast.subscriptions model.messageToast
        ]
