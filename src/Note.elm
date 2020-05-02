module Note exposing (..)


type alias Note =
    { title : String
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
