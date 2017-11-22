module Data_PersonalPathTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Lesson
import Language
import Data.PersonalPath exposing (..)

suite : Test
suite =
  let
    testLesson =
      Lesson.Lesson
        (Lesson.Id 1)
        "Test Lesson Title" 
        "Lesson Subtitle" 
        (Language.fromString "Language") 
        "Description..." 
        [] [] []

    testLesson2 =
      { testLesson | id = (Lesson.Id 2), title = "Test Lesson 2 Title" }

    addTestLesson =
      AddLesson testLesson
  in
    describe "update with AddLesson"
      [ test "adds a new lesson to personalPath" <|
        \_ ->
          let
              actual =
                update initialState addTestLesson

              expected =
                [ PersonalLesson testLesson Backlog ]
          in
              Expect.equal expected actual

      , test "doesn't add lesson if it's already in the personalPath" <|
        \_ ->
          let
              baseState =
                update initialState addTestLesson

              nextState =
                update baseState addTestLesson
          in
              Expect.equal baseState nextState

      , test "appends lesson to personalPath" <|
        \_ ->
          let
              baseState =
                update initialState addTestLesson

              actual =
                update baseState (AddLesson testLesson2)

              expected =
                [ (PersonalLesson testLesson Backlog), (PersonalLesson testLesson2 Backlog) ]
          in
              Expect.equal expected actual
      ]
