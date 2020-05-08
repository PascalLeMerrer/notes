module Requests.Endpoint exposing (..)

import Data.Note exposing (Note, encodeNote, noteDecoder, noteListDecoder)
import RemoteData exposing (RemoteData, WebData)
import RemoteData.Http exposing (get, post)


createNote : Note -> (WebData Note -> msg) -> Cmd msg
createNote note message =
    post "./notes" message noteDecoder (encodeNote note)


getAllNotes : (WebData (List Note) -> msg) -> Cmd msg
getAllNotes message =
    get "./notes" message noteListDecoder
