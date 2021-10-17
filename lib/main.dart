import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';


import 'payload.dart';

void main() {
  // We need to call it manually,
  // because we going to call setPreferredOrientations()
  // before the runApp() call
  WidgetsFlutterBinding.ensureInitialized();

  // Than we setup preferred orientations,
  // and only after it finished we run our app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ON Vax Card',
        home: MyHome()
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  QrCode qrCode = new QrCode(22, QrErrorCorrectLevel.L);
  Payload payload = new Payload();

  Future<String> getSHCDataFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/shcQRData.txt';

    return filePath;
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if(barcodeScanRes != "-1") {
      File file = File(await getSHCDataFilePath());
      await file.writeAsString(barcodeScanRes);
      final snackBar = SnackBar(content: Text('QR Code Data Saved to Device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      reloadQRData();
    }
  }

  Future<String> readSHCDataFile() async {
    File file = File(await getSHCDataFilePath());
    String fileContent = await file.readAsString();

    return fileContent;
  }

  Future<void> reloadQRData() async {
    String shcData = await readSHCDataFile();
    String qrData = shcData.split("shc:/")[1];

    qrCode = new QrCode(22, QrErrorCorrectLevel.L);
    qrCode.addData("shc:/");
    qrCode.addNumeric(qrData);
    qrCode.make();

    RegExp regExp = RegExp(r"\d{2}");
    Iterable matches = regExp.allMatches(qrData).map((number) => String.fromCharCode(int.tryParse(number.group(0)!)! + 45));
    var encoded = matches.join();
    String payloadJWS = encoded.split(".")[1];
    List<int> decoded = base64Url.decode(payloadJWS + List.filled((4 - payloadJWS.length % 4) % 4, '=').join());
    ZLibCodec zlc = new ZLibCodec(raw: true);
    List<int> inflated = zlc.decoder.convert(decoded);

    String payloadString = utf8.decode(inflated);

    payload = Payload.fromJson(jsonDecode(payloadString));

    setState((){});
  }

  @override
  initState() {
    super.initState();
    reloadQRData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ontario Vaccine SMART Code'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: "Scan Code",
            onPressed: () => scanQR(),
          )
        ]
      ),
      body:
        Column(
        children: <Widget>[
            QrImage.withQr(
            qr: qrCode,
            version: 22,
            errorCorrectionLevel: QrErrorCorrectLevel.L,
            errorStateBuilder: (cxt, err) {
              return Container(
                child: const Center(
                  child: Text("Error generating QR code...", textAlign: TextAlign.center),
                ),
              );
            },
          ),
          SizedBox(height: 10),
          Text("PATIENT INFO", style: new TextStyle(fontWeight: FontWeight.bold)),
          Text("Name: ${payload.vc.patient.patientGivenNames.join(" ")} ${payload.vc.patient.patientFamilyName}"),
          Text("Birthdate: ${payload.vc.patient.birthDate}"),
          for(var imm in payload.vc.immunizations)
            Column(
              children: <Widget>[
                SizedBox(height: 10),
                Text("VACCINE DOSE", style: new TextStyle(fontWeight: FontWeight.bold)),
                Text("Type: ${Immunization.fhirCodeToString(imm.FHIRVaccineCode)}"),
                Text("Lot: ${imm.lotNumber}"),
                Text("Administration Date: ${imm.occurrenceDateTime}"),
                Text("Performer: ${imm.performer}"),
              ]
            )
        ],
      ),
    );
  }
}