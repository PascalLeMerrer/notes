module Data.Note exposing (Content(..), Item, Note, decoder, empty, encoder, listDecoder)

import Json.Decode as Decode exposing (Decoder, fail, oneOf, succeed)
import Json.Decode.Pipeline exposing (optional, required, resolve)
import Json.Encode


type alias Note =
    { id : String
    , title : String
    , content : Content
    }


type Content
    = TodoList (List Item)
    | Text String
    | Empty


type alias Item =
    { checked : Bool
    , text : String
    }


empty : Note
empty =
    { id = ""
    , title = ""
    , content = Empty
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
        -- toNote is executed before resolve
        |> resolve


todoListNoteDecoder : Decoder Note
todoListNoteDecoder =
    succeed toTodoNote
        |> required "key" Decode.string
        |> required "title" Decode.string
        |> required "type" Decode.string
        |> required "content" itemListDecoder
        -- toNote is executed before resolve
        |> resolve


toTextNote : String -> String -> String -> String -> Decoder Note
toTextNote key title type_ content =
    case type_ of
        "Text" ->
            succeed (Note key title (Text content))

        "Empty" ->
            succeed (Note key title Empty)

        _ ->
            fail ("Invalid type: " ++ type_)


toTodoNote : String -> String -> String -> List Item -> Decoder Note
toTodoNote key title type_ items =
    case type_ of
        "TodoList" ->
            succeed (Note key title (TodoList items))

        _ ->
            fail ("Invalid type: " ++ type_)


encoder : Note -> Json.Encode.Value
encoder note =
    Json.Encode.object <|
        [ ( "key", Json.Encode.string note.id )
        , ( "title", Json.Encode.string note.title )
        , ( "type", encodeType note.content )
        , ( "content", encodeContent note.content )
        ]


encodeItem : Item -> Json.Encode.Value
encodeItem item =
    Json.Encode.object <|
        [ ( "checked", Json.Encode.bool item.checked )
        , ( "text", Json.Encode.string item.text )
        ]


itemListDecoder : Decoder (List Item)
itemListDecoder =
    Decode.list itemDecoder


itemDecoder : Decoder Item
itemDecoder =
    succeed Item
        |> required "checked" Decode.bool
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
