{
  description = "C bindings for the Tarsnap `scrypt` package, compatible with the old Haskell scrypt library";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });
    in
    {
      overlay = (final: prev: {
        haskellPackages = prev.haskellPackages.override {
          overrides = hsFinal: hsPrev: {
            scrypt = hsFinal.callCabal2nix "scrypt" ./.
              { scrypt-kdf = prev.scrypt.dev; };
          };
        };
      });
      packages = forAllSystems (system: {
         scrypt = nixpkgsFor.${system}.haskellPackages.scrypt;
      });
      defaultPackage = forAllSystems (system: self.packages.${system}.scrypt);
      checks = self.packages;
      devShell = forAllSystems (system: let haskellPackages = nixpkgsFor.${system}.haskellPackages;
        in haskellPackages.shellFor {
          packages = p: [self.packages.${system}.scrypt];
          withHoogle = false;
          buildInputs = with haskellPackages; [
            cabal-install
            c2hs
          ];
        });
  };
}
