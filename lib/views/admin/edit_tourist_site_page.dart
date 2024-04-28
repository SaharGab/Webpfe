import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTouristSitePage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  EditTouristSitePage({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  _EditTouristSitePageState createState() => _EditTouristSitePageState();
}

class _EditTouristSitePageState extends State<EditTouristSitePage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.documentSnapshot['name']);
    _locationController =
        TextEditingController(text: widget.documentSnapshot['location']);
    _descriptionController =
        TextEditingController(text: widget.documentSnapshot['description']);
    _selectedCategory = widget.documentSnapshot['category'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateTouristSite() {
    if (_formKey.currentState!.validate()) {
      widget.documentSnapshot.reference
          .update({
            'name': _nameController.text,
            'location': _locationController.text,
            'description': _descriptionController.text,
            'category': _selectedCategory
          })
          .then(() {
            Navigator.of(context).pop();
          } as FutureOr Function(void value))
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update the site: $error')));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Tourist Site'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateTouristSite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: 'Name', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the site name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                      labelText: 'Location', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  items: <String>[
                    'Accommodation',
                    'Cafe & Restaurant',
                    'Activities',
                    'To Explore'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateTouristSite,
                  child: Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
