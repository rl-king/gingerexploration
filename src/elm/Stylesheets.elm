port module Stylesheets exposing (..)

import Css exposing (..)
import Css.Elements as E
import Css.File exposing (..)
import Css.Namespace exposing (namespace)
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
            [ inputs
            , headers
            , containers
            ]



-- HEADERS


headers =
    [ E.header
        [ position fixed
        , top zero
        , left zero
        , width (pct 100)
        , zIndex (int 1)
        , displayFlex
        , height (Css.rem 4)
        , backgroundColor (mono w2)
        , borderBottom3 (px 1) solid (mono w4)
        , descendants
            [ E.form
                [ width (pct 100)
                ]
            , E.input
                [ fontSize (ms 5)
                , height (Css.rem 2.5)
                , width (pct 100)
                , backgroundColor transparent
                , borderBottom3 (px 1) solid (mono g4)
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


containers =
    [ E.body
        [ color (mono b3)
        , backgroundColor (mono w1)
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
                [ backgroundColor (mono w3)
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
                [ backgroundColor (mono w3)
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


( b1, b2, b3, b4 ) =
    ( 6, 18, 26, 30 )
( w1, w2, w3, w4 ) =
    ( 255, 249, 243, 237 )
( g1, g2, g3, g4 ) =
    ( 164, 188, 212, 224 )


mono x =
    rgb x x x


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
    [ "-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", "sans-serif" ]
