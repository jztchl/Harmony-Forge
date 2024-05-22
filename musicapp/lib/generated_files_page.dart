import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:share/share.dart'; // Import share package
import 'package:flutter/services.dart'; // Import services.dart for Clipboard
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast package
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class GeneratedFilesPage extends StatefulWidget {
  const GeneratedFilesPage({super.key});

  @override
  _GeneratedFilesPageState createState() => _GeneratedFilesPageState();
}

class GeneratedFile {
  String fileName;
  String filePath;

  GeneratedFile({
    required this.fileName,
    required this.filePath,
  });
}

class _GeneratedFilesPageState extends State<GeneratedFilesPage> {
  List<GeneratedFile> generatedFiles = [];
  late AudioPlayer player = AudioPlayer();
  GeneratedFile? currentlyPlayingFile;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    loadGeneratedFiles();
  }

  Future<void> loadGeneratedFiles() async {
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory != null) {
        Directory musicGenDirectory =
            Directory('${downloadsDirectory.path}/MusicGen');
        if (musicGenDirectory.existsSync()) {
          List<FileSystemEntity> files = musicGenDirectory.listSync();
          for (var file in files) {
            if (file is File) {
              generatedFiles.add(
                GeneratedFile(
                  fileName: file.path.split('/').last,
                  filePath: file.path,
                ),
              );
            }
          }
          setState(() {});
        }
      }
    } catch (e) {
      print('Error loading generated files: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue
            .shade900, // Set the background color to a darker shade of blue
        title: const Text('Generated Files',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: generatedFiles.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      generatedFiles[index].fileName,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      openFile(generatedFiles[index].filePath);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          color: Color.fromARGB(
                              255, 187, 255, 0), // Apply blue color to the icon
                          onPressed: () {
                            shareFile(generatedFiles[index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red
                              .shade900, // Apply red color to the delete icon
                          onPressed: () {
                            deleteFile(generatedFiles[index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          color: const Color.fromARGB(255, 255, 255, 255),
                          onPressed: () {
                            playFile(generatedFiles[index]);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            PlayerWidget(player: player),
          ],
        ),
      ),
    );
  }

  Future<void> openFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<void> deleteFile(GeneratedFile file) async {
    try {
      File fileToDelete = File(file.filePath);
      if (fileToDelete.existsSync()) {
        await fileToDelete.delete();
        setState(() {
          generatedFiles.remove(file);
        });
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Future<void> shareFile(GeneratedFile file) async {
    try {
      await Share.shareFiles([file.filePath]);
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  Future<void> playFile(GeneratedFile file) async {
    try {
      await player.setSourceDeviceFile(file.filePath);
      await player.resume();
      setState(() {
        currentlyPlayingFile = file;
      });
    } catch (e) {
      print('Error playing file: $e');
    }
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
    final color = Theme.of(context).primaryColor;
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
