import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('การจองของคุณ'),
        backgroundColor: Colors.indigoAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('booking').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'ไม่มีรายการจอง',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          var bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    '${booking['roomName']} - ${booking['buildingName']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'เริ่ม: ${booking['startDate']} เวลา ${booking['startTime']}\n'
                    'สิ้นสุด: ${booking['endDate']} เวลา ${booking['endTime']}',
                  ),
                  leading: Icon(Icons.meeting_room, color: Colors.blueAccent),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
