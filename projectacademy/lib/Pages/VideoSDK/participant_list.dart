import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectacademy/Pages/VideoSDK/meeting_screen.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantList extends ConsumerStatefulWidget {
  final Room meeting;
  final String insId;
  final int isCreater;
  const ParticipantList(
      {super.key,
      required this.meeting,
      required this.insId,
      required this.isCreater});

  @override
  ConsumerState<ParticipantList> createState() => _ParticipantListState();
}

class _ParticipantListState extends ConsumerState<ParticipantList> {
  Map<String, Participant> _participants = {};
  bool isAudio = false;
  bool isVideo = false;

  @override
  void initState() {
    _participants.putIfAbsent(widget.meeting.localParticipant.id,
        () => widget.meeting.localParticipant);
    _participants.addAll(widget.meeting.participants);
    addMeetingListeners(widget.meeting);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                turns: ref.watch(boxIconProvider) == 0 ? 0 : 0.5,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 30,
                ),
              ),
              Text(
                "Katılımcılar",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _participants.length.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(246, 153, 92, 1),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.group,
                size: 25,
                color: Color.fromRGBO(246, 153, 92, 1),
              ),
              const SizedBox(width: 50),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                return Card(
                  shadowColor: Colors.transparent,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    tileColor: Colors.white,
                    title: Text(
                      _participants.values.elementAt(index).displayName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    subtitle: Text(
                      _participants.values.elementAt(index).id,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                    leading: widget.isCreater == 0
                        ? _participants.values.elementAt(index).id.toString() ==
                                widget.insId
                            ? const Icon(Icons.menu_book)
                            : const Icon(Icons.school)
                        : widget.meeting.localParticipant.id ==
                                _participants.values
                                    .elementAt(index)
                                    .id
                                    .toString()
                            ? const Icon(Icons.menu_book)
                            : const Icon(Icons.school),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _participants.values
                                  .elementAt(index)
                                  .streams
                                  .values
                                  .any((value) => value.kind == 'audio')
                              ? Icons.mic
                              : Icons.mic_off,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          _participants.values
                                  .elementAt(index)
                                  .streams
                                  .values
                                  .any((value) => value.kind == 'video')
                              ? Icons.videocam
                              : Icons.videocam_off,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void addMeetingListeners(Room meeting) {
    meeting.on(Events.participantJoined, (participant) {
      if (mounted) {
        final newParticipants = _participants;
        newParticipants[participant.id] = participant;
        setState(() => _participants = newParticipants);
      }
    });

    meeting.on(Events.participantLeft, (participantId) {
      if (mounted) {
        final newParticipants = _participants;
        newParticipants.remove(participantId);

        setState(() => _participants = newParticipants);
      }
    });
  }
}
