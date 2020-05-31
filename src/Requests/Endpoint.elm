module Requests.Endpoint exposing (createNoteCmd, deleteNoteCmd, getAllNotesCmd, updateNoteCmd)

import Data.Note exposing (Note, decoder, encode, listDecoder)
import RemoteData exposing (RemoteData, WebData)
import RemoteData.Http exposing (delete, get, post, put)


baseUrl =
    "https://pascal-notes.builtwithdark.com/"


createNoteCmd : Note -> (WebData Note -> msg) -> Cmd msg
createNoteCmd note message =
    post (baseUrl ++ "./notes") message decoder (encode note)


updateNoteCmd : Note -> (WebData Note -> msg) -> Cmd msg
updateNoteCmd note message =
    put (baseUrl ++ "./notes") message decoder (encode note)


deleteNoteCmd : Note -> (WebData String -> msg) -> Cmd msg
deleteNoteCmd note message =
    delete (baseUrl ++ "./notes?id=" ++ note.id) message (encode note)


getAllNotesCmd : (WebData (List Note) -> msg) -> Cmd msg
getAllNotesCmd message =
    get (baseUrl ++ "./notes") message listDecoder
