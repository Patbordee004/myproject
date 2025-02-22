import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      title: 'Room Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, String>> rooms = [
    {'name': 'Deluxe Room', 'price': '1000'},
    {'name': 'Suite Room', 'price': '1500'},
    {'name': 'Standard Room', 'price': '800'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rooms List'),
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(rooms[index]['name']!),
              subtitle: Text('Price: ${rooms[index]['price']} THB'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomDetails(room: rooms[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class RoomDetails extends StatelessWidget {
  final Map<String, String> room;

  RoomDetails({required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${room['name']} Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room Name: ${room['name']}',
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Price: ${room['price']} THB',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Perform booking action
              },
              child: Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
