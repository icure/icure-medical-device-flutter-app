import 'package:flutter/material.dart';
import 'package:icure_medical_device_dart_sdk/medtech_api.dart';
import 'package:md_flutter_app/patient_search.dart';

class MainRouter {
  MainRouter(this.medTechApi);

  Future<MedTechApi> medTechApi;

  Future<PatientSearch?> patientSearch(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          PatientSearch(title: 'Select patient', medTechApi: medTechApi)));

}