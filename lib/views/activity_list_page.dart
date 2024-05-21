import 'package:admin_pfe/views/admin/edit_tourist_site_page.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ActivitiesListPage extends StatefulWidget {
  @override
  _ActivitiesListPageState createState() => _ActivitiesListPageState();
}

class _ActivitiesListPageState extends State<ActivitiesListPage> {
  List<DocumentSnapshot> _activities = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('touristSites')
        .where('category', isEqualTo: 'Activities')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _activities = snapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activities')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Image')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Subcategory')), // Added subcategory column
            DataColumn(label: Text('Actions')),
          ],
          rows: _activities.map((DocumentSnapshot doc) {
            var imageUrls = List.from(doc.get('imageUrls') ?? []);
            return DataRow(cells: [
              DataCell(
                imageUrls.isNotEmpty
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 100,
                          minHeight: 50,
                          maxWidth: 100,
                          maxHeight: 50,
                        ),
                        child: kIsWeb
                            ? Image.network(
                                imageUrls.first,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return const Text('Failed to load image');
                                },
                              )
                            : CachedNetworkImage(
                                imageUrl: imageUrls.first,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                      )
                    : const Text('No image'),
              ),
              DataCell(Text(doc['name'] ?? 'N/A')),
              DataCell(Text(doc['location'] ?? 'N/A')),
              DataCell(
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 150,
                  ),
                  child: Text(doc['description'] ?? 'N/A',
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              DataCell(Text(doc['category'] ?? 'N/A')),
              DataCell(
                  Text(doc['subcategory'] ?? 'N/A')), // Display subcategory
              DataCell(Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditTouristSitePage(
                                  documentSnapshot: doc,
                                )),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      doc.reference.delete();
                    },
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
