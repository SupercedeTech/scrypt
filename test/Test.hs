{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import Crypto.Scrypt
import qualified Data.ByteString as B
import Data.Maybe
import Test.Framework (Test, defaultMain, testGroup)
import Test.Framework.Providers.HUnit (testCase)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.HUnit ((@=?))
import Test.QuickCheck


instance Arbitrary ScryptParams where
    arbitrary = do
        logN <- elements [1..14]
        r    <- elements [1..8]
        p    <- elements [1..2]
        bufLen <- elements [1..128]
        frequency
            [(  1, return defaultParams)
            ,(100, return . fromJust $ scryptParamsLen logN r p bufLen)
            ]

instance Arbitrary B.ByteString where
    arbitrary = B.pack <$> arbitrary
    
instance Arbitrary Pass where
    arbitrary = Pass <$> arbitrary

instance Arbitrary Salt where
    arbitrary = Salt <$> arbitrary


main :: IO ()
main = defaultMain
    [ testGroup "Test Vectors" testVectors
    , testGroup "Properties"
        [ testProperty "wrong pass is invalid" prop_WrongPassNotValid
        , testProperty "encrypt/verify" prop_EncryptVerify
        , testProperty "encrypt/verify'" prop_EncryptVerify'
        , testProperty "new params ==> new encryption" prop_NewParamsNewEncr
        ]
    ]

prop_WrongPassNotValid :: Pass -> Pass -> ScryptParams -> Salt -> Property
prop_WrongPassNotValid pass candidate params salt =
    pass /= candidate           ==>
    -- Trailing NULs in a password don't change the hash. Colin Percival: This
    -- is normal; it results from the identical behaviour in HMAC-*, since the
    -- only places scrypt handles the password directly, it is being input to
    -- HMAC-SHA256 as a key.
    not (trailingNUL pass)      ==>
    not (trailingNUL candidate) ==>
        let encr             = encryptPass params salt pass
            (valid, newEncr) = verifyPass params candidate encr
        in not valid && isNothing newEncr
  where
    trailingNUL (Pass p) = not (B.null p) && B.last p == 0

prop_EncryptVerify :: ScryptParams -> Salt -> Pass -> Property
prop_EncryptVerify params salt pass = 
    let encr             = encryptPass params salt pass
        (valid, newEncr) = verifyPass params pass encr
    in property $ valid && isNothing newEncr

prop_EncryptVerify' :: ScryptParams -> Salt -> Pass -> Property
prop_EncryptVerify' params salt pass =
    property $ verifyPass' pass (encryptPass params salt pass)

prop_NewParamsNewEncr
    :: ScryptParams -> ScryptParams -> Salt -> Pass -> Property
prop_NewParamsNewEncr oldParams newParams salt pass =
    oldParams /= newParams ==>
        let encr            = encryptPass oldParams salt pass        
            (valid,newEncr) = verifyPass newParams pass encr
        in valid && isJust newEncr && fromJust newEncr /= encr

-- |Test vectors from the scrypt paper.
--
testVectors :: [Test]
testVectors = map toTestCase vecs
  where
    toTestCase (pass, salt, logN, r, p, dk) =
        let params = fromJust $ scryptParams logN r p
        in testCase (unwords ["vec:", show pass, show salt, show params]) $
                PassHash (B.pack dk) @=? scrypt params (Salt salt) (Pass pass)
    
    vecs =
        [( "", "", 4, 1, 1,
            [ 0x77, 0xd6, 0x57, 0x62, 0x38, 0x65, 0x7b, 0x20
            , 0x3b, 0x19, 0xca, 0x42, 0xc1, 0x8a, 0x04, 0x97
            , 0xf1, 0x6b, 0x48, 0x44, 0xe3, 0x07, 0x4a, 0xe8
            , 0xdf, 0xdf, 0xfa, 0x3f, 0xed, 0xe2, 0x14, 0x42
            , 0xfc, 0xd0, 0x06, 0x9d, 0xed, 0x09, 0x48, 0xf8
            , 0x32, 0x6a, 0x75, 0x3a, 0x0f, 0xc8, 0x1f, 0x17
            , 0xe8, 0xd3, 0xe0, 0xfb, 0x2e, 0x0d, 0x36, 0x28
            , 0xcf, 0x35, 0xe2, 0x0c, 0x38, 0xd1, 0x89, 0x06
            ])
        ,("password", "NaCl", 10, 8, 16,
            [ 0xfd, 0xba, 0xbe, 0x1c, 0x9d, 0x34, 0x72, 0x00
            , 0x78, 0x56, 0xe7, 0x19, 0x0d, 0x01, 0xe9, 0xfe
            , 0x7c, 0x6a, 0xd7, 0xcb, 0xc8, 0x23, 0x78, 0x30
            , 0xe7, 0x73, 0x76, 0x63, 0x4b, 0x37, 0x31, 0x62
            , 0x2e, 0xaf, 0x30, 0xd9, 0x2e, 0x22, 0xa3, 0x88
            , 0x6f, 0xf1, 0x09, 0x27, 0x9d, 0x98, 0x30, 0xda
            , 0xc7, 0x27, 0xaf, 0xb9, 0x4a, 0x83, 0xee, 0x6d
            , 0x83, 0x60, 0xcb, 0xdf, 0xa2, 0xcc, 0x06, 0x40
            ])
        ,("pleaseletmein", "SodiumChloride", 14, 8, 1,
            [ 0x70, 0x23, 0xbd, 0xcb, 0x3a, 0xfd, 0x73, 0x48
            , 0x46, 0x1c, 0x06, 0xcd, 0x81, 0xfd, 0x38, 0xeb
            , 0xfd, 0xa8, 0xfb, 0xba, 0x90, 0x4f, 0x8e, 0x3e
            , 0xa9, 0xb5, 0x43, 0xf6, 0x54, 0x5d, 0xa1, 0xf2
            , 0xd5, 0x43, 0x29, 0x55, 0x61, 0x3f, 0x0f, 0xcf
            , 0x62, 0xd4, 0x97, 0x05, 0x24, 0x2a, 0x9a, 0xf9
            , 0xe6, 0x1e, 0x85, 0xdc, 0x0d, 0x65, 0x1e, 0x40
            , 0xdf, 0xcf, 0x01, 0x7b, 0x45, 0x57, 0x58, 0x87
            ])
        -- ,("pleaseletmein", "SodiumChloride", 20, 8, 1,
        --      [ 0x21, 0x01, 0xcb, 0x9b, 0x6a, 0x51, 0x1a, 0xae
        --      , 0xad, 0xdb, 0xbe, 0x09, 0xcf, 0x70, 0xf8, 0x81
        --      , 0xec, 0x56, 0x8d, 0x57, 0x4a, 0x2f, 0xfd, 0x4d
        --      , 0xab, 0xe5, 0xee, 0x98, 0x20, 0xad, 0xaa, 0x47
        --      , 0x8e, 0x56, 0xfd, 0x8f, 0x4b, 0xa5, 0xd0, 0x9f
        --      , 0xfa, 0x1c, 0x6d, 0x92, 0x7c, 0x40, 0xf4, 0xc3
        --      , 0x37, 0x30, 0x40, 0x49, 0xe8, 0xa9, 0x52, 0xfb
        --      , 0xcb, 0xf4, 0x5c, 0x6f, 0xa7, 0x7a, 0x41, 0xa4
        --      ])
        ]
