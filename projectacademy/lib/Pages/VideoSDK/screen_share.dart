import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

// ignore: must_be_immutable
class ScreenShareView extends StatefulWidget {
  final Participant participant;
  final double iconSize;
  final Color backcolor;
  final Color iconcolor;

  ScreenShareView(
      {super.key,
      required this.iconSize,
      required this.participant,
      required this.backcolor,
      required this.iconcolor}) {
    //intialize the shareStream
    participant.streams.forEach((key, value) {
      if (value.kind == "share") {
        shareStream = value;
      }
    });
  }
  Stream? shareStream;

  @override
  State<ScreenShareView> createState() => _ScreenShareViewState();
}

class _ScreenShareViewState extends State<ScreenShareView> {
  @override
  Widget build(BuildContext context) {
    return widget.shareStream != null
        ? Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: RTCVideoView(
              widget.shareStream?.renderer as RTCVideoRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          )
        : Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.backcolor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Image.asset(
                "assets/screen.png",
                cacheHeight: 5000,
                height: widget.iconSize,
                color: widget.iconcolor,
              ),
            ),
          );
  }
}
