module Requests.Endpoint exposing (..)

import Data.Note exposing (Note, decoder, encoder, listDecoder)
import RemoteData exposing (RemoteData, WebData)
import RemoteData.Http exposing (get, post)


createNote : Note -> (WebData Note -> msg) -> Cmd msg
createNote note message =
    post "./notes" message decoder (encoder note)


getAllNotes : (WebData (List Note) -> msg) -> Cmd msg
getAllNotes message =
    get "./notes" message listDecoder
