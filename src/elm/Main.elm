module Main exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (class, classList, id, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode exposing (..)
import Navigation exposing (Location)
import Route exposing (..)
import UrlParser as Url exposing (..)


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = \x -> Sub.none
        }


type alias Model =
    { route : Route
    , searchQuery : String
    , searchResults : List SearchResult
    , currentPage : Resource
    , menuOpen : Bool
    , httpErrors : String
    , apiEndpoint : String
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    { route = parseLocation location
    , searchQuery = ""
    , searchResults = []
    , currentPage = Resource Nothing 0 Nothing
    , menuOpen = False
    , httpErrors = ""
    , apiEndpoint = "mediamatic.net"
    }
        ! [ checkRoute "mediamatic.net" <| parseLocation location ]


checkRoute : String -> Route -> Cmd Msg
checkRoute endpoint route =
    case route of
        Home ->
            Cmd.none

        Search (Just x) ->
            performSearch endpoint x

        Search Nothing ->
            Cmd.none

        Page x ->
            getCurrentPage endpoint x


type Msg
    = NoOp
    | NewUrl String
    | UrlChange Location
    | EnterSearchQuery String
    | EnterApiEndpoint String
    | GotSearchResults (Result Http.Error (List SearchResult))
    | GotPage (Result Http.Error Resource)
    | ToggleMenu


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        NewUrl url ->
            model ! [ Navigation.newUrl url ]

        UrlChange location ->
            let
                route =
                    parseLocation location

                getData =
                    checkRoute model.apiEndpoint route
            in
            { model | route = parseLocation location } ! [ getData ]

        EnterSearchQuery query ->
            { model | searchQuery = query } ! []

        EnterApiEndpoint endpoint ->
            { model | apiEndpoint = endpoint } ! []

        GotSearchResults (Ok results) ->
            { model | searchResults = results } ! []

        GotSearchResults (Err x) ->
            { model | httpErrors = toString x } ! []

        GotPage (Ok page) ->
            { model | currentPage = page } ! []

        GotPage (Err x) ->
            { model | httpErrors = toString x } ! []

        ToggleMenu ->
            { model | menuOpen = not model.menuOpen } ! []


view : Model -> Html Msg
view model =
    let
        currentView =
            case model.route of
                Home ->
                    resultsView model

                Search x ->
                    resultsView model

                Page _ ->
                    pageView model.currentPage
    in
    div
        []
        [ main_ []
            [ searchView model
            , p [] [ text model.httpErrors ]
            , currentView
            , footerView model
            ]
        ]


footerView : Model -> Html Msg
footerView { apiEndpoint } =
    footer []
        [ input [ onInput EnterApiEndpoint, Attr.value apiEndpoint ] []
        ]


searchView : Model -> Html Msg
searchView model =
    section [ class "search-view" ]
        [ form
            [ class "search-form", onSubmit (NewUrl ("/search/?q=" ++ model.searchQuery)) ]
            [ input [ onInput EnterSearchQuery ] []
            , button [ type_ "submit", onClick (NewUrl ("/search/?q=" ++ model.searchQuery)) ] [ text "Search" ]
            ]
        ]


resultsView : Model -> Html Msg
resultsView { searchResults } =
    section []
        [ ul [ class "search-results" ] <| List.map resultsViewItem searchResults ]


resultsViewItem : SearchResult -> Html Msg
resultsViewItem { id, imageUrl } =
    let
        imageSrc =
            Maybe.withDefault "" imageUrl
    in
    li [ onClick (NewUrl ("/page/" ++ toString id)) ]
        [ img [ src imageSrc ] []
        , article []
            [ h3 [] [ text (toString id) ] ]
        ]


pageView : Resource -> Html Msg
pageView { title } =
    section [ class "page-view" ]
        [ div [ class "page-view_body" ]
            [ h2 [] [ text <| Maybe.withDefault "No title" title ]
            ]
        ]



-- HELPERS


isPageView : Route -> Bool
isPageView route =
    case route of
        Page _ ->
            True

        _ ->
            False


parseLocation : Location -> Route
parseLocation location =
    location
        |> Url.parsePath route
        |> Maybe.withDefault Home



-- HTTP


performSearch : String -> String -> Cmd Msg
performSearch endpoint query =
    let
        url =
            "https://" ++ endpoint ++ "/api/search/?format=simple&cat_exclude=person&text=" ++ query
    in
    Http.send GotSearchResults (Http.get url searchResultDecoder)


getCurrentPage : String -> String -> Cmd Msg
getCurrentPage endpoint id =
    let
        url =
            "https://" ++ endpoint ++ "/api/base/export?id=" ++ id
    in
    Http.send GotPage (Http.get url resourceDecoder)


searchResultDecoder : Decode.Decoder (List SearchResult)
searchResultDecoder =
    Decode.list <|
        Decode.map2
            SearchResult
            (Decode.at [ "id" ] Decode.int)
            (Decode.maybe <| Decode.at [ "preview_url" ] Decode.string)


resourceDecoder : Decode.Decoder Resource
resourceDecoder =
    Decode.map3
        Resource
        (Decode.maybe <| Decode.at [ "rsc", "title", "trans", "en" ] Decode.string)
        (Decode.at [ "id" ] Decode.int)
        (Decode.maybe <| Decode.at [ "preview_url" ] Decode.string)



-- TYPES


type alias SearchResult =
    { id : Int
    , imageUrl : Maybe String
    }


type alias Resource =
    { title : Maybe String
    , id : Int
    , image : Maybe String
    }
