module Fixtures exposing (..)

import Data.Note exposing (..)



--TODO ensure this module is used or delete it


allNotes =
    [ todoNote1, commonNote ]


todoNote1 =
    { id = "todo note 1"
    , title = "Todo Note 1"
    , content = TodoList [ doneItem, notDoneItem ]
    }


doneItem =
    { checked = True
    , text = "an item which is checked"
    }


notDoneItem =
    { checked = False
    , text = "an item which is not checked"
    }


commonNote =
    { id = "basic Note 1"
    , title = "A simple note"
    , content = Text "The note content after changing base URL"
    }
