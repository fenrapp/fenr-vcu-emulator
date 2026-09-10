# Compatibility baseline

Implementation will vendor only the necessary pure protocol source from a committed FENR revision, with the MIT license and a file manifest. No working-tree changes or path dependencies are allowed.

Application authentication (V2) and OS Bluetooth bonding are separate. Neither successful GATT discovery nor subscription proves V2 authentication. macOS controls bonding and the PIN dialog.

Pinned source: fenr-ios-app commit `429e5a05f752ec8ac77cd88cb54e3fac65b6fc34`. Sources are read with git show at this revision, never from the working tree. The upcoming vendor manifest records the selected files. Protocol code retains the upstream MIT license.

Advertising intentionally includes only the 17-character synthetic local name. FENR scans without a service UUID filter, and a 128-bit advertised UUID would compete with the name for the limited advertising payload. All supported GATT services remain published and discoverable after connection. The user confirmed full-name discovery in iPhone LightBlue on 2026-09-10.

## Dashboard startup contract

The pinned client requires decoded notifications for 1002 (status), 2001 (speed), 2004 (map), 2005 (totals), **6004 (battery SOC)** and 4100 (brake telemetry) before reporting complete telemetry. Characteristic 6003 is battery parameters, not SOC; publishing an SOC payload there leaves the client waiting for battery telemetry.

The emulator now publishes SOC on 6004. An independent startup fixture checks the six full wire UUIDs, their sample lengths, authenticated subscriptions and live SOC changes. Unsupported battery-parameter data is not advertised as 6003.
