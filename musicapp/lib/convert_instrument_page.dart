// ignore_for_file: avoid_print, prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'api_endpoints.dart';

class ConvertInstrumentPage extends StatefulWidget {
  const ConvertInstrumentPage({super.key});

  @override
  _ConvertInstrumentPageState createState() => _ConvertInstrumentPageState();
}

class _ConvertInstrumentPageState extends State<ConvertInstrumentPage> {
  TextEditingController inputController = TextEditingController();
  String convertedInstrument = 'Piano'; // Set default instrument to Piano
  List<String> instruments = [
    'Accordion', 'AcousticBass', 'AcousticGuitar', 'Agogo', 'Alto',
    'AltoSaxophone', 'Bagpipes', 'Banjo', 'Baritone', 'BaritoneSaxophone',
    'Bass', 'BassClarinet', 'BassDrum', 'BassTrombone', 'Bassoon', 'BongoDrums',
    'BrassInstrument', 'Castanets', 'Celesta', 'Choir',
    'ChurchBells', 'Clarinet', 'Clavichord', 'Conductor', 'CongaDrum',
    'Contrabass', 'Contrabassoon', 'Cowbell', 'CrashCymbals', 'Cymbals',
    'Dulcimer', 'ElectricBass', 'ElectricGuitar', 'ElectricOrgan',
    'ElectricPiano', 'EnglishHorn', 'FingerCymbals', 'Flute', 'FretlessBass',
    'Glockenspiel', 'Gong', 'Guitar', 'Handbells', 'Harmonica', 'Harp',
    'Harpsichord', 'HiHatCymbal', 'Horn', 'Kalimba', 'KeyboardInstrument',
    'Koto', 'Lute', 'Mandolin', 'Maracas', 'Marimba', 'MezzoSoprano', 'Oboe',
    'Ocarina', 'Organ', 'PanFlute',
    'Percussion', 'Piano', 'Piccolo', 'PipeOrgan', 'PitchedPercussion',
    'Ratchet', 'Recorder', 'ReedOrgan', 'RideCymbals', 'Sampler',
    'SandpaperBlocks', 'Saxophone', 'Shakuhachi', 'Shamisen', 'Shehnai',
    'Siren', 'Sitar', 'SizzleCymbal', 'SleighBells', 'SnareDrum', 'Soprano',
    'SopranoSaxophone', 'SplashCymbals', 'SteelDrum', 'StringInstrument',
    'SuspendedCymbal', 'Taiko', 'TamTam', 'Tambourine', 'TempleBlock',
    'Tenor', 'TenorDrum', 'TenorSaxophone', 'Timbales', 'Timpani', 'TomTom',
    'Triangle', 'Trombone', 'Trumpet', 'Tuba', 'TubularBells', 'Ukulele',
    'UnpitchedPercussion', 'Vibraphone', 'Vibraslap', 'Viola', 'Violin',
    'Violoncello', 'Vocalist', 'Whip', 'Whistle', 'WindMachine', 'Woodblock',
    'WoodwindInstrument', 'Xylophone'
    // Add more instrument names as needed
  ];

  File? file; // Declare file variable
  String errorMessage = '';
  bool isLoading = false;

  Future<void> convertInstrument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['midi'],
      );

      if (result != null) {
        file = File(result.files.single.path!);
        String instrument = inputController.text.isEmpty
            ? convertedInstrument
            : inputController.text;
        setState(() {
          convertedInstrument = instrument;
        });
      }
    } on SocketException {
      // No internet connection
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load available models. Please check your network connection.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 6),
        ),
      );
    } catch (e) {
      print('Error picking file: $e');
      setState(() {
        errorMessage = 'An error occurred while picking the file';
      });
    }
  }

  Future<void> sendDataToApi() async {
    final storage = FlutterSecureStorage();
    String? storedToken = await storage.read(key: 'jwtToken');
    if (file == null) {
      setState(() {
        errorMessage = 'Please choose a MIDI file';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var url = Uri.parse(CONVERT_INSTRUMENT_ENDPOINT);
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $storedToken';
      request.files.add(await http.MultipartFile.fromPath('file', file!.path));
      request.fields['instrument'] = convertedInstrument;

      var response = await request.send();

      if (response.statusCode == 200) {
        print('File uploaded successfully');
        final downloadsDirectory = await getDownloadsDirectory();
        if (downloadsDirectory != null) {
          const folderName = 'MusicGen';
          final folderPath = '${downloadsDirectory.path}/$folderName';

          String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
          String fileName = '$convertedInstrument-$currentTime.midi';

          final folder = Directory(folderPath);
          if (!folder.existsSync()) {
            folder.createSync(recursive: true);
          }

          final filePath = '$folderPath/$fileName';
          final newFile = File(filePath);
          await response.stream.pipe(newFile.openWrite());

          print('File saved to: $filePath');

          await OpenFile.open(filePath);
        } else {
          print('Downloads directory not found');
        }
      } else {
        print('Error uploading file: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending data to API: $e');
      setState(() {
        errorMessage = 'An error occurred while sending data to the API';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue
            .shade900, // Set the background color to a darker shade of blue
        title: const Text('Convert Instrument',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            )),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: convertInstrument,
              icon:
                  const Icon(Icons.file_upload), // Icon for file picker button
              label: const Text('Select MIDI File and Convert'),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.purple),
                foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white), // Text color
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Selected Instrument: $convertedInstrument',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16.0),
            MultiSelectDropDown<int>(
              onOptionSelected: (List<ValueItem> selectedOptions) {
                setState(() {
                  convertedInstrument = selectedOptions.isNotEmpty
                      ? selectedOptions[0].label
                      : '';
                });
              },
              options: instruments
                  .map((value) => ValueItem(
                      label: value, value: instruments.indexOf(value) + 1))
                  .toList(),
              selectionType: SelectionType.single,
              chipConfig: const ChipConfig(wrapType: WrapType.wrap),
              dropdownHeight: 300,
              optionTextStyle: const TextStyle(fontSize: 16),
              selectedOptionIcon: const Icon(Icons.check_circle),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                sendDataToApi();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.purple),
                foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white), // Text color
              ),
              child: const Text('Convert'),
            ),
            const SizedBox(height: 16.0),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
