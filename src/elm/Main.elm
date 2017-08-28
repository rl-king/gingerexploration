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
import Task
import UrlParser as Url exposing (..)
import Window


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type alias Model =
    { route : Route
    , searchQuery : String
    , searchResults : List SearchResult
    , currentPage : Resource
    , currentPageOutgoing : List SearchResult
    , currentPageIncoming : List SearchResult
    , httpError : String
    , apiEndpoint : String
    , windowSize : Window.Size
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            parseLocation location

        ( getData, query ) =
            checkRoute "mediamatic.net" route
    in
    { route = route
    , searchQuery = Maybe.withDefault "" query
    , searchResults = []
    , currentPage = Resource Nothing 0 Nothing Nothing
    , currentPageOutgoing = []
    , currentPageIncoming = []
    , httpError = ""
    , apiEndpoint = "mediamatic.net"
    , windowSize = Window.Size 0 0
    }
        ! [ getData, Task.perform SetWindowSize Window.size ]


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
    | GotPage (Result Http.Error ( Resource, List SearchResult, List SearchResult ))
    | SetWindowSize Window.Size


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

        GotPage (Ok ( page, outgoing, incoming )) ->
            { model
                | currentPage = page
                , currentPageOutgoing = outgoing
                , currentPageIncoming = incoming
            }
                ! []

        GotPage (Err x) ->
            { model | httpError = toString x } ! []

        SetWindowSize x ->
            { model | windowSize = x } ! []



-- VIEWS


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
                    pageView model.currentPage model.currentPageOutgoing model.currentPageIncoming
    in
    div
        []
        [ main_ []
            [ headerView model
            , currentView
            , p [] [ text model.httpError ]
            ]
        ]



-- HEADER VIEW


headerView : Model -> Html Msg
headerView { apiEndpoint, searchQuery } =
    header []
        [ headerSearch searchQuery
        , headerEndpoint apiEndpoint searchQuery
        ]


headerSearch : String -> Html Msg
headerSearch query =
    section [ class "header-search" ]
        [ Icon.search
        , form [ onSubmit (NewUrl ("/search/?q=" ++ query)) ]
            [ input [ onInput EnterSearchQuery, Attr.value query ] [] ]
        ]


headerEndpoint : String -> String -> Html Msg
headerEndpoint endpoint query =
    section [ class "header-endpoint" ]
        [ Icon.globe
        , form [ onSubmit (NewUrl ("/search/?q=" ++ query)) ]
            [ input [ onInput EnterApiEndpoint, Attr.value endpoint ] []
            ]
        ]



-- SEARCHRESULTS VIEW


resultsView : Model -> Html Msg
resultsView { searchResults, windowSize } =
    section [ class "search-results" ]
        [ ul [] <| List.indexedMap (resultsViewItem windowSize) searchResults ]


resultsViewItem : Window.Size -> Int -> SearchResult -> Html Msg
resultsViewItem windowSize index { title, id, imageUrl } =
    let
        ( itemWidth, itemHeight ) =
            ( toFloat windowSize.width / 5, toFloat windowSize.height / 5 )

        indexAsFloat =
            toFloat index

        offsetLeft =
            toString <| itemWidth * toFloat (index % 5)

        offsetTop =
            toString <| itemHeight * toFloat (floor (indexAsFloat * 0.2))

        imageWithFallback =
            case imageUrl of
                Just x ->
                    img [ src x ] []

                Nothing ->
                    div [] [ h5 [] [ text rscTitle ], small [] [ text "no-image" ] ]

        rscTitle =
            Maybe.withDefault "No title" title

        toPx x =
            toString x ++ "px"
    in
    li
        [ style
            [ "width" => toPx itemWidth
            , "height" => toPx itemHeight
            , "transform" => ("translate(" ++ offsetLeft ++ "px, " ++ offsetTop ++ "px)")
            , "padding" => "1rem"
            ]
        , onClick (NewUrl ("/page/" ++ toString id))
        ]
        [ imageWithFallback ]



-- SINGLE PAGE VIEW


pageView : Resource -> List SearchResult -> List SearchResult -> Html Msg
pageView { title, edges, imageUrl } outgoing incoming =
    section [ class "page-view" ]
        [ div [ class "page-view_header" ]
            [ div []
                [ img [ class "page-view_header-image", src <| Maybe.withDefault "" imageUrl ] []
                , h2 [] [ text <| Maybe.withDefault "No title" title ]
                ]
            ]
        , h3 [] [ text "Incoming edges" ]
        , ul [] <| List.map edge incoming
        , h3 [] [ text "Outgoing edges" ]
        , ul [] <| List.map edge outgoing
        ]


edge : SearchResult -> Html Msg
edge { title, id, imageUrl } =
    li [ onClick (NewUrl ("/page/" ++ toString id)) ]
        [ img [ src <| Maybe.withDefault "" imageUrl ] []
        , h6 [] [ text <| Maybe.withDefault "No title" title ]
        ]



-- HTTP REQUESTS


performSearch : String -> String -> Cmd Msg
performSearch endpoint query =
    let
        url =
            "https://" ++ endpoint ++ "/api/search/?format=simple&text=" ++ query
    in
    Http.send GotSearchResults (Http.get url searchResultDecoder)


getCurrentPage : String -> String -> Cmd Msg
getCurrentPage endpoint id =
    let
        pageEndpoint =
            "https://" ++ endpoint ++ "/api/base/export?id=" ++ id

        outgoingEndpoint =
            "https://" ++ endpoint ++ "/api/search/?format=simple&hasobject=" ++ id

        incomingEndpoint =
            "https://" ++ endpoint ++ "/api/search/?format=simple&hassubject=" ++ id

        getPage =
            Http.get pageEndpoint resourceDecoder
                |> Http.toTask

        getOutgoingEdges =
            Http.get outgoingEndpoint searchResultDecoder
                |> Http.toTask

        getIncomingEdges =
            Http.get incomingEndpoint searchResultDecoder
                |> Http.toTask
    in
    Task.attempt GotPage <| Task.map3 (,,) getPage getOutgoingEdges getIncomingEdges



--JSON DECODERS


searchResultDecoder : Decode.Decoder (List SearchResult)
searchResultDecoder =
    Decode.list <|
        Decode.map4 SearchResult
            (Decode.maybe <|
                Decode.oneOf
                    [ Decode.at [ "title", "trans", "en" ] Decode.string
                    , Decode.at [ "title", "trans", "nl" ] Decode.string
                    ]
            )
            (Decode.at [ "id" ] Decode.int)
            (Decode.maybe <| Decode.at [ "preview_url" ] Decode.string)
            (Decode.at [ "category" ] (Decode.list Decode.string))


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
    Decode.map3
        ResourceEdge
        (Decode.maybe <|
            Decode.oneOf
                [ Decode.at [ "predicate_title", "trans", "en" ] Decode.string
                , Decode.at [ "predicate_title", "trans", "nl" ] Decode.string
                ]
        )
        (Decode.at [ "object_id" ] Decode.int)
        (Decode.maybe <|
            Decode.oneOf
                [ Decode.at [ "object_title", "trans", "en" ] Decode.string
                , Decode.at [ "object_title", "trans", "nl" ] Decode.string
                ]
        )



-- TYPE ALIASES


type alias SearchResult =
    { title : Maybe String
    , id : Int
    , imageUrl : Maybe String
    , category : List String
    }


type alias Resource =
    { title : Maybe String
    , id : Int
    , imageUrl : Maybe String
    , edges : Maybe (List ResourceEdge)
    }


type alias ResourceEdge =
    { predicateTitle : Maybe String
    , id : Int
    , objectTitle : Maybe String
    }



-- HELPERS


parseLocation : Location -> Route
parseLocation =
    Url.parsePath route >> Maybe.withDefault Home


(=>) : a -> b -> ( a, b )
(=>) a b =
    ( a, b )
