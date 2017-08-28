port module Stylesheets exposing (..)

import Css exposing (..)
import Css.Elements as E
import Css.File exposing (..)
import Css.Namespace exposing (namespace)
import Dict exposing (..)
import ModularScale exposing (..)


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure [ ( "main.css", Css.compile [ css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles


css =
    Css.stylesheet <|
        List.concatMap identity
            [ typography
            , inputs
            , headers
            , containers
            ]



-- TYPOGRAPHY


typography : List Css.Snippet
typography =
    [ E.ul
        [ listStyle none
        , padding zero
        , margin zero
        ]
    ]



-- HEADERS


headers : List Css.Snippet
headers =
    [ E.header
        [ position fixed
        , top zero
        , left zero
        , width (pct 100)
        , zIndex (int 1)
        , displayFlex
        , height (Css.rem 4)
        , backgroundColor (mono W2)
        , borderBottom3 (px 1) solid (mono W4)
        , descendants
            [ E.form
                [ width (pct 100)
                ]
            , E.input
                [ fontSize (ms 5)
                , height (Css.rem 2.5)
                , width (pct 100)
                , backgroundColor transparent
                , borderBottom3 (px 1) solid (mono G4)
                ]
            , E.section
                [ displayFlex
                , alignItems center
                , width (pct 50)
                , padding2 zero (Css.rem 1)
                ]
            , E.svg
                [ margin2 (px 4) (Css.rem 0.5)
                ]
            ]
        ]
    ]



-- CONTAINERS


containers : List Css.Snippet
containers =
    [ E.body
        [ color (mono B3)
        , backgroundColor (mono W1)
        , boxSizing borderBox
        , fontFamilies sans
        ]
    , E.main_
        [ marginTop (Css.rem 4)
        ]
    , class "search-results"
        [ property "column-count" "6"
        , padding (Css.rem 1)
        , descendants
            [ E.li
                [ backgroundColor (mono W3)
                , marginBottom (Css.rem 1)
                ]
            , E.img
                [ borderRadius (px 4)
                , width (pct 100)
                , height auto
                ]
            ]
        ]
    , class "page-view"
        [ property "column-count" "6"
        , padding (Css.rem 1)
        , descendants
            [ E.li
                [ backgroundColor (mono W3)
                , marginBottom (Css.rem 1)
                ]
            , E.img
                [ borderRadius (px 4)
                , width (pct 100)
                , height auto
                ]
            ]
        ]
    ]



-- INPUTS


inputs : List Css.Snippet
inputs =
    [ E.input
        [ padding2 zero (px 8)
        , margin zero
        , border zero
        , outline zero
        ]
    ]



-- MODULARSCALE


config : ModularScale.Config
config =
    { base = [ 1.2 ]
    , interval = MajorSecond
    }


ms : Int -> Em
ms =
    em << ModularScale.get config



-- VARIABLES


(=>) : a -> b -> ( a, b )
(=>) a b =
    ( a, b )


type Mono
    = B1
    | B2
    | B3
    | B4
    | W1
    | W2
    | W3
    | W4
    | G1
    | G2
    | G3
    | G4


mono : Mono -> Color
mono v =
    monochromeVariables
        |> List.filter (\( a, b ) -> a == v)
        |> List.head
        |> Maybe.withDefault ( B1, 0 )
        |> (\( x, y ) -> rgb y y y)


monochromeVariables : List ( Mono, Int )
monochromeVariables =
    [ B1 => 6
    , B2 => 18
    , B3 => 26
    , B4 => 30
    , W1 => 255
    , W2 => 249
    , W3 => 243
    , W4 => 237
    , G1 => 164
    , G2 => 188
    , G3 => 212
    , G4 => 224
    ]


blue =
    hex "009DE3"


green =
    hex "27C37F"


red =
    hex "ff3333"


yellow =
    hex "EEB021"


purple =
    hex "7F63D2"


pink =
    hex "f9b2e1"


orange =
    hex "FF8A30"


( tiny, small, medium, large, huge ) =
    ( 468, 768, 1024, 1240, 1660 )


sans =
    [ "-apple-system"
    , "BlinkMacSystemFont"
    , "Segoe UI"
    , "Roboto"
    , "Oxygen"
    , "Ubuntu"
    , "Cantarell"
    , "Fira Sans"
    , "Droid Sans"
    , "Helvetica Neue"
    , "sans-serif"
    ]
