import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:icure_medical_device_dart_sdk/api.dart';

import 'utils/date_utils.dart';

class PatientSearch extends StatefulWidget {
  final Future<MedTechApi> medTechApi;

  const PatientSearch({Key? key, required this.title, required this.medTechApi})
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
  State<PatientSearch> createState() => _PatientSearchState();
}

class _PatientSearchState extends State<PatientSearch> {
  List<Patient> _foundPatients = [];
  User? _loggedUser;
  String? _latestSearchString;

  Future<PatientApi> patientApi() =>
      widget.medTechApi.then((mapi) => PatientApiImpl(mapi));

  Future<UserApi> userApi() =>
      widget.medTechApi.then((mapi) => UserApiImpl(mapi));

  @override
  void initState() {
    userApi().then((api) {
      try {
        log("Loading user");
        api.getLoggedUser().then((me) {
          log("User is ${me}");
          setState(() {
            _loggedUser = me;
          });
        });
      } catch (e) {
        log("Cannot get logged user", error: e);
      }
    });
    super.initState();
  }

  void _addPatient() {}

  void _search(String searchString) {
    _latestSearchString = searchString;
    if (searchString.isEmpty) {
      setState(() {
        _foundPatients = [];
      });
    } else {
      Timer(const Duration(seconds: 1), () {
        if (_latestSearchString == searchString) {
          patientApi().then((api) async {
            final res = (await api.filterPatients(
                        PatientByHcPartyNameContainsFuzzyFilter(
                            healthcarePartyId: _loggedUser?.healthcarePartyId,
                            searchString: searchString)))
                    ?.rows ??
                [];
            setState(() {
              _foundPatients = res;
            });

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
        // Here we take the value from the PatientSearch object that was created by
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
              child: _foundPatients.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundPatients.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundPatients[index].id),
                        color: Colors.indigoAccent,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          subtitle:
                              Text('${_foundPatients[index].dateOfBirth?.toShortDate() ?? '-'}'),
                          title: Text(
                              "${_foundPatients[index].firstName ?? ''} ${_foundPatients[index].lastName ?? ''}",
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
        onPressed: _addPatient,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
