// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'api_endpoints.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

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
  TextEditingController durationController = TextEditingController(text: '30');
  double temperatureValue = 0.5;
  int tempoValue = 120;
  String selectedModel = '';
  String selectedInstrument = 'Piano';
  List<String> models = [];
  final List<String> instruments = [
    'Accordion',
    'AcousticBass',
    'AcousticGuitar',
    'Agogo',
    'Alto',
    'AltoSaxophone',
    'Bagpipes',
    'Banjo',
    'Baritone',
    'BaritoneSaxophone',
    'Bass',
    'BassClarinet',
    'BassDrum',
    'BassTrombone',
    'Bassoon',
    'BongoDrums',
    'BrassInstrument',
    'Castanets',
    'Celesta',
    'Choir',
    'ChurchBells',
    'Clarinet',
    'Clavichord',
    'Conductor',
    'CongaDrum',
    'Contrabass',
    'Contrabassoon',
    'Cowbell',
    'CrashCymbals',
    'Cymbals',
    'Dulcimer',
    'ElectricBass',
    'ElectricGuitar',
    'ElectricOrgan',
    'ElectricPiano',
    'EnglishHorn',
    'FingerCymbals',
    'Flute',
    'FretlessBass',
    'Glockenspiel',
    'Gong',
    'Guitar',
    'Handbells',
    'Harmonica',
    'Harp',
    'Harpsichord',
    'HiHatCymbal',
    'Horn',
    'Kalimba',
    'KeyboardInstrument',
    'Koto',
    'Lute',
    'Mandolin',
    'Maracas',
    'Marimba',
    'MezzoSoprano',
    'Oboe',
    'Ocarina',
    'Organ',
    'PanFlute',
    'Percussion',
    'Piano',
    'Piccolo',
    'PipeOrgan',
    'PitchedPercussion',
    'Ratchet',
    'Recorder',
    'ReedOrgan',
    'RideCymbals',
    'Sampler',
    'SandpaperBlocks',
    'Saxophone',
    'Shakuhachi',
    'Shamisen',
    'Shehnai',
    'Siren',
    'Sitar',
    'SizzleCymbal',
    'SleighBells',
    'SnareDrum',
    'Soprano',
    'SopranoSaxophone',
    'SplashCymbals',
    'SteelDrum',
    'StringInstrument',
    'SuspendedCymbal',
    'Taiko',
    'TamTam',
    'Tambourine',
    'TempleBlock',
    'Tenor',
    'TenorDrum',
    'TenorSaxophone',
    'Timbales',
    'Timpani',
    'TomTom',
    'Triangle',
    'Trombone',
    'Trumpet',
    'Tuba',
    'TubularBells',
    'Ukulele',
    'UnpitchedPercussion',
    'Vibraphone',
    'Vibraslap',
    'Viola',
    'Violin',
    'Violoncello',
    'Vocalist',
    'Whip',
    'Whistle',
    'WindMachine',
    'Woodblock',
    'WoodwindInstrument',
    'Xylophone'
  ];
  bool isLoading = true;
  String errorMessage = '';
  late AudioPlayer player = AudioPlayer();

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
    final storage = FlutterSecureStorage();
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
          "instrument_name": selectedInstrument,
        }),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $storedToken',
        },
      );

      if (response.statusCode == 200) {
        final downloadsDirectory = await getDownloadsDirectory();
        if (downloadsDirectory != null) {
          const folderName = 'MusicGen';
          final folderPath = '${downloadsDirectory.path}/$folderName';

          String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
          String fileName = '$modelName-$selectedInstrument-$currentTime.midi';
          final folder = Directory(folderPath);
          if (!folder.existsSync()) {
            folder.createSync(recursive: true);
          }

          final filePath = '$folderPath/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          print('File saved to: $filePath');

          final audioSource = BytesSource(response.bodyBytes);
          await player.play(audioSource);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File saved to Generated Files'),
              duration: Duration(seconds: 2),
            ),
          );

          // await OpenFile.open(filePath);
        } else {
          print('Downloads directory not found');
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to generate music. Please check your network connection. Invalid response';
        });
      }
    } on SocketException {
      print('No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 6),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage =
            'Failed to generate music. Please check your network connection.';
      });
      print('Error: $e');
    } finally {
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
    player = AudioPlayer();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appTheme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: const Text(
            'Generate Music',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
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
                                optionTextStyle: const TextStyle(fontSize: 16),
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
                                optionTextStyle: const TextStyle(fontSize: 16),
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
                                  labelText: 'Duration (seconds) default:30',
                                  hintText: 'Enter duration in seconds',
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                              ListTile(
                                title: const Text(
                                  'Temperature (Randomness)',
                                  style: TextStyle(
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                      PlayerWidget(player: player),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  const PlayerWidget({required this.player, super.key});
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';
  AudioPlayer get player => widget.player;
  @override
  void initState() {
    super.initState();
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: Colors.white,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: Colors.white,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: Colors.white,
            ),
          ],
        ),
        Slider(
          onChanged: (value) {
            final duration = _duration;
            if (duration == null) {
              return;
            }
            final position = value * duration.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
                  _duration != null &&
                  _position!.inMilliseconds > 0 &&
                  _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
        ),
        Text(
          _position != null
              ? '$_positionText / $_durationText'
              : _duration != null
                  ? _durationText
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });
    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
