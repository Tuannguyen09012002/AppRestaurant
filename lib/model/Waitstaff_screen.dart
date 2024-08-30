import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../menuitem.dart';
import '../Waitstaff/list.dart';
import 'package:APP401/services/change_password_screen.dart';
import '../Waitstaff/menu_page.dart';
import '../Waitstaff/table_management.dart';

class ManHinhNhanVienPhucVu extends StatefulWidget {
  final MenuItem item;

  ManHinhNhanVienPhucVu({required this.item});

  @override
  State<StatefulWidget> createState() => _ManHinhNhanVienPhucVuState();
}

class _ManHinhNhanVienPhucVuState extends State<ManHinhNhanVienPhucVu> {
  MenuItem? _selectedItem;
  TextEditingController _tableNumberController = TextEditingController();
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  final DatabaseReference order1Ref = FirebaseDatabase.instance.reference().child('order1');
  bool showNotifications = false;
  List<Map<String, dynamic>> notifications = [];
  int newOrderCount = 0;
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _scrollController = ScrollController();
    _scrollController.addListener(_saveScrollPosition);
    _listenForNewOrders();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _saveScrollPosition() {
    _scrollPosition = _scrollController.position.pixels;
  }

  void _listenForNewOrders() {
    order1Ref.onChildAdded.listen((event) {
      final newOrder = event.snapshot.value as Map<dynamic, dynamic>;
      if (newOrder['status'] == 'đang lên') {
        setState(() {
          notifications.insert(0, {
            'id': event.snapshot.key,
            'tableNumber': newOrder['tableNumber'] ?? 'Unknown',
            'itemName': newOrder['itemName'] ?? 'Unknown',
            'itemCount': newOrder['itemCount'] ?? 0,
            'seen1': newOrder['seen1'] ?? false,
            'status': newOrder['status'] ?? 'đang lên',
            'paymentStatus': newOrder['paymentStatus'] ?? 'chưa thanh toán',
          });
          if (newOrder['seen1'] != true) {
            newOrderCount++;
          }
        });
      }
    });

    order1Ref.onChildChanged.listen((event) {
      final updatedOrder = event.snapshot.value as Map<dynamic, dynamic>;
      if (updatedOrder['status'] == 'đã lên') {
        setState(() {
          notifications.removeWhere((notification) => notification['id'] == event.snapshot.key);
          newOrderCount = notifications.where((n) => !n['seen1']).length;
        });
      }
    });
  }

  void _handleNotificationTap(String orderId) {
    setState(() {
      final notification = notifications.firstWhere((n) => n['id'] == orderId);
      notification['seen1'] = true;
      newOrderCount = newOrderCount > 0 ? newOrderCount - 1 : 0;
    });

    order1Ref.child(orderId).update({'seen1': true}).then((_) {
      print('Đã cập nhật trạng thái seen1 của đơn hàng trên Realtime Database!');
    }).catchError((error) {
      print('Lỗi khi cập nhật trạng thái của đơn hàng: $error');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              _selectedItem = null;
              showNotifications = false;
            });
          },
          child: _selectedItem != null ? Text(_selectedItem!.name) : Text('Danh sách món ăn'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  setState(() {
                    showNotifications = !showNotifications;
                  });
                },
              ),
              if (newOrderCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '$newOrderCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Danh sách đơn hàng chờ'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DanhSachDonHangCho()));
              },
            ),
            ListTile(
              title: Text('Quản lý bàn'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QuanLyBanPage()));
              },
            ),
            ListTile(
              title: Text('Đổi mật khẩu'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage(role: 'waiter')));
              },
            ),
            ListTile(
              title: Text('Đăng xuất'),
              onTap: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
          ],
        ),
      ),
      body: showNotifications
          ? NotificationList(
        notifications: notifications,
        onNotificationTap: _handleNotificationTap,
      )
          : _selectedItem != null
          ? _buildOrderUI()
          : _buildMenuList(),
    );
  }

  Widget _buildMenuList() {
    return Column(
      children: [
        Expanded(
          child: MenuPage(
            scrollController: _scrollController,
            onItemTap: (MenuItem menu) {
              setState(() {
                _selectedItem = menu;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _tableNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Số bàn',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _confirmOrder();
                },
                child: Text('Xác nhận'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmOrder() {
    bool hasSelected = false;
    List<MenuItem> selectedItems = [];

    for (var menuItem in MenuItem.fooddata) {
      if (menuItem.count > 0) {
        hasSelected = true;
        selectedItems.add(menuItem);
      }
    }

    bool hasTableNumber = _tableNumberController.text.isNotEmpty;

    if (hasSelected && hasTableNumber) {
      String tableNumber = _tableNumberController.text;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Xác nhận đơn hàng'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Số bàn: $tableNumber'),
                  SizedBox(height: 10),
                  Text('Danh sách món đã chọn:'),
                  for (var item in selectedItems) Text('${item.name} - Số lượng: ${item.count}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Hủy'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendOrder(tableNumber, selectedItems);
                },
              ),
            ],
          );
        },
      );
    } else if (!hasSelected && !hasTableNumber) {
      _showErrorMessage('Vui lòng chọn món ăn và nhập số bàn.');
    } else if (!hasSelected) {
      _showErrorMessage('Vui lòng chọn món ăn.');
    } else if (!hasTableNumber) {
      _showErrorMessage('Vui lòng nhập số bàn.');
    }
  }

  void _sendOrder(String tableNumber, List<MenuItem> selectedItems) {
    setState(() {
      _selectedItem = null;
      _tableNumberController.clear();
    });

    for (var menuItem in selectedItems) {
      double itemPrice = menuItem.price;
      sendOrderToDatabase(tableNumber, menuItem.name, menuItem.count, itemPrice);
      menuItem.count = 0;
    }
  }

  void sendOrderToDatabase(String tableNumber, String itemName, int itemCount, double itemPrice) {
    DatabaseReference order1Ref = FirebaseDatabase.instance.reference().child('order1');


    order1Ref.push().set({
      'tableNumber': tableNumber,
      'itemName': itemName,
      'itemCount': itemCount,
      'itemPrice': itemPrice,
      'status': 'chưa lên',
      'paymentStatus': 'chưa thanh toán',
    }).then((_) {
      print('Dữ liệu order1 đã được gửi lên Realtime Database!');
      _showConfirmationMessage();
    }).catchError((error) {
      print('Lỗi khi gửi dữ liệu order1: $error');
    });
  }



  void _showConfirmationMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Text('Đã gửi đơn hàng!'),
        );
      },
    );

    Timer(Duration(milliseconds: 300), () {
      Navigator.of(context).pop();
    });
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderUI() {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(_selectedItem!.imageUrl.toString()),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _selectedItem!.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _selectedItem!.count += 1;
                  });
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.white,
              ),
              Text('${_selectedItem!.count}', style: TextStyle(fontSize: 60.0)),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (_selectedItem!.count > 0) {
                      _selectedItem!.count -= 1;
                    }
                  });
                },
                child: Icon(Icons.remove),
                backgroundColor: Colors.white,
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedItem = null;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.jumpTo(_scrollPosition);
              });
            },
            child: const Text('Quay lại danh sách món'),
          ),
        ],
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(String) onNotificationTap;

  NotificationList({required this.notifications, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        Color tileColor = notification['seen1'] ? Colors.white : Colors.lightBlueAccent;
        return ListTile(
          tileColor: tileColor,
          title: Text('Bàn ${notification['tableNumber']} - ${notification['itemName']}'),
          subtitle: Text('Số lượng: ${notification['itemCount']}'),
          onTap: () {
            onNotificationTap(notification['id']);
          },
        );
      },
    );
  }
}
