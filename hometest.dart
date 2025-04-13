import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookroom/app/roomdt.dart';
import 'package:bookroom/app/booked.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking Room App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> buildings = [
    {
      'buildingName': 'อาคาร 22',
      'rooms': [
        {'name': '2231', 'status': '⏳ กำลังโหลด...'},
        {'name': '2232', 'status': '⏳ กำลังโหลด...'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchRoomStatus();
  }

  void _fetchRoomStatus() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime now = DateTime.now();
    String currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    List<String> daysInThai = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์'];
    String today = daysInThai[now.weekday % 7]; // วันปัจจุบัน

    for (var building in buildings) {
      for (var room in building['rooms']) {
        String roomName = room['name'];
        String status = await _getRoomStatus(roomName, today, currentTime);
        setState(() {
          room['status'] = status;
        });
      }
    }
  }

  Future<String> _getRoomStatus(String roomName, String day, String currentTime) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // ตรวจสอบว่าห้องนี้มีการเรียนการสอนอยู่หรือไม่
    QuerySnapshot schedule = await firestore.collection('schedule_2231')
        .where('day', isEqualTo: day)
        .where('room', isEqualTo: roomName)
        .get();

    for (var doc in schedule.docs) {
      String dbStartTime = doc['start_time'];
      String dbEndTime = doc['end_time'];
      if (_isTimeOverlap(currentTime, dbStartTime, dbEndTime)) {
        return '📚 มีการเรียนการสอน';
      }
    }

    // ตรวจสอบว่าห้องนี้มีการจองอยู่หรือไม่
    QuerySnapshot booking = await firestore.collection('booking')
        .where('roomName', isEqualTo: roomName)
        .where('day', isEqualTo: day)
        .get();

    for (var doc in booking.docs) {
      String dbStartTime = doc['startTime'];
      String dbEndTime = doc['endTime'];
      if (_isTimeOverlap(currentTime, dbStartTime, dbEndTime)) {
        return '🛑 มีการจองแล้ว';
      }
    }

    return '✅ ว่าง';
  }

  bool _isTimeOverlap(String currentTime, String startTime, String endTime) {
    return (currentTime.compareTo(startTime) >= 0 && currentTime.compareTo(endTime) <= 0);
  }

  void _searchAvailableRooms() {
    showDialog(
      context: context,
      builder: (context) {
        String selectedDay = 'จันทร์';
        String startTime = '08:00';
        String endTime = '12:00';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('ค้นหาห้องว่าง'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedDay,
                    items: ['จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์']
                        .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDay = value!;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'เวลาเริ่มต้น (HH:MM)'),
                    onChanged: (value) => startTime = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'เวลาสิ้นสุด (HH:MM)'),
                    onChanged: (value) => endTime = value,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    List<String> availableRooms = [];
                    for (var building in buildings) {
                      for (var room in building['rooms']) {
                        String roomName = room['name'];
                        String status = await _getRoomStatus(roomName, selectedDay, startTime);
                        if (status == '✅ ว่าง') {
                          availableRooms.add(roomName);
                        }
                      }
                    }
                    Navigator.pop(context);
                    _showAvailableRooms(availableRooms);
                  },
                  child: Text('ค้นหา'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAvailableRooms(List<String> rooms) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ห้องว่าง'),
          content: rooms.isNotEmpty ? Text(rooms.join(', ')) : Text('ไม่มีห้องว่างในช่วงเวลาที่เลือก'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Booking App'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchAvailableRooms,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: buildings.length,
        itemBuilder: (context, buildingIndex) {
          final building = buildings[buildingIndex];
          return Column(
            children: [
              Text(building['buildingName'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...building['rooms'].map<Widget>((room) => Card(
                    child: ListTile(
                      title: Text('ห้อง ${room['name']}'),
                      subtitle: Text(room['status']),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        child: Text('ดูรายละเอียด'),
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
