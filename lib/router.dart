import 'package:flutter/material.dart';

import 'package:icure_medical_device_dart_sdk/api.dart';

import 'patient_search.dart';

class MainRouter {
  MainRouter(this.medTechApi);

  Future<MedTechApi> medTechApi;

  Future<PatientSearch?> patientSearch(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          PatientSearch(title: 'Select patient', medTechApi: medTechApi)));

}