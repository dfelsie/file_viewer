import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key, required this.files, required this.setImages})
      : super(key: key);
  final List<PlatformFile> files;
  final void Function(List<PlatformFile> files) setImages;

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  int _currentIndex = 0;
  double _dragStart = 0;
  double _dragEnd = 0;

  void _onImageSwiped(int index, CarouselPageChangedReason reason) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDragStart(DragStartDetails details) {
    print("Draggin!");
    _dragStart = details.localPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragEnd = details.localPosition.dx;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragEnd - _dragStart > 0) {
      setState(() {
        _currentIndex = (_currentIndex - 1) % widget.files.length.abs();
      });
    } else if (_dragEnd - _dragStart < 0) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.files.length.abs();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Column(
        children: [
          CarouselSlider(
            items: widget.files.map((file) {
              return Image.file(
                File(file.path!),
                fit: BoxFit.cover,
              );
            }).toList(),
            options: CarouselOptions(
              height: 400.0,
              viewportFraction: 1.0,
              onPageChanged: _onImageSwiped,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text("${_currentIndex + 1} / ${widget.files.length}")
        ],
      ),
    );
  }
}
