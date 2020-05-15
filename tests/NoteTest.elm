module NoteTest exposing (..)

import Data.Note exposing (Content(..), Item, Note, decoder, encode, toTodoList)
import Expect exposing (Expectation)
import Json.Decode
import Json.Encode
import Test exposing (..)


textNote : Note
textNote =
    { id = "a key", title = "the title", content = Text "The note content", order = 1 }


encodedTextNote : String
encodedTextNote =
    "{\"key\":\"a key\",\"title\":\"the title\",\"type\":\"Text\",\"content\":\"The note content\",\"order\":1}"


multiLineTextNote : Note
multiLineTextNote =
    { id = "a key", title = "the title", content = Text "Line 1\nLine 2", order = 42 }


multiLineTextNoteItems : List Item
multiLineTextNoteItems =
    [ { checked = False, text = "Line 1" }, { checked = False, text = "Line 2" } ]


emptyNote : Note
emptyNote =
    { id = "a key", title = "the title", content = Empty, order = 2 }


encodedEmptyNote : String
encodedEmptyNote =
    "{\"key\":\"a key\",\"title\":\"the title\",\"type\":\"Empty\",\"content\":\"\",\"order\":2}"


items =
    [ { checked = False, text = "task1" }, { checked = True, text = "task2" } ]


todoNote : Note
todoNote =
    { id = "a key", title = "the title", content = TodoList items, order = 3 }


encodedTodoNote : String
encodedTodoNote =
    "{\"key\":\"a key\",\"title\":\"the title\",\"type\":\"TodoList\",\"content\":[{\"checked\":false,\"text\":\"task1\"},{\"checked\":true,\"text\":\"task2\"}],\"order\":3}"


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
        , describe "toTodolist"
            [ test "should let a Todolist note unchanged" <|
                \_ ->
                    case todoNote |> toTodoList |> .content of
                        TodoList actualItems ->
                            Expect.equal items actualItems

                        _ ->
                            Expect.fail "Unexpected note content"
            , test "should convert a text note into a Todo list" <|
                \_ ->
                    case multiLineTextNote |> toTodoList |> .content of
                        TodoList actualItems ->
                            Expect.equal multiLineTextNoteItems actualItems

                        _ ->
                            Expect.fail "Unexpected note content"
            , test "should convert an empty note into a enmpty Todo list" <|
                \_ ->
                    case emptyNote |> toTodoList |> .content of
                        TodoList actualItems ->
                            Expect.equal [] actualItems

                        _ ->
                            Expect.fail "Unexpected note content"
            ]
        ]
