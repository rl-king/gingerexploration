module Icons exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)


search : Svg a
search =
    svg
        [ width "38", height "38", viewBox "0 0 38 38" ]
        [ g [ fill "none", stroke "#111", strokeWidth "4" ]
            [ circle [ cx "14", cy "14", r "12" ] []
            , Svg.path [ d "M21,21 L32,32" ] []
            ]
        ]


globe : Svg a
globe =
    svg
        [ width "38", height "38", viewBox "0 0 38 38" ]
        [ g [ fill "none", stroke "#111", strokeWidth "3", transform "rotate(10 13.42 26.958)" ]
            [ circle [ cx "17", cy "17", r "17" ] []
            , Svg.path [ d "M16.73 33.45c-5.88-3.4-8.92-8.96-9.12-16.72C7.43 8.96 10.47 3.4 16.74 0" ] []
            , Svg.path [ d "M33.46 15.2c-3.4 1.83-8.97 2.85-16.73 3.04-7.76.2-13.34-.82-16.73-3.04" ] []
            , Svg.path [ d "M16.73 33.45c5.9-3.18 8.94-8.75 9.12-16.72.18-7.98-2.87-13.55-9.12-16.73M16.73 33.45V0" ] []
            ]
        ]
