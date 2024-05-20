import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:share/share.dart'; // Import share package
import 'package:flutter/services.dart'; // Import services.dart for Clipboard
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast package

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

  @override
  void initState() {
    super.initState();
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
        child: ListView.builder(
          itemCount: generatedFiles.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(
                generatedFiles[index].fileName,
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(generatedFiles[index].filePath),
              onTap: () {
                openFile(generatedFiles[index].filePath);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    color: Colors.purpleAccent, // Apply blue color to the icon
                    onPressed: () {
                      shareFile(generatedFiles[index]);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy),
                    color: Colors.purpleAccent, // Apply blue color to the icon
                    onPressed: () {
                      copyFile(generatedFiles[index]);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors
                        .red.shade900, // Apply red color to the delete icon
                    onPressed: () {
                      deleteFile(generatedFiles[index]);
                    },
                  ),
                ],
              ),
            );
          },
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

  Future<void> copyFile(GeneratedFile file) async {
    try {
      Clipboard.setData(
          ClipboardData(text: file.filePath)); // Set text to clipboard
      Fluttertoast.showToast(
        msg: 'File path copied to clipboard!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Error copying file: $e');
    }
  }
}
