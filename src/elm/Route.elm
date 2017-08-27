module Route exposing (..)

import UrlParser as Url exposing (..)


type Route
    = Home
    | Search (Maybe String)
    | Page String


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Home top
        , Url.map Search (s "search" <?> stringParam "q")
        , Url.map Page (s "page" </> string)
        ]
