import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../menuitem.dart';

class DeleteMenuItemPage extends StatefulWidget {
  final Function(MenuItem) onDelete; // Callback để thông báo khi xóa món ăn

  DeleteMenuItemPage({required this.onDelete});

  @override
  State<StatefulWidget> createState() => _DeleteMenuItemPageState();
}

class _DeleteMenuItemPageState extends State<DeleteMenuItemPage> {
  final List<MenuItem> menus = MenuItem.fooddata;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xóa món ăn'),
      ),
      body: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (BuildContext context, int index) {
          return buildRow(menus[index]);
        },
      ),
    );
  }

  Widget buildRow(MenuItem menu) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Image.network(menu.imageUrl),
        title: Text(menu.name),
        subtitle: Text('Giá: ${menu.price.toStringAsFixed(2)} ₫'),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _confirmDelete(menu),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(MenuItem menu) async {
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa món ${menu.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (deleteConfirmed ?? false) {

      try {
        final reference = FirebaseStorage.instance.refFromURL(menu.imageUrl);
        await reference.delete();
      } catch (e) {
        print('Lỗi khi xóa ảnh trên Firebase Storage: $e');
      }
      setState(() {
        menus.remove(menu);
      });
      widget.onDelete(menu);
    }
  }
}
