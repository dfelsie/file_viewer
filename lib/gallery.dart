import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Gallery extends StatefulWidget {
  Gallery(
      {Key? key,
      required this.files,
      required this.setImages,
      required this.setImageNum,
      required this.imageNum})
      : super(key: key);
  final List<PlatformFile> files;
  final void Function(List<PlatformFile> files) setImages;
  int imageNum;
  final void Function(int newNum) setImageNum;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
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
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            widget.imageNum = (widget.imageNum - 1) % files.length;
            widget.setImageNum(widget.imageNum);

            // Handle left arrow key event
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // Handle right arrow key event
            widget.imageNum = (widget.imageNum + 1) % files.length;
            widget.setImageNum(widget.imageNum);
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (_controller.value.text == '') {
              return;
            }
            int newIndex = (int.parse(_controller.value.text.toString()));
            if (newIndex < 1) {
              newIndex = 1;
            } else if (newIndex > (widget.files.length)) {
              newIndex = widget.files.length;
            }
            //Only works if i edit widget.imageNum
            widget.imageNum = newIndex - 1;
            widget.setImageNum(widget.imageNum);
          }
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerPanZoomEnd: (event) {
                //For some reason, moving left is positive.
                if (_prevDrag > 0) {
                  widget.imageNum = (widget.imageNum - 1) % files.length;
                } else {
                  widget.imageNum = (widget.imageNum + 1) % files.length;
                }
                widget.setImageNum(widget.imageNum);
              },
              onPointerPanZoomUpdate: (event) {
                //final currDrag = event.pan.dx;
                setState(() {
                  _prevDrag = event.pan.dx;
                });
              },
              onPointerDown: (event) {
                widget.imageNum = (widget.imageNum + 1) % files.length;
                widget.setImageNum(widget.imageNum);
              },
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    width: 50,
                    child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.grey.withOpacity(0.5),
                          BlendMode.srcATop,
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.red,
                        )),
                  ),
                  Positioned(
                    right: 0,
                    width: 50,
                    child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.grey.withOpacity(0.5),
                          BlendMode.srcATop,
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.red,
                        )),
                  ),
                  Container(
                    //Need this to have listen the whole screen's width.
                    color: Colors.transparent,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.file(
                            File(files[widget.imageNum].path!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text("${widget.imageNum + 1} / ${widget.files.length}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 100,
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                      hintText:
                          "${(widget.imageNum + 1).toString()}/${widget.files.length}"),
                ),
              ),
              IconButton(
                  onPressed: () {
                    int newIndex =
                        (int.parse(_controller.value.text.toString()));
                    if (newIndex < 1) {
                      newIndex = 1;
                    } else if (newIndex > (widget.files.length)) {
                      newIndex = widget.files.length;
                    }
                    //Only works if i edit widget.imageNum
                    widget.imageNum = newIndex - 1;
                    widget.setImageNum(widget.imageNum);
                  },
                  icon: Icon(Icons.arrow_forward))
            ],
          )
        ],
      ),
    );
  }
}
