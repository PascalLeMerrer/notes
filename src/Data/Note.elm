module Data.Note exposing (Content(..), Item, Note, empty, encodeNote, noteDecoder, noteListDecoder)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
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


noteListDecoder : Decoder (List Note)
noteListDecoder =
    Json.Decode.list noteDecoder


noteDecoder : Decoder Note
noteDecoder =
    Json.Decode.succeed Note
        |> required "id" Json.Decode.string
        |> required "title" Json.Decode.string
        |> required "content" contentDecoder


contentDecoder : Decoder Content
contentDecoder =
    let
        get noteContent =
            case noteContent of
                "TodoList" ->
                    Debug.todo "Cannot decode variant with params: TodoList"

                "Text" ->
                    Json.Decode.succeed <| Text noteContent

                "Empty" ->
                    Json.Decode.succeed Empty

                _ ->
                    Json.Decode.fail ("unknown value for Content: " ++ noteContent)
    in
    Json.Decode.string |> Json.Decode.andThen get


encodeNote : Note -> Json.Encode.Value
encodeNote note =
    Json.Encode.object <|
        [ ( "id", Json.Encode.string note.id )
        , ( "title", Json.Encode.string note.title )
        , ( "content", encodeContent note.content )
        ]



-- TODO: double-check generated code


encodeItem : Item -> Json.Encode.Value
encodeItem item =
    Json.Encode.object <|
        [ ( "checked", Json.Encode.bool item.checked )
        , ( "text", Json.Encode.string item.text )
        ]



-- TODO: double-check generated code


encodeContent : Content -> Json.Encode.Value
encodeContent content =
    case content of
        TodoList items ->
            Json.Encode.list encodeItem items

        Text string ->
            Json.Encode.string string

        Empty ->
            Json.Encode.string "Empty"
