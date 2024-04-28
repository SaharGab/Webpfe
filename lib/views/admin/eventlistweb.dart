import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventListWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Management'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events found.'));
          }

          return DataTable(
            columns: const [
              DataColumn(label: Text('Event Category')),
              DataColumn(label: Text('Event Title')),
              DataColumn(label: Text('Event Date')),
              DataColumn(label: Text('Event Image')),
              DataColumn(label: Text('User ID')),
              DataColumn(label: Text('Actions')),
            ],
            rows: snapshot.data!.docs.map<DataRow>((document) {
              return DataRow(cells: [
                DataCell(Text(document['categoryEvent'] ?? 'N/A')),
                DataCell(Text(document['title'] ?? 'N/A')),
                DataCell(Text(
                  document['startDate'] == null
                      ? 'N/A'
                      : DateFormat('yyyy-MM-dd – HH:mm')
                          .format(document['startDate'].toDate()),
                )),
                DataCell(
                  document['imageUrl'] != null
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                100, // Définissez la largeur maximale que vous souhaitez pour les images
                          ),
                          child: Image.network(document['imageUrl'],
                              fit: BoxFit.cover),
                        )
                      : Text("no image"),
                ), // Assuming you have a placeholder or just empty space if no image URL is present.
                DataCell(Text(document['userId'] ?? 'N/A')),
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteEvent(document.id);
                      },
                    ),
                  ),
                ),
              ]);
            }).toList(),
          );
        },
      ),
    );
  }

  void _deleteEvent(String eventId) {
    FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }
}
