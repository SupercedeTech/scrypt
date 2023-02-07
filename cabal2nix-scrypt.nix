{ mkDerivation, base, base64-bytestring, bytestring, c2hs, entropy
, HUnit, lib, QuickCheck, scrypt-kdf, test-framework
, test-framework-hunit, test-framework-quickcheck2
}:
mkDerivation {
  pname = "scrypt";
  version = "0.5.0";
  src = ./.;
  libraryHaskellDepends = [
    base base64-bytestring bytestring entropy
  ];
  librarySystemDepends = [ scrypt-kdf ];
  libraryToolDepends = [ c2hs ];
  testHaskellDepends = [
    base bytestring HUnit QuickCheck test-framework
    test-framework-hunit test-framework-quickcheck2
  ];
  homepage = "http://github.com/informatikr/scrypt";
  description = "Stronger password hashing via sequential memory-hard functions";
  license = lib.licenses.bsd3;
}
