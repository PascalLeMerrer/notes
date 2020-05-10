module NoteTest exposing (..)

import Data.Note exposing (Content(..), Note, decoder, encode)
import Expect exposing (Expectation)
import Json.Decode
import Json.Encode
import Test exposing (..)


textNote : Note
textNote =
    { id = "a key", title = "the title", content = Text "The note content" }


encodedTextNote : String
encodedTextNote =
    "{\"key\":\"a key\",\"title\":\"the title\",\"type\":\"Text\",\"content\":\"The note content\"}"


emptyNote : Note
emptyNote =
    { id = "a key", title = "the title", content = Empty }


encodedEmptyNote : String
encodedEmptyNote =
    "{\"key\":\"a key\",\"title\":\"the title\",\"type\":\"Empty\",\"content\":\"\"}"


todoNote : Note
todoNote =
    { id = "a key", title = "the title", content = TodoList [ { checked = False, text = "task1" }, { checked = True, text = "task2" } ] }


encodedTodoNote : String
encodedTodoNote =
    "{\"key\":\"a key\",\"title\":\"the title\",\"type\":\"TodoList\",\"content\":[{\"checked\":false,\"text\":\"task1\"},{\"checked\":true,\"text\":\"task2\"}]}"


suite : Test
suite =
    describe "The Note module"
        [ describe "decoder"
            [ test "should decode Json encoded text note" <|
                \_ ->
                    encodedTextNote
                        |> Json.Decode.decodeString decoder
                        |> Expect.equal (Ok textNote)
            , test "should decode Json encoded empty note" <|
                \_ ->
                    encodedEmptyNote
                        |> Json.Decode.decodeString decoder
                        |> Expect.equal (Ok emptyNote)
            , test "should decode Json encoded item list" <|
                \_ ->
                    encodedTodoNote
                        |> Json.Decode.decodeString decoder
                        |> Expect.equal (Ok todoNote)
            ]
        , describe "encoder"
            [ test "should encode text note in Json" <|
                \_ ->
                    textNote
                        |> encode
                        |> Json.Encode.encode 0
                        |> Expect.equal encodedTextNote
            , test "should encode empty note in Json" <|
                \_ ->
                    emptyNote
                        |> encode
                        |> Json.Encode.encode 0
                        |> Expect.equal encodedEmptyNote
            , test "should encode item list in Json" <|
                \_ ->
                    todoNote
                        |> encode
                        |> Json.Encode.encode 0
                        |> Expect.equal encodedTodoNote
            ]
        ]
