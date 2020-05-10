module Pages.NoteList exposing (..)

import Components.Spinner as Spinner
import Data.Note as Note exposing (Content(..), Note)
import Html.Styled exposing (Html, div, fromUnstyled, h2, input, text)
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
    | UserCreatedNote Note
    | UserDeletedNote String
    | UserUpdatedNote Note
    | MessageToastChanged (MessageToast Msg)



-- MODEL


type alias Model =
    { messageToast : MessageToast Msg
    , notes : WebData (List Note)
    }


withNotes : List Note -> Model -> Model
withNotes notes model =
    { model | notes = Success notes }


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
      , notes = NotAsked
      }
    , getAllNotes ServerReturnedNoteList
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MessageToastChanged updatedMessageToast ->
            ( { model | messageToast = updatedMessageToast }, Cmd.none )

        UserClickedNote _ ->
            ( model, Cmd.none )

        UserCreatedNote note ->
            ( model |> withNotes (note :: allNotes model)
            , Cmd.none
            )

        UserDeletedNote noteId ->
            let
                newNotes =
                    removeNoteWithId noteId (allNotes model)
            in
            ( model |> withNotes newNotes
            , Cmd.none
            )

        UserUpdatedNote updatedNote ->
            let
                newNotes =
                    List.Extra.setIf (\note -> note.id == updatedNote.id) updatedNote (allNotes model)
            in
            ( model |> withNotes newNotes
            , Cmd.none
            )

        ServerReturnedNoteList (Success notes) ->
            ( model |> withNotes notes
            , Cmd.none
            )

        ServerReturnedNoteList (Failure err) ->
            let
                toast =
                    model.messageToast
                        |> MessageToast.danger
                        |> MessageToast.withMessage (errorToString err)
            in
            ( { model | messageToast = toast }, Cmd.none )

        ServerReturnedNoteList _ ->
            -- TODO handle other cases
            ( model, Cmd.none )


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
    div [ class "flex-container fill-height" ] <|
        [ case model.notes of
            NotAsked ->
                Spinner.view

            Loading ->
                Spinner.view

            Failure e ->
                noContent

            Success notes ->
                viewNotes notes
        , fromUnstyled <| MessageToast.view model.messageToast
        ]


viewNotes : List Note -> Html Msg
viewNotes notes =
    div []
        (List.map viewNote notes)


viewNote : Note -> Html Msg
viewNote note =
    div
        [ class "clickable card"
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



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- MessageToast provides a subscription to close automatically
          MessageToast.subscriptions model.messageToast
        ]
