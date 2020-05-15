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
    , order = 2
    , text = "an item which is checked"
    }


notDoneItem =
    { checked = False
    , order = 1
    , text = "an item which is not checked"
    }


commonNote =
    { id = "basic Note 1"
    , title = "A simple note"
    , content = Text "The note content after changing base URL"
    }


todoBuyingList : Note
todoBuyingList =
    { id = "todo note buying list"
    , title = "Liste de courses 13/05"
    , content = TodoList buyingList
    , order = 1
    }


buyingList =
    [ { checked = False
      , order = 24
      , text = "basilic"
      }
    , { checked = False
      , order = 23
      , text = "4 courgettes moyennes"
      }
    , { checked = False
      , order = 22
      , text = "Pommes de terre"
      }
    , { checked = False
      , order = 21
      , text = "2 beau poireaux ou 3 petits"
      }
    , { checked = False
      , order = 20
      , text = "300 grammes de courgette"
      }
    , { checked = False
      , order = 19
      , text = "200 grammes de carotte"
      }
    , { checked = False
      , order = 18
      , text = "350 grammes de pomme de terre"
      }
    , { checked = False
      , order = 17
      , text = "150 grammes d'épinard (en feuille)"
      }
    , { checked = False
      , order = 16
      , text = "Haricots verts"
      }
    , { checked = False
      , order = 15
      , text = "Haricots blancs"
      }
    , { checked = False
      , order = 14
      , text = "coriandre"
      }
    , { checked = False
      , order = 13
      , text = "Tomates"
      }
    , { checked = False
      , order = 12
      , text = "6 Saucisses de strasbourg"
      }
    , { checked = False
      , order = 11
      , text = "800 g de poulet"
      }
    , { checked = False
      , order = 10
      , text = "jambon sec 2 grandes ou 4 petites tranches"
      }
    , { checked = False
      , order = 9
      , text = "Jambon blanc x 2"
      }
    , { checked = False
      , order = 8
      , text = "levure de boulanger fraiche"
      }
    , { checked = False
      , order = 7
      , text = "saumon ou truite fumée"
      }
    , { checked = False
      , order = 6
      , text = "crevettes"
      }
    , { checked = False
      , order = 5
      , text = "pâte feuilletée"
      }
    , { checked = False
      , order = 4
      , text = "fromage"
      }
    , { checked = False
      , order = 3
      , text = "comté"
      }
    , { checked = False
      , order = 2
      , text = "beurre de cacahuète"
      }
    , { checked = False
      , order = 1
      , text = "oeufs"
      }
    ]
