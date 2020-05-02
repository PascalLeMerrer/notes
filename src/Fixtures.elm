module Fixtures exposing (..)

import Note exposing (..)


allNotes =
    [ todoNote1, commonNote ]


todoNote1 =
    { title = "Todo Note 1"
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
    { title = "A simple note"
    , content = Text "The note content"
    }
