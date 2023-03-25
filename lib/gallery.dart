import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  const Gallery(
      {Key? key,
      required this.files,
      required this.setImages,
      required this.setImageNum,
      required this.imageNum})
      : super(key: key);
  final List<PlatformFile> files;
  final void Function(List<PlatformFile> files) setImages;
  final int imageNum;
  final void Function(int newNum) setImageNum;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  int _currentIndex = 0;
  //double _dragStart = 0;
  double _prevDrag = 0;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final String text = _controller.text.toLowerCase();
      _controller.value = _controller.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final files = widget.files;
    return Listener(
      /* onPointerPanZoomStart: (event) {
        setState(() {
          _dragStart = event.position.dx;
        });
        print("Start: ${event.position.dx}");
      }, */
      onPointerPanZoomEnd: (event) {
        //For some reason, moving left is positive.
        if (_prevDrag > 0) {
          _currentIndex = (_currentIndex - 1) % files.length;
        } else {
          _currentIndex = (_currentIndex + 1) % files.length;
        }
        widget.setImageNum(_currentIndex);
      },
      onPointerPanZoomUpdate: (event) {
        //final currDrag = event.pan.dx;
        setState(() {
          /* if (_prevDrag > 0) {
            _currentIndex = (_currentIndex - 1) % files.length;
          } else {
            _currentIndex = (_currentIndex + 1) % files.length;
          }*/
          _prevDrag = event.pan.dx;
        });
      },
      child: Container(
        //Scroll doesn't affect container unless
        //I do this
        color: Colors.transparent,
        child: Column(
          children: [
            Expanded(
              child: Image.file(
                File(files[_currentIndex].path!),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text("${_currentIndex + 1} / ${widget.files.length}"),
/*             TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
// for version 2 and greater youcan also use this
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration()) */
          ],
        ),
      ),
    );
  }
}
