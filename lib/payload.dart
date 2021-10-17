import 'dart:convert';

class Payload {
  String iss = "";
  double nbf = 0;
  VC vc = VC();

  Payload() {}

  Payload.fromJson(Map<String, dynamic> json) {
    iss = json['iss'];
    nbf = json['nbf'];
    vc = VC.fromJson(json['vc']);
  }
}

class VC {
  List<String> type = [];
  Patient patient = Patient();
  List<Immunization> immunizations = [];

  VC() {}

  VC.fromJson(Map<String, dynamic> json) {
    type = json['type'].cast<String>();

    List entries = json['credentialSubject']['fhirBundle']['entry'];
    for(var entry in entries) {
      if (entry['resource']['resourceType'] == "Patient") {
        patient = Patient.fromEntryJson(entry);
      } else if (entry['resource']['resourceType'] == "Immunization") {
        immunizations.add(Immunization.fromEntryJson(entry));
      }
    }
  }
}

class Patient {
  String patientFamilyName = "";
  List<String> patientGivenNames = [""];
  String birthDate = "";

  Patient() {}

  Patient.fromEntryJson(Map<String, dynamic> json) {
    patientFamilyName = json['resource']['name'][0]['family'];
    patientGivenNames = json['resource']['name'][0]['given'].cast<String>();
    birthDate = json['resource']['birthDate'];
  }
}

class Immunization {
  String FHIRVaccineCode = "";
  String occurrenceDateTime = "";
  String lotNumber = "";
  String performer = "";

  Immunization.fromEntryJson(Map<String, dynamic> json) {
    occurrenceDateTime = json['resource']['occurrenceDateTime'];
    lotNumber = json['resource']['lotNumber'];
    performer = json['resource']['performer'][0]['actor']['display'];

    List codes = json['resource']['vaccineCode']['coding'];

    for(var code in codes) {
      if(code['system'] == "http://hl7.org/fhir/sid/cvx") {
        FHIRVaccineCode = code['code'];
      }
    }
  }

  static String fhirCodeToString(String vaxCode) {
    switch(vaxCode) {
      case("207") :
        return "Moderna mRNA 100 mcg/0.5mL";
      case("208") :
        return "Pfizer mRNA 30 mcg/0.3mL";
      case("210") :
        return "Astrazenica 0.5mL";
      case("211") :
        return "Novavax 0.5mL";
      case("212") :
        return "Janssen (Johnson and Johnson) 0.5mL";
      case("213") :
        return "Unspecified";
      default :
        return "Invalid Code";
    }
  }
}