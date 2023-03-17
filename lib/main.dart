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
      scrollBehavior: AppScrollBehavior(),
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

class _MyHomePageState extends State<MyHomePage> {
  List<PlatformFile>? _files;

  void _setImages(List<PlatformFile>? files) {
    setState(() {
      _files = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filesNull = _files == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Viewer"),
        actions: [
          filesNull
              ? Container()
              : Center(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _setImages(null),
                  ),
                )
        ],
      ),
      body: Center(
        child: Container(
          child: filesNull
              ? ImagePicker(
                  setImages: _setImages,
                )
              : Gallery(files: _files!, setImages: _setImages),
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
          print("Image Selection:");
          print(selection);
          if (selection == null) {
            return;
          }
          final files = selection.files;
          setImages(files);
        });
  }
}
