import 'package:flutter/material.dart';

import 'package:icure_medical_device_dart_sdk/api.dart';
import 'package:md_flutter_app/patient_details.dart';
import 'utils/date_utils.dart';
import 'patient_search.dart';

class MainRouter {
  MainRouter(this.medTechApi);

  Future<MedTechApi> medTechApi;

  Future<PatientSearch?> patientSearch(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          PatientSearch(router: this, title: 'Select patient', medTechApi: medTechApi)));

  Future<PatientSearch?> patientDetails(BuildContext context, Patient patient) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          PatientDetails(router: this, patient: patient, title: "${patient.firstName ?? ''} ${patient.lastName ?? ''} °${patient.dateOfBirth?.toShortDate() ?? '-'}", medTechApi: medTechApi)));

}