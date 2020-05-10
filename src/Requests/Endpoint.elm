module Requests.Endpoint exposing (..)

import Data.Note exposing (Note, decoder, encode, listDecoder)
import RemoteData exposing (RemoteData, WebData)
import RemoteData.Http exposing (delete, get, post, put)


createNote : Note -> (WebData Note -> msg) -> Cmd msg
createNote note message =
    post "./notes" message decoder (encode note)


updateNote : Note -> (WebData Note -> msg) -> Cmd msg
updateNote note message =
    put "./notes" message decoder (encode note)


deleteNote : Note -> (WebData String -> msg) -> Cmd msg
deleteNote note message =
    delete ("./notes?id=" ++ note.id) message (encode note)


getAllNotes : (WebData (List Note) -> msg) -> Cmd msg
getAllNotes message =
    get "./notes" message listDecoder
