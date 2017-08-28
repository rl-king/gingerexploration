port module Stylesheets exposing (..)

import Css exposing (..)
import Css.Elements as E
import Css.File
import ModularScale


port files : Css.File.CssFileStructure -> Cmd msg


cssFiles : Css.File.CssFileStructure
cssFiles =
    Css.File.toFileStructure [ ( "main.css", Css.compile [ css ] ) ]


main : Css.File.CssCompilerProgram
main =
    Css.File.compiler files cssFiles


css : Stylesheet
css =
    Css.stylesheet <|
        List.concat
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
    , E.h2
        [ fontSize (ms 2)
        , fontWeight (int 500)
        , padding zero
        , margin zero
        ]
    , E.h3
        [ fontSize (ms 0)
        , fontWeight (int 500)
        , padding2 (Css.rem 0.5) zero
        , margin zero
        ]
    , E.h5
        [ padding zero
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
    [ everything
        [ boxSizing borderBox
        ]
    , E.body
        [ color (mono B3)
        , backgroundColor (mono W1)
        , fontFamilies sans
        ]
    , E.main_
        [ marginTop (Css.rem 4)
        ]
    , searchResults
    , pageView
    ]


searchResults : Css.Snippet
searchResults =
    class "search-results"
        [ descendants
            [ E.ul
                [ position absolute
                , top (Css.rem 4)
                , left zero
                ]
            , E.li
                [ backgroundColor (mono W3)
                , displayFlex
                , justifyContent center
                , alignItems center
                , position absolute
                , top zero
                , left zero
                ]
            , E.img
                [ borderRadius (px 2)
                , width (pct 100)
                , height auto
                ]
            ]
        ]


pageView : Css.Snippet
pageView =
    class "page-view"
        [ descendants
            [ E.ul
                [ displayFlex
                , flexWrap wrap
                , justifyContent spaceBetween
                ]
            , E.li
                [ backgroundColor (mono W3)
                , displayFlex
                , flexWrap wrap
                , justifyContent center
                , alignItems flexStart
                , width (pct 4.8)
                ]
            , E.img
                [ borderRadius (px 2)
                , width (pct 100)
                , height auto
                ]
            , class "page-view_header"
                [ displayFlex
                , justifyContent center
                , paddingTop (Css.rem 2)
                , descendants
                    [ E.img
                        [ width (px 400)
                        , height auto
                        ]
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
    , interval = ModularScale.MajorSecond
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


monoValues : List ( Mono, Int )
monoValues =
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


mono : Mono -> Color
mono v =
    case List.filter ((==) v << Tuple.first) monoValues of
        [ ( x, y ) ] ->
            rgb y y y

        _ ->
            rgba 0 0 0 0


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
