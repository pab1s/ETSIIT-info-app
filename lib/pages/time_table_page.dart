
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


class TimeTableCalendar extends StatefulWidget {
  const TimeTableCalendar({super.key});

  @override
  CalendarAppointment createState() => CalendarAppointment();
}

class CalendarAppointment extends State<TimeTableCalendar> {
  final CalendarDataSource _dataSource = _DataSource(<Appointment>[]);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
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
                            Text(appointment.notes ?? 'No hay información adicional'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cerrar'),
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
          ),
        ),
      ),
    );
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    List<DateTime> visibleDates = viewChangedDetails.visibleDates;
    List<Appointment> appointments = <Appointment>[];
    _dataSource.appointments!.clear();

    for (int i = 0; i < visibleDates.length; i++) {
      if (visibleDates[i].weekday == 6 || visibleDates[i].weekday == 7) {
        continue;
      }
      //Se añaden al timetable elementos
      // PDOO - Programacion y Diseño Orientado a Objetos
    if (visibleDates[i].weekday == DateTime.monday) {
      appointments.add(Appointment(
          startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 9, 30),
          endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30),
          subject: 'PDOO - Teoría',
          notes: 'Clase: 1.6\nProfesor: Cortijo Bon',
          color: Colors.green));
      appointments.add(Appointment(
          startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30),
          endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 13, 30),
          subject: 'PL - Teoría',
          notes: 'Clase: 1.2\nProfesor: Ramon Lopez',
          color: Colors.blue));
    }
    if (visibleDates[i].weekday == DateTime.tuesday) {
      appointments.add(Appointment(
          startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30),
          endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 13, 30),
          subject: 'PDOO - Prácticas A1',
          color: Colors.lightGreen));
      appointments.add(Appointment(
          startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 9, 30),
          endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30),
          subject: 'PL - Prácticas A2',
          color: Colors.lightBlue));
    }
    if (visibleDates[i].weekday == DateTime.wednesday) {
      appointments.add(Appointment(
        startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 9, 30), 
        endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30) ,
        subject: 'SO - Teoria',
        color: Colors.red,
        ));
      appointments.add(Appointment(
        startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30), 
        endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 13, 30) ,
        subject: 'SO - Practicas D3',
        color: Colors.redAccent,
        ));
    }

    if (visibleDates[i].weekday == DateTime.thursday) {
      appointments.add(Appointment(
        startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 9, 30), 
        endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30) ,
        subject: 'ISE - Teoria',
        notes: 'Clase: 0.1\nProfesor: Hector Pomares',
        color: const Color.fromARGB(255, 184, 54, 244),
        ));
      appointments.add(Appointment(
        startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30), 
        endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 13, 30) ,
        subject: 'VC - Practicas A2',
        color: const Color.fromARGB(255, 255, 226, 82),
        ));
    }

    if (visibleDates[i].weekday == DateTime.friday) {
      appointments.add(Appointment(
        startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30), 
        endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 13, 30) ,
        subject: 'ISE - Practicas A2',
        notes: 'Clase: 1.4\nProfesor: Alberto Guillen',
        color: const Color.fromARGB(255, 184, 54, 244),
        ));
      appointments.add(Appointment(
        startTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 9, 30), 
        endTime: DateTime(visibleDates[i].year, visibleDates[i].month, visibleDates[i].day, 11, 30) ,
        subject: 'VC - Teoria',
        color: const Color.fromARGB(255, 255, 226, 82),
        ));
    }
      
    }

    for (int i = 0; i < appointments.length; i++) {
      _dataSource.appointments!.add(appointments[i]);
    }
    _dataSource.notifyListeners(
        CalendarDataSourceAction.reset, _dataSource.appointments!);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
