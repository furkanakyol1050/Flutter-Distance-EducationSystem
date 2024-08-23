// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:projectacademy/Pages/hub/studentpanel/navbarstudent.dart';
import 'package:projectacademy/myDesign.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 65),
          child: Container(
            padding: const EdgeInsets.all(40),
            width: size.width,
            height: 953,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(35, 35, 35, 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SfCalendar(
                      backgroundColor: Colors.white,
                      view: CalendarView.month,
                      todayHighlightColor:
                          const Color.fromRGBO(83, 145, 101, 1),
                      cellBorderColor: Colors.white,
                      firstDayOfWeek: 1,
                      appointmentTimeTextFormat: 'HH:mm',
                      dataSource: _getCalendarDataSource(
                          ref.watch(calendarLecInfos),
                          ref.watch(calendarHomeworkInfos),
                          ref.watch(calendarExamInfos)),
                      appointmentBuilder:
                          (context, calendarAppointmentDetails) {
                        final Appointment appointment =
                            calendarAppointmentDetails.appointments.first;
                        return Card(
                          child: ListTile(
                            tileColor: appointment.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            leading: SizedBox(
                              width: 100,
                              child: Text(
                                """${DateFormat('HH:mm').format(appointment.startTime)}"""
                                """-${DateFormat('HH:mm').format(appointment.endTime)}""",
                                style: Design().poppins(
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                            title: Text(
                              appointment.subject,
                              style: Design().poppins(
                                color: Colors.white,
                                size: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              appointment.notes ?? "",
                              style: Design().poppins(
                                color: Colors.white,
                                size: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        );
                      },
                      selectionDecoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(83, 145, 101, 1),
                          width: 3,
                        ),
                      ),
                      monthViewSettings: MonthViewSettings(
                        appointmentDisplayCount: 10,
                        showAgenda: true,
                        dayFormat: 'EEE',
                        agendaItemHeight: 80,
                        agendaStyle: AgendaStyle(
                          backgroundColor:
                              const Color.fromARGB(255, 226, 229, 233),
                          placeholderTextStyle: Design().poppins(
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                          dayTextStyle: Design().poppins(
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                          dateTextStyle: Design().poppins(
                            color: Colors.grey.shade600,
                            size: 22,
                          ),
                          appointmentTextStyle: Design().poppins(
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                        monthCellStyle: MonthCellStyle(
                          textStyle: Design().poppins(
                            color: const Color.fromRGBO(50, 50, 50, 1),
                            size: 18,
                          ),
                          leadingDatesTextStyle: Design().poppins(
                            color: const Color.fromRGBO(180, 180, 180, 1),
                            size: 18,
                          ),
                          trailingDatesTextStyle: Design().poppins(
                            color: const Color.fromRGBO(180, 180, 180, 1),
                            size: 18,
                          ),
                        ),
                      ),
                      headerStyle: CalendarHeaderStyle(
                        backgroundColor: const Color.fromRGBO(35, 35, 35, 1),
                        textStyle: Design().poppins(
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      viewHeaderStyle: ViewHeaderStyle(
                        backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                        dayTextStyle: Design().poppins(
                          color: const Color.fromRGBO(205, 205, 205, 1),
                          size: 16,
                        ),
                        dateTextStyle: Design().poppins(
                          color: const Color.fromRGBO(205, 205, 205, 1),
                          size: 16,
                        ),
                      ),
                      todayTextStyle: Design().poppins(
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 226, 229, 233),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

_AppointmentDataSource _getCalendarDataSource(
    List<Map<String, dynamic>> courselist,
    List<Map<String, dynamic>> homeworkList,
    List<Map<String, dynamic>> examList) {
  List<Appointment> appointments = <Appointment>[];
  //! if else ile bu 3 yapıdan birisine girecekler
  DateTime now = DateTime.now();
  int currentYear = now.year;
  int currentMonth = now.month;

  for (var course in courselist) {
    for (int i = 0; i < course['startTime'].length; i++) {
      List<String> startTimeParts = course['startTime'][i].split(':');
      List<String> endTimeParts = course['endTime'][i].split(':');
      int dayOfWeek = int.parse(course['day'][i]);

      // Iterate through all days of the current month
      for (int day = 1;
          day <= DateTime(currentYear, currentMonth + 1, 0).day;
          day++) {
        DateTime date = DateTime(currentYear, currentMonth, day);

        if (date.weekday == dayOfWeek + 1) {
          // DateTime weekday: 1=Mon, 7=Sun
          DateTime startTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]),
          );

          DateTime endTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
          );

          appointments.add(Appointment(
              startTime: startTime,
              endTime: endTime,
              subject: "${course['name']} Canlı Dersi",
              color: const Color.fromRGBO(211, 118, 118, 1),
              notes: course['instructorName']));
        }
      }
    }
  }

  for (var exam in examList) {
    appointments.add(Appointment(
      startTime: exam['startTime'],
      endTime: exam['endTime'],
      subject: exam['subject'],
      color: const Color.fromRGBO(81, 130, 155, 1),
      notes: exam['notes'],
    ));
  }
  for (var homework in homeworkList) {
    String deadlineString = homework['deadline'];
    List<String> parts = deadlineString.split(',');
    DateTime deadlineDateTime = DateTime.parse(parts[0]);

    if (parts.length > 1) {
      String timeOfDayString =
          parts[1].replaceAll('TimeOfDay(', '').replaceAll(')', '');
      List<String> timeParts = timeOfDayString.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      deadlineDateTime = DateTime(deadlineDateTime.year, deadlineDateTime.month,
          deadlineDateTime.day, hour, minute);
    }

    appointments.add(Appointment(
      startTime: deadlineDateTime,
      endTime: deadlineDateTime.add(const Duration(minutes: 1)),
      subject: '${homework['title']} Son Gönderim Tarihi',
      color: const Color.fromRGBO(246, 153, 92, 1),
      notes: homework['name'],
    ));
  }

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
