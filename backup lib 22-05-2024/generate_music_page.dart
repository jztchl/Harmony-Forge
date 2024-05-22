import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'api_endpoints.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  fontFamily: 'Quicksand',
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.purple.shade900),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      ),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  ),
  sliderTheme: const SliderThemeData(
    thumbColor: Colors.white,
    activeTrackColor: Color.fromARGB(255, 94, 14, 6),
    inactiveTrackColor: Colors.grey,
    trackHeight: 4.0,
  ),
);

class GenerateMusicPage extends StatefulWidget {
  const GenerateMusicPage({super.key});

  @override
  _GenerateMusicPageState createState() => _GenerateMusicPageState();
}

class _GenerateMusicPageState extends State<GenerateMusicPage> {
  TextEditingController durationController = TextEditingController();
  double temperatureValue = 0.5;
  int tempoValue = 120; // Default tempo value
  String selectedModel = '';
  String selectedInstrument = 'Piano'; // Default instrument
  List<String> models = [];
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
  bool isLoading = true;
  String errorMessage = '';

  Future<void> getAvailableModels() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      var url = Uri.parse(GET_AVAILABLE_MODEL_FOLDERS_ENDPOINT);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          models = jsonResponse['model_folders'].cast<String>();
          selectedModel = models.isNotEmpty ? models[0] : '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load available models. Please check your network connection.';
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
        SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 6),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load available models. Please check your network connection.';
      });
      print('Error: $e');
    }
  }

  Future<void> generateMusic() async {
    String modelName = selectedModel;
    int durationSeconds = int.tryParse(durationController.text) ?? 0;
    double temperature = temperatureValue;
    int tempo = tempoValue;
    final storage = const FlutterSecureStorage();
    String? storedToken = await storage.read(key: 'jwtToken');

    if (durationSeconds <= 0) {
      setState(() {
        errorMessage = 'Please enter a valid duration.';
      });
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    var url = Uri.parse(GENERATE_MUSIC_ENDPOINT);
    var client = http.Client();

    try {
      var response = await client.post(
        url,
        body: json.encode({
          "model_folder": modelName,
          "duration_seconds": durationSeconds,
          "temperature": temperature,
          "tempo": tempo,
          "instrument_name": selectedInstrument, // Use selectedInstrument
        }),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $storedToken', // Include the token as Bearer
        },
      );

      if (response.statusCode == 200) {
        // Handle successful response

        final downloadsDirectory = await getDownloadsDirectory();
        if (downloadsDirectory != null) {
          const folderName = 'MusicGen';
          final folderPath = '${downloadsDirectory.path}/$folderName';

          String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
          String fileName = '$modelName-$selectedInstrument-$currentTime.midi';
          // Create the folder if it doesn't exist
          final folder = Directory(folderPath);
          if (!folder.existsSync()) {
            folder.createSync(recursive: true);
          }

          // Construct the full file path
          final filePath = '$folderPath/$fileName';

          // Save the file to the folder
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          print('File saved to: $filePath');

          // Open the file
          await OpenFile.open(filePath);
        } else {
          print('Downloads directory not found');
        }
      } else {
        // Handle error
        setState(() {
          errorMessage =
              'Failed to generate music. Please check your network connection. invalid response';
        });
      }
    } on SocketException {
      // No internet connection
      print('No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 6),
        ),
      );
    } catch (e) {
      // Handle exception
      setState(() {
        errorMessage =
            'Failed to generate music. Please check your network connection.';
      });
      print('Error: $e');
    } finally {
      // Close the client
      client.close();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAvailableModels();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: appTheme,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue
                .shade900, // Set the background color to a darker shade of blue
            title: const Text('Generate Music',
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
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (errorMessage.isNotEmpty) Text(errorMessage),
                                Text(
                                  'Selected Model: $selectedModel',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                MultiSelectDropDown<int>(
                                  onOptionSelected:
                                      (List<ValueItem> selectedOptions) {
                                    setState(() {
                                      selectedModel = selectedOptions.isNotEmpty
                                          ? selectedOptions[0].label
                                          : '';
                                    });
                                  },
                                  options: models
                                      .map((value) => ValueItem(
                                          label: value,
                                          value: models.indexOf(value) + 1))
                                      .toList(),
                                  selectionType: SelectionType.single,
                                  chipConfig:
                                      const ChipConfig(wrapType: WrapType.wrap),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                      const TextStyle(fontSize: 16),
                                  selectedOptionIcon:
                                      const Icon(Icons.check_circle),
                                  selectedOptionBackgroundColor:
                                      const Color.fromARGB(116, 105, 27, 154),
                                  hintColor: Colors.white,
                                  fieldBackgroundColor:
                                      const Color.fromARGB(116, 105, 27, 154),
                                  selectedOptionTextColor: Colors.white,
                                ),
                                Text(
                                  'Selected Instrument: $selectedInstrument',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                MultiSelectDropDown<String>(
                                  onOptionSelected:
                                      (List<ValueItem> selectedOptions) {
                                    setState(() {
                                      selectedInstrument =
                                          selectedOptions.isNotEmpty
                                              ? selectedOptions[0].label
                                              : '';
                                    });
                                  },
                                  options: instruments
                                      .map((value) =>
                                          ValueItem(label: value, value: value))
                                      .toList(),
                                  selectionType: SelectionType.single,
                                  chipConfig:
                                      const ChipConfig(wrapType: WrapType.wrap),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                      const TextStyle(fontSize: 16),
                                  selectedOptionIcon:
                                      const Icon(Icons.check_circle),
                                  selectedOptionBackgroundColor:
                                      const Color.fromARGB(116, 105, 27, 154),
                                  hintColor: Colors.white,
                                  fieldBackgroundColor:
                                      const Color.fromARGB(116, 105, 27, 154),
                                  selectedOptionTextColor: Colors.white,
                                ),
                                TextFormField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                      labelText: 'Duration (seconds)',
                                      hintText: 'Enter duration in seconds',
                                      labelStyle: TextStyle(
                                        color: Color.fromARGB(255, 255, 255,
                                            255), // Change this to your desired color
                                      ),
                                      hintStyle:
                                          TextStyle(color: Colors.white)),
                                ),
                                ListTile(
                                  title: const Text(
                                    'Temperature (Randomness)',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Set the text color to white
                                    ),
                                  ),
                                  subtitle: Slider(
                                    value: temperatureValue,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 100,
                                    onChanged: (double value) {
                                      setState(() {
                                        temperatureValue = value;
                                      });
                                    },
                                    label: 'Temperature: $temperatureValue',
                                  ),
                                ),
                                ListTile(
                                  title: const Text(
                                    'Tempo (BPM)',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Set the text color to white
                                    ),
                                  ),
                                  subtitle: Slider(
                                    value: tempoValue.toDouble(),
                                    min: 40,
                                    max: 200,
                                    divisions: 100,
                                    onChanged: (double value) {
                                      setState(() {
                                        tempoValue = value.toInt();
                                      });
                                    },
                                    label: 'Tempo: $tempoValue BPM',
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: generateMusic,
                                  child: const Text('Generate Music'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ));
  }
}
