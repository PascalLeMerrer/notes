module Requests.Endpoint exposing (..)

import Data.Note exposing (Note, decoder, encode, listDecoder)
import RemoteData exposing (RemoteData, WebData)
import RemoteData.Http exposing (delete, get, post, put)


createNoteCmd : Note -> (WebData Note -> msg) -> Cmd msg
createNoteCmd note message =
    post "./notes" message decoder (encode note)


updateNoteCmd : Note -> (WebData Note -> msg) -> Cmd msg
updateNoteCmd note message =
    put "./notes" message decoder (encode note)


deleteNoteCmd : Note -> (WebData String -> msg) -> Cmd msg
deleteNoteCmd note message =
    delete ("./notes?id=" ++ note.id) message (encode note)


getAllNotesCmd : (WebData (List Note) -> msg) -> Cmd msg
getAllNotesCmd message =
    get "./notes" message listDecoder
