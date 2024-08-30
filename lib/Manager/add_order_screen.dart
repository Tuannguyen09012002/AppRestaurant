import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../menuitem.dart';

class AddOrderScreen extends StatefulWidget {
  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      _showErrorDialog('Chưa chọn hình ảnh');
      return;
    }
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('menu_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(_imageFile!);
      final imageUrl = await ref.getDownloadURL();
      _addMenuItem(imageUrl);
    } catch (e) {
      print('Lỗi tải ảnh lên: $e');
      _showErrorDialog('Lỗi tải ảnh lên: $e');
    }
  }

  void _addMenuItem(String imageUrl) {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (name.isEmpty && price <= 0) {
      _showErrorDialog('Chưa nhập tên món và giá');
    } else if (name.isEmpty) {
      _showErrorDialog('Chưa nhập tên món');
    } else if (price <= 0) {
      _showErrorDialog('Chưa nhập giá');
    } else {
      setState(() {
        MenuItem.fooddata.add(MenuItem(name, imageUrl, price: price));
      });
      // Xóa các đầu vào
      _nameController.clear();
      _priceController.clear();
      _imageFile = null;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm món'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên món'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _imageFile == null
                ? Text('Chưa chọn hình ảnh')
                : Image.file(_imageFile!, height: 150),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Chọn hình ảnh'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Thêm món'),
            ),
          ],
        ),
      ),
    );
  }
}
