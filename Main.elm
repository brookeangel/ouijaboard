module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Process
import Random exposing (Seed)
import Task
import Time


{-|

    This program is a spooky Ouija board that we can view in the browser!
    Start it from the command line with elm-reactor

    Goal: Every 2 seconds, our spooky ouija board cursor moves to a new position

-}
main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


{-| This is "type" of our state
-}
type alias Model =
    { xPosition : Int
    , yPosition : Int
    }


{-| This is how we get our state, and our initial commands.

In Elm, a Command is a description of something our Elm program tells our computer to do!
We use commands in Elm for:

  - Setting timeouts
  - Getting the current time
  - Talking to JavaScript

We can get our random seed using a Command here!
Documentation: <http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Random>

-}
init : ( Model, Cmd Msg )
init =
    ( { xPosition = 100
      , yPosition = 100
      }
    , Time.now
        |> Task.map (\time -> Random.initialSeed (round time))
        |> Task.andThen (\seed -> Process.sleep 2000 |> Task.map (\_ -> seed))
        |> Task.perform NewPosition
    )


{-| A Message is something that can be triggered by a UI action in the View (or by a Command)

It gets passed to our update function and tells us how to change our model

-}
type Msg
    = NewPosition Seed


{-| An update function takes in a Message and a Model, and gives you back the new Model!

If you've used Redux, it's like the reducer

-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewPosition seed ->
            let
                ( newModel, newSeed ) =
                    Random.step
                        (Random.map2
                            (\x y ->
                                { xPosition = x
                                , yPosition = y
                                }
                            )
                            (Random.int 100 width)
                            (Random.int 100 height)
                        )
                        seed
            in
            ( newModel
            , Task.perform (\_ -> NewPosition newSeed) (Process.sleep 2000)
            )


width : Int
width =
    1000


height : Int
height =
    559


{-| A view takes our Model and produces HTML!

Because we are in a pure, functional language, we expect for the same Model to always give us the same View

Not so different from jsx, just has different syntax, [] instead of <>

-}
view : Model -> Html Msg
view model =
    let
        cursorX =
            toString model.xPosition ++ "px"

        cursorY =
            toString model.yPosition ++ "px"
    in
    div [ style [ ( "position", "relative" ) ] ]
        [ img
            [ style
                [ ( "width", "100%" )
                , ( "max-width", toString width ++ "px" )
                , ( "margin-left", "-50%" )
                , ( "position", "absolute" )
                , ( "left", "50%" )
                ]
            , src "assets/oujia_6.jpeg"
            ]
            []
        , div
            [ style
                [ ( "width", "100px" )
                , ( "height", "100px" )
                , ( "border-radius", "100%" )
                , ( "background-color", "rgba(0, 0, 0, 0.5)" )
                , ( "position", "absolute" )
                , ( "box-shadow", "0 0 20px yellow" )
                , ( "border", "5px solid black" )
                , ( "top", cursorY )
                , ( "left", cursorX )
                , ( "transition", "all 1s" )
                ]
            ]
            []
        ]
