# ON Vax Card

A companion app for storing and displaying Ontario-issued SMART Health Card QR codes.

<img src="doc/app_screenshot.jpg?raw=true" width="360" height="780">

## Getting Started

This app allows you to scan-in your QR code from your Ontario-issued enhanced vaccine passport, save the QR code data to your phone, and quickly regenerate and display it.

Only the most recently scanned QR code is saved, and the original (encoded/encrypted) data is stored. Aside from decoding the data to display the patient and dose information on the screen, no further attempt is made to interpret the data. The original (encoded) data is what is stored on the device and used to re-generate and display the QR code when the app is opened.

Huge shout out to @obrassard (and the other projects credited in his project) who published sample code that was very helpful for development: https://github.com/obrassard/shc-extractor.

Also, this is the first time I've ever made an app (actually it's also the first time I've ever used Github or Git at all for that matter) so please bear with me.

## Dependencies

This project uses three external flutter libraries:

- qr_flutter: https://pub.dev/packages/qr_flutter
- flutter_barcode_scanner: https://pub.dev/packages/flutter_barcode_scanner
- path_provider: https://pub.dev/packages/path_provider

## Known Issues

Multi-chunk SMART codes are currently not supported, since a based two-dose record fits into a single chunk.

Also, the QR code generated by this app isn't the same as the QR code in the PDF even though the data and QR are the same, and I'm not sure why. Both seem to be compatible with the Verify Ontario app.

## Download/Installation

I'm currently working on getting this app on the Play Store. Theoretically an iOS version could follow since this is a flutter project, but that will likely only happen if there is demand.