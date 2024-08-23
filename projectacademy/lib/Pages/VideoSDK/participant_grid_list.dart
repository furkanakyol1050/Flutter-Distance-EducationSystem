import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/VideoSDK/meeting_screen.dart';
import 'package:projectacademy/Pages/VideoSDK/participant_tile.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantGridView extends ConsumerStatefulWidget {
  final Room meeting;
  const ParticipantGridView({super.key, required this.meeting});
  @override
  ConsumerState<ParticipantGridView> createState() =>
      _ParticipantGridViewState();
}

class _ParticipantGridViewState extends ConsumerState<ParticipantGridView> {
  Map<String, Participant> _participants = {};

  @override
  void initState() {
    _participants.putIfAbsent(widget.meeting.localParticipant.id,
        () => widget.meeting.localParticipant);
    _participants.addAll(widget.meeting.participants);
    addMeetingListeners(widget.meeting);
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.24,
      color: Colors.white,
      child: GridView.builder(
        physics: const ScrollPhysics(),
        itemCount: _participants.length,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 16 / 9,
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return SizedBox(
            height: size.height * 0.24,
            child: Stack(
              children: [
                ParticipantTile(
                  participant: _participants.values.elementAt(index),
                  iconSize: size.height * 0.25,
                  backcolor: Colors.grey.shade200,
                  iconcolor: Colors.grey.shade800,
                ),
                UpScreenWidget(
                  isCam: _participants.values
                      .elementAt(index)
                      .streams
                      .values
                      .any((value) => value.kind == 'video'),
                  isMic: _participants.values
                      .elementAt(index)
                      .streams
                      .values
                      .any((value) => value.kind == 'audio'),
                  provider: null,
                  no: (index + 1).toString(),
                  name: _participants.values.elementAt(index).displayName,
                  index: index,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
