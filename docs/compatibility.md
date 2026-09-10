# Compatibility baseline

Implementation will vendor only the necessary pure protocol source from a committed FENR revision, with the MIT license and a file manifest. No working-tree changes or path dependencies are allowed.

Application authentication (V2) and OS Bluetooth bonding are separate. Neither successful GATT discovery nor subscription proves V2 authentication. macOS controls bonding and the PIN dialog.

Pinned source: fenr-ios-app commit `429e5a05f752ec8ac77cd88cb54e3fac65b6fc34`. Sources are read with git show at this revision, never from the working tree. The upcoming vendor manifest records the selected files. Protocol code retains the upstream MIT license.

Advertising intentionally includes only the 17-character synthetic local name. FENR scans without a service UUID filter, and a 128-bit advertised UUID would compete with the name for the limited advertising payload. All supported GATT services remain published and discoverable after connection. Full name delivery still requires physical verification.
