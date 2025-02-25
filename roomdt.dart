import 'package:flutter/material.dart';
import 'package:bookroom/app/booking.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomDetails extends StatefulWidget {
  final Map<String, String> room;
  final String buildingName;
  final Function(String, String) onStatusChanged; // Callback function

  RoomDetails(
      {required this.room,
      required this.buildingName,
      required this.onStatusChanged});

  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  String status = '';

  List<Map<String, dynamic>> bookings = []; // เพิ่มตัวแปรเพื่อเก็บประวัติการจอง

  @override
  void initState() {
    super.initState();
    status = widget.room['status'] ?? 'ว่าง';

    FirebaseFirestore.instance
        .collection("booking")
        .where('roomName', isEqualTo: widget.room['name'])
        .where('buildingName', isEqualTo: widget.buildingName)
        .get()
        .then((event) {
      for (var doc in event.docs) {
        final booking = doc.data();
        booking["id"] = doc.id;
        setState(() {
          bookings.add(booking); // อ่านประวัติการจองจากฐานข้อมูล
        });
      }
    });
  }

  void updateStatus(String newStatus) async {
    setState(() {
      status = newStatus;
      widget.room['status'] = newStatus;
      widget.onStatusChanged(
          widget.room['name']!, newStatus); // ส่งข้อมูลสถานะกลับไปที่ HomePage
    });

    try {
      // บันทึกสถานะห้องลงใน Collection `room_status`
      await FirebaseFirestore.instance
          .collection("room_status") // Collection สำหรับบันทึกสถานะห้อง
          .doc(
              "${widget.buildingName}_${widget.room['name']}") // ใช้ชื่ออาคาร+ห้องเป็น ID
          .set(
              {
            "roomName": widget.room['name'],
            "buildingName": widget.buildingName,
            "status": newStatus,
            "updatedAt": FieldValue.serverTimestamp(), // บันทึกเวลาอัปเดตล่าสุด
          },
              SetOptions(
                  merge:
                      true)); // ใช้ merge เพื่ออัปเดตข้อมูลเดิมแทนการเขียนทับทั้งหมด

      print("บันทึกสถานะห้องเรียบร้อย: ${widget.room['name']} -> $newStatus");
    } catch (e) {
      print("เกิดข้อผิดพลาดในการบันทึกสถานะ: $e");
    }
  }

  void bookRoom() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('จองห้อง'),
          content: Text('คุณต้องการจอง ${widget.room['name']} หรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // รอผลจาก BookingPage
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPage(
                      roomName: widget.room['name']!,
                      buildingName: widget.buildingName,
                      initialStatus: status,
                    ),
                  ),
                );

                if (result != null) {
                  setState(() {
                    bookings.add(result); // เพิ่มการจองลงในประวัติ
                  });
                }
              },
              child: Text(
                'ยืนยัน',
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBooking(int index) async {
    final booking = bookings[index];

    print(booking);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('roomName', isEqualTo: booking['roomName'])
        .where('buildingName', isEqualTo: booking['buildingName'])
        .where('endDate', isEqualTo: booking['endDate'])
        .where('endTime', isEqualTo: booking['endTime'])
        .where('startDate', isEqualTo: booking['startDate'])
        .where('startTime', isEqualTo: booking['startTime'])
        .get();

    for (var doc in querySnapshot.docs) {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(doc.id)
          .delete();
      print('Deleted document with ID: ${doc.id}');
    }

    await FirebaseFirestore.instance
        .collection('booking')
        .doc(booking['id'])
        .delete();

    setState(() {
      bookings.removeAt(index); // ลบการจองตามดัชนี
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.buildingName} - ${widget.room['name']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.buildingName} - ${widget.room['name']}',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'สถานะ: $status',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => updateStatus('ไม่ว่าง'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == 'ใช้งานอยู่'
                        ? Colors.green
                        : Colors.blueGrey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  child: Text(
                    'ใช้งานอยู่',
                    style: TextStyle(
                      color:
                          status == 'ใช้งานอยู่' ? Colors.white : Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => updateStatus('ว่าง'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == 'เลิกใช้งาน'
                        ? Colors.red
                        : Colors.blueGrey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  child: Text(
                    'เลิกใช้งาน',
                    style: TextStyle(
                      color: status == 'เลิกใช้งาน' ? Colors.white : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'ประวัติการจอง:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('${bookings[index]['roomName']}'),
                      subtitle: Text(
                        'จาก ${bookings[index]['startDate']} เวลา ${bookings[index]['startTime']} '
                        'ถึง ${bookings[index]['endDate']} เวลา ${bookings[index]['endTime']}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBooking(index), // ลบการจอง
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20), // เพิ่มพื้นที่ว่างที่นี่
            Center(
              child: ElevatedButton(
                onPressed: bookRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: Text(
                  'จองห้อง',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
