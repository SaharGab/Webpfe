import 'package:admin_pfe/views/admin/edit_tourist_site_page.dart';
import 'package:admin_pfe/views/admin/touristsitepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TouristSiteListPage extends StatefulWidget {
  @override
  _TouristSiteListPageState createState() => _TouristSiteListPageState();
}

class _TouristSiteListPageState extends State<TouristSiteListPage> {
  List<DocumentSnapshot> _touristSites = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('touristSites')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _touristSites = snapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tourist Sites')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Image')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _touristSites.map((DocumentSnapshot doc) {
            // Assurez-vous que 'imageUrls' est une liste de chaînes d'URLs valides
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
                                  return const Text(
                                      'Failed to load image'); // Texte affiché en cas d'erreur
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
              DataCell(Text(doc['description'] ?? 'N/A')),
              DataCell(Text(doc['category'] ?? 'N/A')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TouristSitePage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 123, 73, 15),
        tooltip: 'Add Tourist Site',
      ),
    );
  }
}
