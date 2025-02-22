import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


String formatTimeOfDay(TimeOfDay time) {
  String hour = time.hour < 10 ? '0${time.hour}' : '${time.hour}';
  String minute = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
  return '$hour:$minute';
}

class BookingPage extends StatefulWidget {
  final String roomName;
  final String buildingName;
  final String initialStatus;

  BookingPage({required this.roomName, required this.buildingName, required this.initialStatus});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (startDate.isAfter(endDate)) endDate = startDate;
        } else {
          endDate = picked;
          if (endDate.isBefore(startDate)) startDate = endDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'การจองสำเร็จ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'คุณได้จองห้อง ${widget.roomName} \n\n'
              'ตั้งแต่วันที่ ${startDate.toLocal().toString().split(' ')[0]} เวลา ${startTime.format(context)}\n'
              'ถึงวันที่ ${endDate.toLocal().toString().split(' ')[0]} เวลา ${endTime.format(context)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด AlertDialog

                final data = <String, dynamic> {
                  'roomName': widget.roomName,
                  'buildingName': widget.buildingName,
                  'startDate': startDate.toLocal().toString().split(' ')[0], // 2025-11-08
                  'endDate': endDate.toLocal().toString().split(' ')[0],
                  'startTime': formatTimeOfDay(startTime), // 11:00
                  'endTime': formatTimeOfDay(endTime),
                };

                String id = "${data['buildingName']}_${data['roomName']}_${DateTime.now().microsecondsSinceEpoch}";

                FirebaseFirestore.instance.collection("booking").doc(id).set(data);
                
                data['id'] = id;

                Navigator.of(context).pop(data); // ส่งข้อมูลการจองกลับ
              },
              child: Text(
                'ตกลง',
                style: TextStyle(color: Colors.blue),
              ),
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
        title: Text('จองห้อง ${widget.roomName}'),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('เลือกวันที่เริ่มต้น'),
            SizedBox(height: 8),
            _buildDateTimeSelector(
              label: 'วันที่: ',
              date: startDate,
              onTap: () => _selectDate(context, true),
            ),
            _buildDateTimeSelector(
              label: 'เวลา: ',
              time: startTime,
              onTap: () => _selectTime(context, true),
            ),
            SizedBox(height: 16),
            _buildSectionTitle('เลือกวันที่สิ้นสุด'),
            SizedBox(height: 8),
            _buildDateTimeSelector(
              label: 'วันที่: ',
              date: endDate,
              onTap: () => _selectDate(context, false),
            ),
            _buildDateTimeSelector(
              label: 'เวลา: ',
              time: endTime,
              onTap: () => _selectTime(context, false),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'ยืนยันการจอง',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
    );
  }

  Widget _buildDateTimeSelector({required String label, DateTime? date, TimeOfDay? time, required VoidCallback onTap}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: Colors.blueGrey[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            date != null ? '${date.toLocal()}'.split(' ')[0] : time!.format(context),
            style: TextStyle(fontSize: 16, color: Colors.indigo),
          ),
        ),
      ],
    );
  }
}
