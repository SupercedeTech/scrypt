# Welcome to scrypt

This is a Haskell library providing bindings to [Colin Percival's scrypt implementation](http://www.tarsnap.com/scrypt.html). Scrypt is a key derivation function designed to be far more secure against hardware brute-force attacks than alternative functions such as PBKDF2 or bcrypt.

Details of the scrypt key derivation function are given in a paper by Colin Percival, Stronger Key Derivation via Sequential Memory-Hard Functions: [PDF](http://www.tarsnap.com/scrypt/scrypt-slides.pdf).

Unlike earlier versions of the `scrypt` library, this version is compatible with multiple OSes and architectures.

# Join in!

We are happy to receive bug reports, fixes, documentation enhancements, and other improvements.

Please report bugs via the [github issue tracker](http://github.com/SupercedeTech/scrypt/issues).

Master [git repository](http://github.com/SupercedeTech/scrypt):

    git clone git://github.com/SupercedeTech/scrypt.git

# Authors

This library was originally written by Falko Peters, <falko.peters@gmail.com>, with thanks to Thomas DuBuisson.

This library is maintained by Supercede Ltd., <support@supercede.com>.

