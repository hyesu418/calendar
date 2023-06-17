import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Calendar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime?, List<String>> _events = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                if (!_events.containsKey(selectedDay)) {
                  _events[selectedDay] = [];
                }
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xff6ca86f),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xff9bbf9d),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 5,
              markerDecoration: BoxDecoration(
                  color: Color(0xffd13838),
                  shape: BoxShape.circle
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _events[_selectedDay] != null ? _events[_selectedDay]!.length : 0,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_events[_selectedDay]![index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Color(0xff7b6dbe),
                        onPressed: () {
                          _showEditDialog(context, index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        color: Color(0xffd13838),
                        onPressed: () {
                          setState(() {
                            _events[_selectedDay]!.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }
  void _showAddDialog(BuildContext context) {
    String newEvent = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 일정 추가'),
          content: TextField(
            onChanged: (value) {
              newEvent = value;
            },
            decoration: InputDecoration(
              hintText: '내용',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (!_events.containsKey(_selectedDay)) {
                    _events[_selectedDay] = [];
                  }
                  _events[_selectedDay]!.add(newEvent);
                });
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    String editedEvent = _events[_selectedDay]![index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('일정 수정'),
          content: TextField(
            onChanged: (value) {
              editedEvent = value;
            },
            decoration: InputDecoration(
              hintText: '내용',
            ),
            controller: TextEditingController(text: _events[_selectedDay]![index]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _events[_selectedDay]![index] = editedEvent;
                });
                Navigator.pop(context);
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }
}