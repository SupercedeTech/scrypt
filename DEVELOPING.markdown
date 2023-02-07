# Development

This repository is a [Nix flake](https://nixos.wiki/wiki/Flakes).

The supported way to start developing is to drop into the development shell,
with `nix develop`. Make sure you have Nix installed for this, and that
the necessary Nix features for using flakes are enabled.

Before starting development, you may want to update the pinned flake inputs in
`flake.lock` if you want the flake to use your system's package set. Otherwise,
you will use the pinned package set, which may be out of date. To update the
inputs, run this before entering the development shell:

```
nix flake update
```

Inside the development shell, you should be able to use `cabal` commands as
normal i.e.

  * `cabal v2-build` to compile the library - this will call `c2hs` automatically
  * `cabal test` to compile and run the tests

## cabal2nix

Because of issues with using `callCabal2nix` in the flake overlay, this project
relies on a manually-generated Nix derivation to define the Haskell package.
This file is still generated with `cabal2nix`, but it is simply tracked in the
git history.

It should be regenerated every time `scrypt.cabal` is edited. To regenerate the
file after editing `scrypt.cabal`, run this in the development shell:

```
cabal2nix . > cabal2nix-scrypt.nix
```

## c2hs

Because of a peculiarity with how the `scrypt` C library defines its public
function API, we rely on `c2hs` to do some preprocessing of our Haskell files.

If you use the development approach supported above, this should be handled
automatically for you. Otherwise, you will have to generate the Haskell code
yourself manually.

## libscrypt-kdf

Generating the Haskell bindings for this library requires a copy of the
`libscrypt-kdf` library that includes the development header.

This header is provided by the Nix flake automatically. If you aren't using Nix,
you will probably have to install it manually - look for `libscrypt-kdf` in your
package manager.
