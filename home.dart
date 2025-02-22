import 'package:flutter/material.dart';
import 'package:bookroom/roomdt/roomdt.dart';
import 'package:bookroom/schedule/schedule.dart';
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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  final List<Map<String, dynamic>> buildings = [
    {
      'buildingName': 'อาคาร 22',
      'rooms': [
        {'name': 'ห้อง 2231', 'status': ''},
        {'name': 'ห้อง 2232', 'status': ''},
        {'name': 'ห้อง 2233', 'status': ''},
        {'name': 'ห้อง 2234', 'status': ''},
      ],
    },
    {
      'buildingName': 'อาคาร 26',
      'rooms': [
        {'name': 'ห้อง 26104', 'status': ''},
        {'name': 'ห้อง 26105', 'status': ''},
        {'name': 'ห้อง 26108', 'status': ''},
        {'name': 'ห้อง 26202', 'status': ''},
      ],
    },
  ];

  void updateRoomStatus(String roomName, String newStatus) {
    for (var building in buildings) {
      for (var room in building['rooms']) {
        if (room['name'] == roomName) {
          setState(() {
            room['status'] = newStatus;
          });
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Booking App'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
        elevation: 4,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: buildings.length,
        itemBuilder: (context, buildingIndex) {
          final building = buildings[buildingIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  building['buildingName'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: building['rooms'].length,
                itemBuilder: (context, roomIndex) {
                  final room = building['rooms'][roomIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        title: Text(
                          room['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'สถานะ: ${room['status']}',
                          style: TextStyle(
                            color: room['status'] == 'ว่าง' ? Colors.green : Colors.red,
                          ),
                        ),
                        trailing: Icon(
                          room['status'] == 'ว่าง' ? Icons.check_circle : Icons.cancel,
                          color: room['status'] == 'ว่าง' ? Colors.green : Colors.red,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomDetails(
                                room: room,
                                buildingName: building['buildingName'],
                                onStatusChanged: updateRoomStatus,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    final allRooms = [
      ...buildings[0]['rooms'], // ห้องจากอาคาร 22
      ...buildings[1]['rooms'], // ห้องจากอาคาร 26
    ];

    // แปลงประเภทให้เป็น List<Map<String, dynamic>> ก่อนส่ง
    List<Map<String, dynamic>> allRoomsTyped = List<Map<String, dynamic>>.from(allRooms);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchedulePage(rooms: allRoomsTyped),
      ),
    );
  },
  label: Text('ดูตารางเรียน'),
  icon: Icon(Icons.schedule),
  backgroundColor: const Color.fromARGB(255, 128, 146, 252),
),

    );
  }
}
