import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_viewer/gallery.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Future<FilePickerResult?> pickImages() async {
  final image = await FilePicker.platform
      .pickFiles(type: FileType.image, allowMultiple: true);

  return image;
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown
      };
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //scrollBehavior: AppScrollBehavior(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum AddFileMode { append, replace }

class _MyHomePageState extends State<MyHomePage> {
  List<PlatformFile>? _files;
  int? _imageNum;
/*
  void _selectImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
      withData: true,
      withReadStream: true,
      //onDirectoryPickCancel: () => true,
    );

    if (result != null) {
      if (result.files.isNotEmpty) {
        // Files were selected
        setState(() {
          _files = result.paths.map((path) => File(path!)).toList();
        });
      } else {
        // Directory was selected
        setState(() {
          _files = result.paths
              .map((path) => Directory(path!).listSync())
              .expand((i) => i)
              .where((f) =>
                  f.path.endsWith('.jpg') ||
                  f.path.endsWith('.jpeg') ||
                  f.path.endsWith('.png'))
              .map((f) => File(f.path))
              .toList();
        });
      }
    }
  }
 */
  void setImageNum(int newNum) {
    setState(() {
      _imageNum = newNum;
    });
  }

  void _setImages(List<PlatformFile>? files,
      {AddFileMode fileMode = AddFileMode.replace}) {
    if (_files == null || fileMode == AddFileMode.replace) {
      setState(() {
        _files = files;
        _imageNum = 0;
      });
    } else {
      //_imageNum = ((_files?.length ?? -1) + 1);
      //_files?.addAll(files ?? []);

      setState(() {
        _imageNum = ((_files?.length ?? 0));
        _files?.addAll(files ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filesNull = _files == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Image Viewer"),
        actions: [
          filesNull
              ? Container()
              : Center(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _setImages(null),
                      ),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final selection = await pickImages();
                            if (selection == null) {
                              return;
                            }
                            final files = selection.files;
                            _setImages(files, fileMode: AddFileMode.append);
                          })
                    ],
                  ),
                )
        ],
      ),
      body: Center(
        child: SizedBox(
          child: filesNull
              ? ImagePicker(
                  setImages: _setImages,
                )
              : Gallery(
                  files: _files!,
                  setImages: _setImages,
                  imageNum: _imageNum ?? 0,
                  setImageNum: setImageNum),
        ),
      ),
    );
  }
}

class ImagePicker extends StatelessWidget {
  const ImagePicker({super.key, required this.setImages});
  final void Function(List<PlatformFile> files) setImages;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: const Text("Upload Images!"),
        onPressed: () async {
          final selection = await pickImages();
          if (selection == null) {
            return;
          }
          final files = selection.files;
          setImages(files);
        });
  }
}
