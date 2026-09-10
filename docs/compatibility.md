# Compatibility baseline

Only the necessary pure protocol sources from a committed FENR revision are vendored, with the MIT license and a checked file manifest. No working-tree sources or path dependencies are used.

Application authentication (V2) and OS Bluetooth bonding are separate. Neither successful GATT discovery nor subscription proves V2 authentication. macOS controls bonding and the PIN dialog.

Pinned source: fenr-ios-app commit `429e5a05f752ec8ac77cd88cb54e3fac65b6fc34`. Sources are read with git show at this revision, never from the working tree. Modules/ProtocolCore/UpstreamManifest.json records the selected files. Protocol code retains the upstream MIT license.

Advertising intentionally includes only the 17-character synthetic local name. FENR scans without a service UUID filter, and a 128-bit advertised UUID would compete with the name for the limited advertising payload. All supported GATT services remain published and discoverable after connection. The user confirmed full-name discovery in iPhone LightBlue on 2026-09-10.

## Dashboard startup contract

The pinned client requires decoded notifications for 1002 (status), 2001 (speed), 2004 (map), 2005 (totals), **6004 (battery SOC)** and 4100 (brake telemetry) before reporting complete telemetry. Characteristic 6003 is battery parameters, not SOC; publishing an SOC payload there leaves the client waiting for battery telemetry.

The emulator now publishes SOC on 6004. An independent startup fixture checks the six full wire UUIDs, their sample lengths, authenticated subscriptions and live SOC changes. Unsupported battery-parameter data is not advertised as 6003.

## Version 0.2.0 telemetry extensions

6004 includes optional DC voltage in tenths of a volt after SOC and health (6 bytes total). The FENR parser at `3c5582dd8c095c56f06c1482ef2dba85d4b6bf81` accepts this field. 5001 remains 19 bytes with requested/reported current in tenths and target-cell voltage in ten-thousandths. Charging interruption preserves charger connection while stopping current and charging. Signal flags retain the known status/brake layouts; raw charger status is diagnostic only.

Known configuration types remain 0, 1, 4, 5 and 8. Curve writes are 68 bytes and reads 64; there is no invented fragmentation. Core Bluetooth owns the CCCD and encryption negotiation. FENR's firmware/capability/no-op/readback checks remain necessary; emulator support never adds evidence about the actual motorcycle.

The FENR iOS authenticated-target identity correction is recorded at `3c5582dd8c095c56f06c1482ef2dba85d4b6bf81`. This emulator is independent of the iOS checkout.
