module Utils.Http exposing (errorToString)

import Http exposing (Error(..))


errorToString : Http.Error -> String
errorToString error =
    case error of
        BadUrl errorMessage ->
            "Bad URL " ++ errorMessage

        Timeout ->
            "Timeout exceeded"

        NetworkError ->
            "Network error!"

        BadStatus errorMessage ->
            "Server returned an error " ++ String.fromInt errorMessage

        BadBody errorMessage ->
            "Bad message body " ++ errorMessage
