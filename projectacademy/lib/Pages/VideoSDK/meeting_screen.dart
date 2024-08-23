import 'dart:ui';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectacademy/Pages/VideoSDK/participant_grid_list.dart';
import 'package:projectacademy/Pages/VideoSDK/participant_list.dart';
import 'package:projectacademy/Pages/VideoSDK/participant_tile.dart';
import 'package:projectacademy/Pages/VideoSDK/screen_share.dart';
import 'package:projectacademy/myDesign.dart';
import 'package:videosdk/videosdk.dart';

final msgProvider = StateProvider((ref) => "");
final isRecorderProvider = StateProvider((ref) => 0);
final boxSizeProvider = StateProvider((ref) => 0);
final boxIconProvider = StateProvider<double>((ref) => 0);
final bottomContainerSizeProvider = StateProvider<double>(
  (ref) =>
      // ignore: deprecated_member_use
      MediaQueryData.fromView(WidgetsBinding.instance.window).size.height *
      0.04,
);
final bottomContainerVisProvider = StateProvider<double>((ref) => 0);

//! ALT SATIR TUŞ ICON DEĞİŞİM PROVİDERLERİ

final allMuteProvider = StateProvider((ref) => 0);
final allNoCamProvider = StateProvider((ref) => 0);

final screenChange1Provider = StateProvider((ref) => 0);

Participant? presenter;

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String token;
  final String uniId;
  final String facultyId;
  final String departmentId;
  final String personName;
  final String courseId;
  final int isCreater;
  final String insId;
  const MeetingScreen(this.meetingId, this.token,
      {super.key,
      required this.uniId,
      required this.facultyId,
      required this.departmentId,
      required this.personName,
      required this.isCreater,
      required this.courseId,
      required this.insId});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  bool isRecordingOn = false;
  String recordingState = "RECORDING_STOPPED";
  PubSubMessages? messages;
  late Room meeting;
  String? _presenterId;
  bool _joined = false;
  var micEnabled = false;
  var camEnabled = false;

  late String roomInsId;

  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  bool _showWidgets = false;

  bool check = true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
      check = true;
      meeting.participants.forEach((key, value) {
        check = true;
        meeting.participants.forEach((key, value) {
          value.streams.forEach((key2, Stream stream) {
            if (stream.kind == 'share') {
              presenter = value;
              check = false;
            }
          });
          if (check == true) {
            presenter = null;
          }
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // create room
    Room room = VideoSDK.createRoom(
        roomId: widget.meetingId,
        token: widget.token,
        displayName: widget.personName,
        micEnabled: micEnabled,
        camEnabled: camEnabled,
        defaultCameraIndex: kIsWeb
            ? 0
            : 1 // Index of MediaDevices will be used to set default camera
        );

    if (widget.isCreater == 1) {
      _updateCourse(room.id, room.localParticipant.id);
    }

    registerMeetingEvents(room);

    // Join room
    room.join();

    room.participants
        .putIfAbsent(room.localParticipant.id, () => room.localParticipant);
  }

  // ignore: no_leading_underscores_for_local_identifiers
  void registerMeetingEvents(Room _meeting) {
    // Called when joined in meeting
    _meeting.on(
      Events.roomJoined,
      () {
        setState(() {
          meeting = _meeting;
          _joined = true;
        });
      },
    );

    // Called when meeting is ended
    _meeting.on(Events.roomLeft, (String? errorMsg) {
      if (errorMsg != null) {
        showSnackBarWidget(context, "Hata");
      }
      Navigator.pop(context);
    });

    // Called when recording is started
    _meeting.on(Events.recordingStateChanged, (String status) {
      if (status == "RECORDING_STARTED") {
        showSnackBarWidget(
          context,
          "Kayıt başladı.",
        );
      } else if (status == "RECORDING_STOPPED") {
        showSnackBarWidget(
          context,
          "Kayıt durdu.",
        );
      }

      setState(() {
        recordingState = status;
      });
    });

    // Called when stream is enabled
    // ignore: no_leading_underscores_for_local_identifiers
    _meeting.localParticipant.on(Events.streamEnabled, (Stream _stream) {
      if (_stream.kind == 'video') {
        setState(() {
          videoStream = _stream;
        });
      } else if (_stream.kind == 'audio') {
        setState(() {
          audioStream = _stream;
        });
      } else if (_stream.kind == 'share') {
        setState(() {
          shareStream = _stream;
        });
      }
    });

    // Called when stream is disabled
    // ignore: no_leading_underscores_for_local_identifiers
    _meeting.localParticipant.on(Events.streamDisabled, (Stream _stream) {
      if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    // ignore: no_leading_underscores_for_local_identifiers
    _meeting.on(Events.presenterChanged, (_activePresenterId) {
      _presenterId = _activePresenterId;
    });

    _meeting.on(
        Events.error,
        (error) => {
              showSnackBarWidget(
                context,
                "Ekran paylaşılmadı.",
              )
            });
  }

  // onbackButton pressed leave the room
  // ignore: unused_element
  Future<bool> _onWillPop() async {
    meeting.leave();
    return true;
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showWidgets = true;
      });
    });
  }

  void _updateCourse(String roomId, String insId) {
    final courseRef = FirebaseFirestore.instance
        .collection('universities')
        .doc(widget.uniId)
        .collection('faculties')
        .doc(widget.facultyId)
        .collection('departments')
        .doc(widget.departmentId)
        .collection('courses')
        .doc(widget.courseId);

    courseRef.update({'roomId': roomId, 'roomInsId': insId});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _startTimer();

    return Scaffold(
      // ignore: deprecated_member_use
      body: (ui.window.display.size.height ==
                  MediaQuery.of(context).size.height) &&
              // ignore: deprecated_member_use
              (ui.window.display.size.width ==
                  MediaQuery.of(context).size.width)
          ? Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage("assets/1.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipRRect(
                // make sure we apply clip it properly
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 20,
                        top: 20,
                        right: 20,
                      ),
                      alignment: Alignment.center,
                      child: _showWidgets && _joined
                          ? Center(
                              child: Row(
                                children: [
                                  LeftPageWidget(widget.isCreater,
                                      size: size,
                                      room: meeting,
                                      presenterId: _presenterId,
                                      courseId: widget.courseId),
                                  RightPageWidget(
                                      size: size,
                                      room: meeting,
                                      insId: widget.insId,
                                      isCreater: widget.isCreater),
                                ],
                              ),
                            )
                          : const Center(
                              child: SpinKitPulse(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            )
          : size.height > 300
              ? Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage("assets/1.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipRRect(
                    // make sure we apply clip it properly
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.6),
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                size: 70,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                """Canlı derse devam edemiyorsunuz.\n"""
                                """Lütfen tarayıcınızı tam ekran moduna alınız.""",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
    );
  }
}

class LeftPageWidget extends ConsumerWidget {
  const LeftPageWidget(this.isCreater,
      {super.key,
      required this.size,
      required this.room,
      required this.presenterId,
      required this.courseId});

  final Size size;
  final Room room;
  final String? presenterId;
  final int isCreater;
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Flexible(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              width: size.width,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      room.leave();
                      room.pubSub.unsubscribe("CHAT", (p0) => null);
                    },
                    style: IconButton.styleFrom(
                      hoverColor: Colors.white24,
                      foregroundColor: Colors.white24,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 35,
                      top: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Algoritma ve Programlama 1",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          "Dr. Muhammed Furkan Akyol",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 40,
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 16,
                          top: 7,
                          bottom: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.5),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: ref.watch(isRecorderProvider) == 0
                                ? Colors.transparent
                                : const Color.fromRGBO(211, 118, 118, 1),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.fiber_manual_record_rounded,
                              color: room.recordingState != "RECORDING_STARTED"
                                  ? Colors.grey.shade800
                                  : const Color.fromRGBO(211, 118, 118, 1),
                              size: 15,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              room.recordingState == "RECORDING_STARTED"
                                  ? "Kaydediliyor"
                                  : "Kaydedilmiyor",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color:
                                    room.recordingState == "RECORDING_STARTED"
                                        ? const Color.fromRGBO(211, 118, 118, 1)
                                        : Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 150,
                        height: 40,
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.5),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: Colors.grey.shade800,
                            ),
                            const Spacer(),
                            Text(
                              "00:00:00",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
                height: ref.watch(bottomContainerSizeProvider) ==
                        size.height * 0.275
                    ? size.height * 0.5
                    : size.height * 0.7,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: presenter != null
                      ? Stack(
                          children: [
                            ref.watch(screenChange1Provider) == 0
                                ? ParticipantTile(
                                    participant: presenter!,
                                    iconSize: size.height * 0.30,
                                    backcolor: const Color.fromRGBO(
                                        255, 255, 255, 0.5),
                                    iconcolor: Colors.grey.shade800,
                                  )
                                : ScreenShareView(
                                    participant: presenter!,
                                    iconSize: size.height * 0.30,
                                    backcolor: const Color.fromRGBO(
                                        255, 255, 255, 0.5),
                                    iconcolor: Colors.grey.shade800,
                                  ),
                            UpScreenWidget(
                              isCam: presenter!.streams.values
                                  .any((value) => value.kind == 'video'),
                              isMic: presenter!.streams.values
                                  .any((value) => value.kind == 'audio'),
                              provider: screenChange1Provider,
                              no: "1",
                              name: presenter!.displayName,
                              index: 0,
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            ref.watch(screenChange1Provider) == 0
                                ? DefaultUserCardWidget(
                                    iconSize: size.height * 0.25,
                                    backcolor: const Color.fromRGBO(
                                        255, 255, 255, 0.5),
                                    iconcolor: Colors.grey.shade800,
                                  )
                                : DefaultScreenShareCardWidget(
                                    iconSize: size.height * 0.25,
                                    backcolor: const Color.fromRGBO(
                                        255, 255, 255, 0.5),
                                    iconcolor: Colors.grey.shade800,
                                  ),
                            UpScreenWidget(
                              isCam: false,
                              isMic: false,
                              provider: screenChange1Provider,
                              no: "1",
                              name: "Konuşmacı Yok",
                              index: 0,
                            ),
                          ],
                        ),
                )),
            const Spacer(flex: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 24),
                Expanded(
                  flex: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: room
                                    .localParticipant.streams.values
                                    .any((value) => value.kind == 'audio')
                                ? Colors.white
                                : const Color.fromRGBO(211, 118, 118, 1),
                            minimumSize: const Size(50, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(111),
                            ),
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          onPressed: () {
                            room.localParticipant.streams.values
                                    .any((value) => value.kind == 'audio')
                                ? room.muteMic()
                                : room.unmuteMic();
                          },
                          icon: Icon(
                            room.localParticipant.streams.values
                                    .any((value) => value.kind == 'audio')
                                ? Icons.mic
                                : Icons.mic_off,
                            color: room.localParticipant.streams.values
                                    .any((value) => value.kind == 'audio')
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(50, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(111),
                            ),
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          onPressed: () {
                            if (room.localParticipant.streams.values
                                .any((value) => value.kind == 'video')) {
                              room.disableCam();
                            } else {
                              room.enableCam();
                            }
                          },
                          icon: Icon(
                            room.localParticipant.streams.values
                                    .any((value) => value.kind == 'video')
                                ? Icons.videocam
                                : Icons.videocam_off,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: room
                                    .localParticipant.streams.values
                                    .any((value) => value.kind == 'share')
                                ? Colors.blue.shade600
                                : Colors.white,
                            minimumSize: const Size(50, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          onPressed: () {
                            if (room.localParticipant.streams.values
                                .any((value) => value.kind == 'share')) {
                              room.disableScreenShare();
                            } else {
                              room.enableScreenShare();
                            }
                          },
                          icon: Icon(
                            Icons.screen_share,
                            color: room.localParticipant.streams.values
                                    .any((value) => value.kind == 'share')
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        isCreater == 1
                            ? Expanded(
                                flex: 11,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    PopupMenuButton(
                                      offset: const Offset(0, -160),
                                      tooltip: "Ayarlar",
                                      color: Colors.white.withOpacity(1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      shadowColor: Colors.transparent,
                                      surfaceTintColor:
                                          Colors.white.withOpacity(1),
                                      onSelected: (value) {
                                        if (value == 0) {
                                          if (ref.watch(isRecorderProvider) ==
                                              0) {
                                            Map<String, dynamic> config = {
                                              "layout": {
                                                "type": "GRID",
                                                "priority": "SPEAKER",
                                                "gridSize": 4,
                                              },
                                              "theme": "DARK",
                                              "mode": "video-and-audio",
                                              "quality": "high",
                                              "orientation": "lanscape",
                                            };

                                            room.startRecording(
                                                config: config,
                                                awsDirPath: courseId);
                                          } else {
                                            room.stopRecording();
                                          }
                                          ref
                                              .read(isRecorderProvider.notifier)
                                              .state = ref.watch(
                                                      isRecorderProvider) ==
                                                  0
                                              ? 1
                                              : 0;
                                        } else if (value == 1) {
                                          if (ref.watch(allMuteProvider) == 0) {
                                            for (var participant
                                                in room.participants.values) {
                                              participant.muteMic();
                                            }
                                          } else {
                                            for (var participant
                                                in room.participants.values) {
                                              participant.unmuteMic();
                                            }
                                          }

                                          ref
                                              .read(allMuteProvider.notifier)
                                              .state = ref
                                                      .watch(allMuteProvider) ==
                                                  0
                                              ? 1
                                              : 0;
                                        } else {
                                          if (ref.watch(allNoCamProvider) ==
                                              0) {
                                            for (var participant
                                                in room.participants.values) {
                                              participant.disableCam();
                                            }
                                          } else {
                                            for (var participant
                                                in room.participants.values) {
                                              participant.enableCam();
                                            }
                                          }

                                          ref
                                              .read(allNoCamProvider.notifier)
                                              .state = ref.watch(
                                                      allNoCamProvider) ==
                                                  0
                                              ? 1
                                              : 0;
                                        }
                                      },
                                      itemBuilder: (BuildContext bc) {
                                        return [
                                          PopupMenuItem(
                                            value: 0,
                                            child: Text(
                                              ref.watch(isRecorderProvider) == 0
                                                  ? "Kaydı başlat"
                                                  : "Kaydı durdur",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 1,
                                            child: Text(
                                              ref.watch(allMuteProvider) == 0
                                                  ? "Herkesi sustur"
                                                  : "Mikrofona izin ver",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 2,
                                            child: Text(
                                              ref.watch(allNoCamProvider) == 0
                                                  ? "Kameraları kapat"
                                                  : "Kameraya izin ver",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ];
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                        child: const Icon(
                                          Icons.settings,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Spacer(flex: 1),
                        const Spacer(flex: 4),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(211, 118, 118, 1),
                            minimumSize: const Size(100, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            foregroundColor: Colors.white,
                            hoverColor: Colors.transparent,
                          ),
                          onPressed: () {
                            if (isCreater == 1) {
                              room.end();
                            } else {
                              room.leave();
                            }
                          },
                          icon: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 24),
              ],
            ),
            const Spacer(),
            AnimatedContainer(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              onEnd: () {
                if (ref.watch(bottomContainerSizeProvider) ==
                    size.height * 0.275) {
                  ref.read(bottomContainerVisProvider.notifier).state = 1;
                }
              },
              height: ref.watch(bottomContainerSizeProvider),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuart,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(bottomContainerSizeProvider.notifier).state =
                          ref.watch(bottomContainerSizeProvider) ==
                                  size.height * 0.275
                              ? size.height * 0.035
                              : size.height * 0.275;
                      if (ref.watch(bottomContainerVisProvider) == 1) {
                        ref.read(bottomContainerVisProvider.notifier).state = 0;
                      }
                    },
                    child: Container(
                      height: size.height * 0.035,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedRotation(
                        turns: ref.watch(bottomContainerSizeProvider) ==
                                size.height * 0.275
                            ? 0
                            : 0.5,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutQuart,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ref.watch(bottomContainerVisProvider) == 1
                          ? ParticipantGridView(
                              meeting: room,
                            )
                          : Container(),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpScreenWidget extends ConsumerWidget {
  const UpScreenWidget({
    super.key,
    required this.isMic,
    required this.isCam,
    required this.provider,
    required this.no,
    required this.name,
    required this.index,
  });

  final bool isMic;
  final bool isCam;
  final dynamic provider;
  final String no;
  final String name;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        if (provider != null) {
          showAdaptiveDialog(
            context: context,
            builder: (context) {
              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(50),
                child: Material(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      provider == 0
                          ? ParticipantTile(
                              participant: presenter!,
                              iconSize: size.height * 0.30,
                              backcolor: Colors.grey.shade200,
                              iconcolor: Colors.grey.shade800,
                            )
                          : presenter != null
                              ? ScreenShareView(
                                  participant: presenter!,
                                  iconSize: size.height * 0.30,
                                  backcolor: Colors.grey.shade200,
                                  iconcolor: Colors.grey.shade800,
                                )
                              : DefaultScreenShareCardWidget(
                                  iconSize: size.height * 0.30,
                                  backcolor: Colors.grey.shade200,
                                  iconcolor: Colors.grey.shade800),
                      Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      margin: const EdgeInsets.all(20),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(555),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        no,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 40,
                                  width: 80,
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(20),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isMic ? Icons.mic : Icons.mic_off,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        isCam
                                            ? Icons.videocam
                                            : Icons.videocam_off,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(888),
                                ),
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(555),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        no,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    provider != null
                        ? IconButton(
                            onPressed: () {
                              ref.read(provider.notifier).state =
                                  ref.watch(provider) == 0 ? 1 : 0;
                            },
                            icon: Icon(
                              ref.watch(provider) == 0
                                  ? Icons.screen_share
                                  : Icons.video_camera_front,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  height: 40,
                  width: 80,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isMic ? Icons.mic : Icons.mic_off,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        isCam ? Icons.videocam : Icons.videocam_off,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(888),
                ),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 10,
                ),
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DefaultUserCardWidget extends StatelessWidget {
  const DefaultUserCardWidget({
    super.key,
    required this.iconSize,
    required this.backcolor,
    required this.iconcolor,
  });

  final double iconSize;
  final Color backcolor;
  final Color iconcolor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backcolor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        // kullanıcı kamerasını açtıysa onu göster açmadıysa göster
        child: Image.asset(
          "assets/user.png",
          cacheHeight: 5000,
          height: iconSize,
          width: iconSize,
          color: iconcolor,
        ),
      ),
    );
  }
}

class DefaultScreenShareCardWidget extends StatelessWidget {
  const DefaultScreenShareCardWidget({
    super.key,
    required this.iconSize,
    required this.backcolor,
    required this.iconcolor,
  });

  final double iconSize;
  final Color backcolor;
  final Color iconcolor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backcolor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Image.asset(
          "assets/screen.png",
          cacheHeight: 5000,
          height: iconSize,
          color: iconcolor,
        ),
      ),
    );
  }
}

class RightPageWidget extends ConsumerStatefulWidget {
  const RightPageWidget(
      {super.key,
      required this.size,
      required this.room,
      required this.insId,
      required this.isCreater});

  final Size size;
  final Room room;
  final String insId;
  final int isCreater;

  @override
  ConsumerState<RightPageWidget> createState() => _RightPageWidgetState();
}

final textController12 = StateProvider((ref) => TextEditingController());

class _RightPageWidgetState extends ConsumerState<RightPageWidget> {
  PubSubMessages? messages;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    asd();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 300,
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  void asd() {
    widget.room.pubSub
        .subscribe("CHAT", messageHandler)
        .then((value) => setState((() => messages = value)));
  }

  void messageHandler(PubSubMessage message) {
    if (mounted) {
      setState(() => messages!.messages.add(message));
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 300,
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var message = "";
    var messageDate = "";
    var messageSenderName = "";
    var messageSenderId = "";

    return messages != null
        ? Flexible(
            child: Container(
              padding: const EdgeInsets.all(20),
              height: widget.size.height,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(boxSizeProvider.notifier).state = 0;
                      ref.read(boxIconProvider.notifier).state = 0;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutQuart,
                      width: double.infinity,
                      height: ref.watch(boxSizeProvider) == 0
                          ? widget.size.height - 170
                          : 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ParticipantList(
                          meeting: widget.room,
                          insId: widget.insId,
                          isCreater: widget.isCreater),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      ref.read(boxSizeProvider.notifier).state = 1;
                      ref.read(boxIconProvider.notifier).state = 1;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutQuart,
                      width: double.infinity,
                      height: ref.watch(boxSizeProvider) == 1
                          ? widget.size.height - 170
                          : 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    itemCount: messages!.messages
                                        .map((message) => Text(message.message))
                                        .toList()
                                        .length,
                                    itemBuilder: (context, index) {
                                      message = messages!.messages
                                          .map((message) => message.message)
                                          .toList()[index];
                                      messageSenderName = messages!.messages
                                          .map((message) => message.senderName)
                                          .toList()[index];
                                      messageSenderId = messages!.messages
                                          .map((message) => message.senderId)
                                          .toList()[index];
                                      messageDate = messages!.messages
                                          .map((message) =>
                                              message.timestamp.toString())
                                          .toList()[index];
                                      if (messageSenderId !=
                                          widget.room.localParticipant.id) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            left: 20,
                                            right: 100,
                                            top: 20,
                                            bottom: 20,
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: const Color.fromRGBO(
                                                81, 130, 155, 0.2),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                messageSenderName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromRGBO(
                                                      55, 55, 55, 1),
                                                ),
                                              ),
                                              Text(
                                                message,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromRGBO(
                                                      55, 55, 55, 1),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  messageDate,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color.fromRGBO(
                                                        55, 55, 55, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            left: 100,
                                            right: 20,
                                            top: 20,
                                            bottom: 20,
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Siz",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromRGBO(
                                                      55, 55, 55, 1),
                                                ),
                                              ),
                                              Text(
                                                message,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromRGBO(
                                                      55, 55, 55, 1),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  messageDate,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color.fromRGBO(
                                                        55, 55, 55, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: TextFormField(
                                              controller:
                                                  ref.watch(textController12),
                                              onChanged: (value) {
                                                ref
                                                    .read(msgProvider.notifier)
                                                    .state = value;
                                              },
                                              onEditingComplete: () {
                                                if (ref
                                                    .watch(msgProvider)
                                                    .trim()
                                                    .isNotEmpty) {
                                                  widget.room.pubSub
                                                      .publish(
                                                        "CHAT",
                                                        ref.watch(msgProvider),
                                                        const PubSubPublishOptions(
                                                            persist: true),
                                                      )
                                                      .then((value) => ref
                                                          .read(msgProvider
                                                              .notifier)
                                                          .state = "");
                                                  ref
                                                      .read(textController12)
                                                      .text = "";
                                                }
                                              },
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: const Color.fromRGBO(
                                                    55, 55, 55, 1),
                                              ),
                                              cursorColor: const Color.fromRGBO(
                                                  55, 55, 55, 1),
                                              cursorWidth: 2,
                                              cursorRadius:
                                                  const Radius.circular(25),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                errorStyle:
                                                    const TextStyle(height: 0),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 30, right: 30),
                                                hintText: "Mesaj Gönder",
                                                hintStyle: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color.fromRGBO(
                                                      80, 80, 80, 1),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Center(
                                            child: IconButton(
                                              onPressed: () {
                                                if (ref
                                                    .watch(msgProvider)
                                                    .trim()
                                                    .isNotEmpty) {
                                                  widget.room.pubSub
                                                      .publish(
                                                        "CHAT",
                                                        ref.watch(msgProvider),
                                                        const PubSubPublishOptions(
                                                            persist: true),
                                                      )
                                                      .then((value) => ref
                                                          .read(msgProvider
                                                              .notifier)
                                                          .state = "");
                                                  ref
                                                      .read(textController12)
                                                      .text = "";
                                                }
                                              },
                                              icon: const Icon(Icons.send),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 70,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 50),
                                AnimatedRotation(
                                  turns:
                                      ref.watch(boxIconProvider) == 0 ? 0 : 0.5,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutQuart,
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 30,
                                  ),
                                ),
                                Text(
                                  "Canlı Sohbet",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const Flexible(
            child: SpinKitChasingDots(
              color: Colors.white,
            ),
          );
  }
}
