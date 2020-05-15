module Data.Note exposing (Content(..), Item, Note, decoder, empty, encode, listDecoder, toText, toTodoList)

import Json.Decode as Decode exposing (Decoder, fail, oneOf, succeed)
import Json.Decode.Pipeline exposing (optional, required, resolve)
import Json.Encode


type alias Note =
    { id : String
    , title : String
    , content : Content
    , order : Int
    }


withContent : Content -> Note -> Note
withContent content note =
    { note | content = content }


type Content
    = TodoList (List Item)
    | Text String
    | Empty


type alias Item =
    { checked : Bool
    , order : Int
    , text : String
    }


empty : Note
empty =
    { id = ""
    , title = ""
    , content = Empty
    , order = 0
    }


listDecoder : Decoder (List Note)
listDecoder =
    Decode.list decoder


decoder : Decoder Note
decoder =
    oneOf
        [ textNoteDecoder
        , todoListNoteDecoder
        ]


textNoteDecoder : Decoder Note
textNoteDecoder =
    succeed toTextNote
        |> required "key" Decode.string
        |> required "title" Decode.string
        |> required "type" Decode.string
        |> required "content" Decode.string
        |> required "order" Decode.int
        -- toNote is executed before resolve
        |> resolve


todoListNoteDecoder : Decoder Note
todoListNoteDecoder =
    succeed toTodoNote
        |> required "key" Decode.string
        |> required "title" Decode.string
        |> required "type" Decode.string
        |> required "content" itemListDecoder
        |> required "order" Decode.int
        -- toNote is executed before resolve
        |> resolve


toTextNote : String -> String -> String -> String -> Int -> Decoder Note
toTextNote key title type_ content order =
    case type_ of
        "Text" ->
            succeed (Note key title (Text content) order)

        "Empty" ->
            succeed (Note key title Empty order)

        _ ->
            fail ("Invalid type: " ++ type_)


toTodoNote : String -> String -> String -> List Item -> Int -> Decoder Note
toTodoNote key title type_ items order =
    case type_ of
        "TodoList" ->
            succeed (Note key title (TodoList items) order)

        _ ->
            fail ("Invalid type: " ++ type_)


encode : Note -> Json.Encode.Value
encode note =
    Json.Encode.object <|
        [ ( "key", Json.Encode.string note.id )
        , ( "title", Json.Encode.string note.title )
        , ( "type", encodeType note.content )
        , ( "content", encodeContent note.content )
        , ( "order", Json.Encode.int note.order )
        ]


encodeItem : Item -> Json.Encode.Value
encodeItem item =
    Json.Encode.object <|
        [ ( "checked", Json.Encode.bool item.checked )
        , ( "order", Json.Encode.int item.order )
        , ( "text", Json.Encode.string item.text )
        ]


itemListDecoder : Decoder (List Item)
itemListDecoder =
    Decode.list itemDecoder


itemDecoder : Decoder Item
itemDecoder =
    succeed Item
        |> required "checked" Decode.bool
        |> required "order" Decode.int
        |> required "text" Decode.string


encodeContent : Content -> Json.Encode.Value
encodeContent content =
    case content of
        TodoList items ->
            Json.Encode.list encodeItem items

        Text string ->
            Json.Encode.string string

        Empty ->
            Json.Encode.string ""


encodeType : Content -> Json.Encode.Value
encodeType content =
    case content of
        TodoList _ ->
            Json.Encode.string "TodoList"

        Text _ ->
            Json.Encode.string "Text"

        Empty ->
            Json.Encode.string "Empty"


toTodoList : Note -> Note
toTodoList note =
    case note.content of
        TodoList _ ->
            note

        Text text ->
            let
                newContent =
                    text
                        |> String.lines
                        |> List.reverse
                        |> List.indexedMap (\idx line -> { checked = False, order = idx + 1, text = line })
                        |> List.reverse
                        |> TodoList
            in
            note |> withContent newContent

        Empty ->
            note |> withContent (TodoList [])


toText : Note -> Note
toText note =
    case note.content of
        TodoList items ->
            let
                contentAsText =
                    items
                        |> List.map .text
                        |> String.join "\n"
            in
            if String.isEmpty contentAsText then
                note |> withContent Empty

            else
                note |> withContent (Text contentAsText)

        Text _ ->
            note

        Empty ->
            note
