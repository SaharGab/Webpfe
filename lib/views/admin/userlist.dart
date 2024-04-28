import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }
          return DataTable(
            columns: const [
              DataColumn(label: Text('User ID')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('Actions')),
            ],
            rows: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> user =
                  document.data()! as Map<String, dynamic>;
              return DataRow(cells: [
                DataCell(Text(document.id)),
                DataCell(Text(user['email'] ?? 'N/A')),
                DataCell(Text(user['role'] ?? 'N/A')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteUser(document.id),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          );
        },
      ),
    );
  }

  void _deleteUser(String userId) {
    FirebaseFirestore.instance.collection('Users').doc(userId).delete().then(
          (value) => print('User Deleted'),
          onError: (error) => print('Failed to Delete user: $error'),
        );
  }
}
