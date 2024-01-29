import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'dart:async';
import 'package:light/light.dart';
import '../entities/courses.dart';

class TimeTableCalendar extends StatefulWidget {
  const TimeTableCalendar({super.key});

  @override
  CalendarAppointment createState() => CalendarAppointment();
}

class CalendarAppointment extends State<TimeTableCalendar> {
  Light? _light;
  StreamSubscription? _lightSubscription;
  bool _darkMode = false;
  final CalendarDataSource _dataSource = _DataSource(<Appointment>[]);

  @override
  void initState() {
    super.initState();
    _light = Light();
    _lightSubscription = _light?.lightSensorStream.listen((luxValue) {
      setState(() {
        _darkMode = luxValue < 100; // Ajusta este valor según sea necesario
      });
    });
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SfCalendarTheme(
            data: SfCalendarThemeData(
              brightness: _darkMode ? Brightness.dark : Brightness.light,
              backgroundColor: _darkMode ? Colors.black : Colors.white,
              headerTextStyle:
                  TextStyle(color: _darkMode ? Colors.white : Colors.black),
              viewHeaderDateTextStyle:
                  TextStyle(color: _darkMode ? Colors.white : Colors.black),
              viewHeaderDayTextStyle:
                  TextStyle(color: _darkMode ? Colors.white : Colors.black),
              timeTextStyle:
                  TextStyle(color: _darkMode ? Colors.white : Colors.black),
            ),
            child: SfCalendar(
              dataSource: _dataSource,
              view: CalendarView.workWeek,
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment ||
                    details.targetElement == CalendarElement.agenda) {
                  final Appointment appointment = details.appointments![0];
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(appointment.subject),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(appointment.notes ??
                                  'No hay información adicional'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cerrar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              firstDayOfWeek: 1,
              onViewChanged: viewChanged,
              headerStyle: CalendarHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  color: _darkMode ? Colors.white : Colors.black,
                ),
              ),
              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: TextStyle(
                  color: _darkMode ? Colors.white : Colors.black,
                ),
                dateTextStyle: TextStyle(
                  color: _darkMode ? Colors.white : Colors.black,
                ),
              ),
              timeSlotViewSettings: TimeSlotViewSettings(
                startHour: 8,
                timeTextStyle: TextStyle(
                  color: _darkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: _darkMode ? Colors.black : Colors.white,
      ),
    );
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    List<DateTime> visibleDates = viewChangedDetails.visibleDates;
    List<Appointment> appointments = <Appointment>[];
    _dataSource.appointments!.clear();

    List<Course> courses = CoursesProvider().getCourses();

    for (DateTime date in visibleDates) {
      if (date.weekday == 6 || date.weekday == 7) {
        continue;
      }

      for (Course course in courses) {
        if (date.weekday == course.dayOfWeek) {
          appointments.add(Appointment(
            startTime: DateTime(date.year, date.month, date.day,
                course.startHour, course.startMinute),
            endTime: DateTime(date.year, date.month, date.day, course.endHour,
                course.endMinute),
            subject: course.title,
            color: course.color,
            notes:
                'Asignatura: ${course.nombreCompleto}\nProfesor: ${course.professor}\nAula: ${course.aula}',
          ));
        }
      }
    }

    _dataSource.appointments!.addAll(appointments);
    _dataSource.notifyListeners(
        CalendarDataSourceAction.reset, _dataSource.appointments!);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
