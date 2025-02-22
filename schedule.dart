import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  final List<Map<String, dynamic>> rooms; // รับข้อมูลห้องทั้งหมด

  // กำหนดตารางเรียนที่เป็นรูปภาพของห้องต่างๆ
  final Map<String, List<Map<String, String>>> scheduleData = {
    'ห้อง 2231': [{'image': 'images/2231.jpg'}],
    'ห้อง 2232': [{'image': 'images/2232.jpg'}],
    'ห้อง 2233': [{'image': 'images/2233.jpg'}],
    'ห้อง 2234': [{'image': 'images/2234.jpg'}],
    'ห้อง 26104': [{'image': 'images/26104.jpg'}],
    'ห้อง 26105': [{'image': 'images/26105.jpg'}],
    'ห้อง 26108': [{'image': 'images/26108.jpg'}],
    'ห้อง 26202': [{'image': 'images/26202.jpg'}],
  };

  SchedulePage({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตารางเรียนของห้องทั้งหมด'),
        backgroundColor: Colors.indigoAccent,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          final roomName = room['name'] as String; // ดึงชื่อห้องจากข้อมูลที่ส่งเข้าม
          
          // ตรวจสอบข้อมูล
          print('roomName: $roomName');
          
          final schedule = scheduleData[roomName] ?? []; // ตรวจสอบว่าใน scheduleData มีข้อมูลห้องนั้นหรือไม่

          // แสดงข้อมูล
          print('schedule: $schedule'); // ตรวจสอบข้อมูลใน schedule

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                title: Text(
                  'ตารางเรียนของ $roomName',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: [
                  if (schedule.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: schedule.length,
                      itemBuilder: (context, scheduleIndex) {
                        final item = schedule[scheduleIndex];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              Image.asset(
                                item['image']!,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('ไม่มีข้อมูลตารางเรียนสำหรับห้องนี้'),
                    ),
                ],
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
