# Compatibility baseline

Implementation will vendor only the necessary pure protocol source from a committed FENR revision, with the MIT license and a file manifest. No working-tree changes or path dependencies are allowed.

Application authentication (V2) and OS Bluetooth bonding are separate. Neither successful GATT discovery nor subscription proves V2 authentication. macOS controls bonding and the PIN dialog.
