import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:icure_medical_device_dart_sdk/api.dart';
import 'package:md_flutter_app/router.dart';

import 'utils/date_utils.dart';

class PatientDetails extends StatefulWidget {
  final Future<MedTechApi> medTechApi;
  final Patient patient;
  final MainRouter router;

  const PatientDetails({Key? key, required this.patient, required this.router, required this.title, required this.medTechApi})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  List<DataSample> _allDataSamples = [];
  List<DataSample> _selectedDataSamples = [];
  User? _loggedUser;
  String? _latestSearchString;

  Future<DataSampleApi> dataSampleApi() =>
      widget.medTechApi.then((mapi) => mapi.dataSampleApi);

  Future<UserApi> userApi() =>
      widget.medTechApi.then((mapi) => mapi.userApi);

  Future<Crypto> crypto() =>
      widget.medTechApi.then((mapi) => mapi.localCrypto);


  @override
  void initState() {
    dataSampleApi().then((api) async {
      try {
        log("Loading user");
        final user = await (await userApi()).getLoggedUser();
        if (user == null) {
          throw const FormatException('You have been unlogged');
        }
        final dss = await api.filterDataSample(
            await DataSampleFilter()
            .forHcp(HealthcareProfessional(id:user.healthcarePartyId!))
            .forPatients(await crypto(), [widget.patient]
            ).build());

        _allDataSamples = dss?.rows ?? [];
        _search(_latestSearchString ?? '');
      } catch (e) {
        log("Cannot get logged user", error: e);
      }
    });
    super.initState();
  }

  void _addDataSample() {}

  void _search(String searchString) {
    if (searchString.isEmpty) {
      setState(() {
        _selectedDataSamples = _allDataSamples;
      });
    } else {
      Timer(const Duration(seconds: 1), () {
        if (_latestSearchString == searchString) {
          setState(() {
            _selectedDataSamples = _allDataSamples.where((element) =>
                element.content.entries.any((c) => c.value.stringValue
                    ?.contains(searchString) ?? false)).toList();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the PatientDetails object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (value) => _search(value),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _selectedDataSamples.isNotEmpty
                  ? ListView.builder(
                      itemCount: _selectedDataSamples.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_selectedDataSamples[index].id),
                        color: Colors.indigoAccent,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          subtitle:
                              Text("${
                                  _selectedDataSamples[index].labels.firstWhere((element) => element.type == 'LOINC', orElse: () => CodingReference(code: 'Unknown')).code ?? 'Unknown:'
                              }: ${_selectedDataSamples[index].content.entries.map((c) => c.value.stringValue ?? c.value.numberValue?.toString()).whereType<String>().join('\n')}"),
                          title: Text(
                              _selectedDataSamples[index].valueDate?.toShortDate() ?? '-',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDataSample,
        tooltip: 'Add note for patient',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
