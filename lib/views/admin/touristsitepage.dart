import 'dart:typed_data';
import 'package:admin_pfe/views/admin/tourist_sites_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as p;

// Use 'universal_html' instead of 'dart:html'

class TouristSitePage extends StatefulWidget {
  @override
  _TouristSitePageState createState() => _TouristSitePageState();
}

class _TouristSitePageState extends State<TouristSitePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String name = '';
  String location = '';
  String description = '';
  List<String> imageUrls = [];
  String category = '';
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles;
  final List<String> categories = [
    'Accommodation',
    'Cafe & Restaurant',
    'Activities',
    'To Explore'
  ];

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    setState(() {
      _imageFiles = selectedImages;
    });
  }

  Future<String> _uploadFile(XFile file) async {
    String fileName = p.basename(file.path);
    String mimeType = mime(fileName) ?? 'application/octet-stream';
    Reference fileRef = FirebaseStorage.instance.ref('touristSites/$fileName');

    if (kIsWeb) {
      // Running on the web
      Uint8List fileBytes = await file.readAsBytes();
      // html.File htmlFile = html.File([fileBytes], fileName, {'type': mimeType});
      await fileRef.putData(fileBytes, SettableMetadata(contentType: mimeType));
    } else {
      // Running on mobile
    }
    return await fileRef.getDownloadURL();
  }

  Future<void> _uploadImages() async {
    setState(() {
      _isLoading = true;
    });
    List<String> urls = [];
    for (var file in _imageFiles!) {
      try {
        String url = await _uploadFile(file);
        urls.add(url);
      } catch (e) {
        print("Error uploading file: ${file.name}, Error: $e");
      }
    }
    setState(() {
      imageUrls.addAll(urls);
      _isLoading = false;
    });
  }

  void _saveTouristSite() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _uploadImages();

      FirebaseFirestore.instance.collection('touristSites').add({
        'name': name,
        'location': location,
        'description': description,
        'imageUrls': imageUrls,
        'category': category,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Tourist Site Added Successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TouristSiteListPage()),
        );
      }).catchError((error) {
        print("Failed to save data: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add tourist site. Please try again!'),
              backgroundColor: Colors.red),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Tourist Site')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city)),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a name'
                      : null,
                  onSaved: (value) => name = value!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.map)),
                  onSaved: (value) => location = value!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description)),
                  onSaved: (value) => description = value!,
                  maxLines: 3,
                ),
                SizedBox(height: 15),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category)),
                  value: category.isEmpty ? null : category,
                  items: categories.map((String category) {
                    return DropdownMenuItem(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      category = newValue!;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                  onSaved: (value) => category = value.toString(),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _pickImages,
                    child: Text('Select Images'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 123, 73, 15),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTouristSite,
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 123, 73, 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
