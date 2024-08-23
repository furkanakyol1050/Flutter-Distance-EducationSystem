import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

// ignore: must_be_immutable
class ParticipantTile extends StatefulWidget {
  final Participant participant;
  final double iconSize;
  final Color backcolor;
  final Color iconcolor;
  ParticipantTile(
      {super.key,
      required this.participant,
      required this.iconSize,
      required this.iconcolor,
      required this.backcolor}) {
    //intialize the videoStream
    participant.streams.forEach((key, value) {
      if (value.kind == "video") {
        videoStream = value;
      }
    });
  }

  Stream? videoStream;

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  @override
  Widget build(BuildContext context) {
    return widget.videoStream != null
        ? Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: RTCVideoView(
              widget.videoStream?.renderer as RTCVideoRenderer,
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
                "assets/user.png",
                cacheHeight: 5000,
                height: widget.iconSize,
                color: widget.iconcolor,
              ),
            ),
          );
  }
}
