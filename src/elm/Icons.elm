module Icons exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)


search : Svg a
search =
    svg
        [ width "18", height "18", viewBox "0 0 18 18" ]
        [ g [ fill "none", fillRule "evenodd", stroke "#222", strokeWidth "3" ]
            [ circle [ cx "8", cy "8", r "6" ] []
            , Svg.path [ d "M11,11 L18,18" ] []
            ]
        ]
