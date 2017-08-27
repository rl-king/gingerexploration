module Main exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (class, classList, id, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy as Lazy
import Http
import Icons as Icon
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
    , httpError : String
    , apiEndpoint : String
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    { route = parseLocation location
    , searchQuery = initSearchQuery location
    , searchResults = []
    , currentPage = Resource Nothing 0 Nothing Nothing
    , httpError = ""
    , apiEndpoint = "mediamatic.net"
    }
        ! [ Tuple.first <| checkRoute "mediamatic.net" <| parseLocation location ]


initSearchQuery : Location -> String
initSearchQuery location =
    location
        |> parseLocation
        |> checkRoute "mediamatic.net"
        |> Tuple.second
        |> Maybe.withDefault ""


checkRoute : String -> Route -> ( Cmd Msg, Maybe String )
checkRoute endpoint route =
    case route of
        Home ->
            ( Cmd.none, Nothing )

        Search (Just x) ->
            ( performSearch endpoint x, Just x )

        Search Nothing ->
            ( Cmd.none, Nothing )

        Page x ->
            ( getCurrentPage endpoint x, Nothing )


type Msg
    = NoOp
    | NewUrl String
    | UrlChange Location
    | EnterSearchQuery String
    | EnterApiEndpoint String
    | GotSearchResults (Result Http.Error (List SearchResult))
    | GotPage (Result Http.Error Resource)


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

                ( getData, query ) =
                    checkRoute model.apiEndpoint route
            in
            { model
                | searchResults = []
                , httpError = ""
                , currentPage = Resource Nothing 0 Nothing Nothing
                , route = parseLocation location
            }
                ! [ getData ]

        EnterSearchQuery query ->
            { model | searchQuery = query } ! []

        EnterApiEndpoint endpoint ->
            { model | apiEndpoint = endpoint } ! []

        GotSearchResults (Ok results) ->
            { model | searchResults = results } ! []

        GotSearchResults (Err x) ->
            { model | httpError = toString x } ! []

        GotPage (Ok page) ->
            { model | currentPage = page } ! []

        GotPage (Err x) ->
            { model | httpError = toString x } ! []


view : Model -> Html Msg
view model =
    let
        currentView =
            case model.route of
                Home ->
                    resultsView model

                Search x ->
                    Lazy.lazy resultsView model

                Page _ ->
                    pageView model.currentPage
    in
    div
        []
        [ main_ []
            [ headerView model
            , currentView
            , p [] [ text model.httpError ]
            ]
        ]


headerView : Model -> Html Msg
headerView { apiEndpoint, searchQuery } =
    header []
        [ headerSearch searchQuery
        , headerEndpoint apiEndpoint searchQuery
        ]


headerEndpoint : String -> String -> Html Msg
headerEndpoint endpoint query =
    section [ class "header-endpoint" ]
        [ Icon.globe
        , form [ onSubmit (NewUrl ("/search/?q=" ++ query)) ]
            [ input [ onInput EnterApiEndpoint, Attr.value endpoint ] []
            ]
        ]


headerSearch : String -> Html Msg
headerSearch query =
    section [ class "header-search" ]
        [ Icon.search
        , form [ onSubmit (NewUrl ("/search/?q=" ++ query)) ]
            [ input [ onInput EnterSearchQuery, Attr.value query ] [] ]
        ]


resultsView : Model -> Html Msg
resultsView { searchResults } =
    section []
        [ ul [ class "search-results" ] <| List.map resultsViewItem searchResults ]


resultsViewItem : SearchResult -> Html Msg
resultsViewItem { title, id, imageUrl } =
    let
        imageSrc =
            Maybe.withDefault "" imageUrl

        rscTitle =
            Maybe.withDefault "No title" title
    in
    li [ onClick (NewUrl ("/page/" ++ toString id)) ]
        [ img [ src imageSrc ] [] ]


pageView : Resource -> Html Msg
pageView { title } =
    section [ class "page-view" ]
        [ div [ class "page-view_body" ]
            [ h2 [] [ text <| Maybe.withDefault "No title" title ]
            ]
        ]



-- HELPERS


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
        Decode.map3 SearchResult
            (Decode.maybe <|
                Decode.oneOf
                    [ Decode.at [ "title", "trans", "en" ] Decode.string
                    , Decode.at [ "title", "trans", "nl" ] Decode.string
                    ]
            )
            (Decode.at [ "id" ] Decode.int)
            (Decode.maybe <| Decode.at [ "preview_url" ] Decode.string)


resourceDecoder : Decode.Decoder Resource
resourceDecoder =
    Decode.map4
        Resource
        (Decode.maybe <|
            Decode.oneOf
                [ Decode.at [ "rsc", "title", "trans", "en" ] Decode.string
                , Decode.at [ "rsc", "title", "trans", "nl" ] Decode.string
                ]
        )
        (Decode.at [ "id" ] Decode.int)
        (Decode.maybe <| Decode.at [ "preview_url" ] Decode.string)
        (Decode.maybe <| Decode.at [ "edges" ] <| Decode.list edgeDecoder)


edgeDecoder : Decode.Decoder ResourceEdge
edgeDecoder =
    Decode.map2
        ResourceEdge
        (Decode.maybe <|
            Decode.oneOf
                [ Decode.at [ "predicate_title", "trans", "en" ] Decode.string
                , Decode.at [ "predicate_title", "trans", "nl" ] Decode.string
                ]
        )
        (Decode.at [ "predicate_id" ] Decode.int)



-- TYPES


type alias SearchResult =
    { title : Maybe String
    , id : Int
    , imageUrl : Maybe String
    }


type alias Resource =
    { title : Maybe String
    , id : Int
    , imageUrl : Maybe String
    , edges : Maybe (List ResourceEdge)
    }


type alias ResourceEdge =
    { title : Maybe String
    , id : Int
    }
