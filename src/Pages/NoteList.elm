module Pages.NoteList exposing (..)

import Data.Note as Note exposing (Content(..), Note)
import Fixtures exposing (allNotes)
import Html.Styled exposing (Html, div, fromUnstyled, h2, input, text)
import Html.Styled.Attributes exposing (checked, class, type_)
import Html.Styled.Events exposing (onClick)
import MessageToast exposing (MessageToast)
import RemoteData exposing (RemoteData(..), WebData)
import Requests.Endpoint exposing (getAllNotes)
import Utils.Html exposing (noContent)
import Utils.Http exposing (errorToString)


type Msg
    = ServerReturnedNoteList (WebData (List Note))
    | UserClickedNote Note
    | UserCreatedNote Note
    | MessageToastChanged (MessageToast Msg)



-- MODEL


type alias Model =
    { messageToast : MessageToast Msg
    , notes : List Note
    }


init : ( Model, Cmd Msg )
init =
    ( { messageToast = MessageToast.init MessageToastChanged
      , notes = allNotes
      }
    , getAllNotes ServerReturnedNoteList
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ServerReturnedNoteList (Success notes) ->
            ( { model | notes = notes }
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

        UserClickedNote note ->
            ( model, Cmd.none )

        UserCreatedNote note ->
            ( { model | notes = note :: model.notes }
            , Cmd.none
            )

        MessageToastChanged updatedMessageToast ->
            ( { model | messageToast = updatedMessageToast }, Cmd.none )



-- VIEW


view model =
    div [ class "fill-height" ] <|
        (List.map viewNote model.notes
            ++ [ fromUnstyled <| MessageToast.view model.messageToast
               ]
        )


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
