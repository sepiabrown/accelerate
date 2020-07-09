{-# LANGUAGE BangPatterns        #-}
{-# LANGUAGE ConstraintKinds     #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications    #-}
-- |
-- Module      : Data.Array.Accelerate.Test.NoFib.Imaginary.SASUM
-- Copyright   : [2009..2020] The Accelerate Team
-- License     : BSD3
--
-- Maintainer  : Trevor L. McDonell <trevor.mcdonell@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
--

module Data.Array.Accelerate.Test.NoFib.Imaginary.SASUM (

  test_sasum

) where

import Prelude                                                  as P

import Data.Array.Accelerate                                    as A
import Data.Array.Accelerate.Sugar.Array                        as S
import Data.Array.Accelerate.Sugar.Elt                          as S
import Data.Array.Accelerate.Test.NoFib.Base
import Data.Array.Accelerate.Test.NoFib.Config
import Data.Array.Accelerate.Test.Similar

import Hedgehog
import qualified Hedgehog.Gen                                   as Gen
import qualified Hedgehog.Range                                 as Range

import Test.Tasty
import Test.Tasty.Hedgehog


test_sasum :: RunN -> TestTree
test_sasum runN =
  testGroup "sasum"
    [ at @TestInt8   $ testElt i8
    , at @TestInt16  $ testElt i16
    , at @TestInt32  $ testElt i32
    , at @TestInt64  $ testElt i64
    , at @TestWord8  $ testElt w8
    , at @TestWord16 $ testElt w16
    , at @TestWord32 $ testElt w32
    , at @TestWord64 $ testElt w64
    , at @TestHalf   $ testElt f16
    , at @TestFloat  $ testElt f32
    , at @TestDouble $ testElt f64
    ]
  where
    testElt :: forall a. (P.Num a, P.Eq a, A.Num a, A.Eq a, Similar a, Show a)
        => Gen a
        -> TestTree
    testElt e =
      testProperty (show (eltR @a)) $ test_sasum' runN e


test_sasum'
    :: (P.Num e, A.Num e, Similar e, Show e)
    => RunN
    -> Gen e
    -> Property
test_sasum' runN e =
  property $ do
    sh <- forAll ((Z:.) <$> Gen.int (Range.linear 0 16384))
    xs <- forAll (array sh e)
    let !go = runN sasum in go xs S.! Z ~~~ sasumRef xs

sasum :: A.Num e => Acc (Vector e) -> Acc (Scalar e)
sasum = A.fold (+) 0 . A.map abs

sasumRef :: (P.Num e, Elt e) => Vector e -> e
sasumRef xs = P.sum [ abs x | x <- toList xs ]

