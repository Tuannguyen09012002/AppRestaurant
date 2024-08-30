import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:APP401/kitchen/history_screen.dart';
import 'package:APP401/services/change_password_screen.dart';

class ManHinhBep extends StatefulWidget {
  @override
  _ManHinhBepState createState() => _ManHinhBepState();
}

class _ManHinhBepState extends State<ManHinhBep> {
  final DatabaseReference order1Ref = FirebaseDatabase.instance.reference().child('order1');
  bool showNotifications = false;
  List<Map<String, dynamic>> notifications = [];
  int newOrderCount = 0;

  @override
  void initState() {
    super.initState();
    _listenForNewOrders();
  }

  void _listenForNewOrders() {
    order1Ref.onChildAdded.listen((event) {
      final newOrder = event.snapshot.value as Map<dynamic, dynamic>;

      if (newOrder['status'] == 'chưa lên') {
        setState(() {
          notifications.insert(0, {
            'id': event.snapshot.key,
            'tableNumber': newOrder['tableNumber'] ?? 'Unknown',
            'itemName': newOrder['itemName'] ?? 'Unknown',
            'itemCount': newOrder['itemCount'] ?? 0,
            'seen': newOrder['seen'] ?? false,
          });

          if (newOrder['seen'] != true) {
            newOrderCount++;
          }
        });
      }
    });

    order1Ref.onChildChanged.listen((event) {
      final updatedOrder = event.snapshot.value as Map<dynamic, dynamic>;

      if (updatedOrder['status'] == 'chưa lên') {
        setState(() {
          final index = notifications.indexWhere((n) => n['id'] == event.snapshot.key);
          if (index != -1) {
            notifications[index] = {
              'id': event.snapshot.key,
              'tableNumber': updatedOrder['tableNumber'] ?? 'Unknown',
              'itemName': updatedOrder['itemName'] ?? 'Unknown',
              'itemCount': updatedOrder['itemCount'] ?? 0,
              'seen': updatedOrder['seen'] ?? false,
            };
          } else {
            notifications.insert(0, {
              'id': event.snapshot.key,
              'tableNumber': updatedOrder['tableNumber'] ?? 'Unknown',
              'itemName': updatedOrder['itemName'] ?? 'Unknown',
              'itemCount': updatedOrder['itemCount'] ?? 0,
              'seen': updatedOrder['seen'] ?? false,
            });
          }

          newOrderCount = notifications.where((n) => n['seen'] != true).length;
        });
      }
    });
  }

  void markOrderAsInProgress(String orderId) {
    var now = DateTime.now();
    var formattedDate = DateFormat('yyyy-MM-dd').format(now);

    order1Ref.child(orderId).update({
      'status': 'đang lên',
      'completedAt': formattedDate,
    }).then((_) {
      _removeNotification(orderId);
    });
  }

  void _handleMenuOption(BuildContext context, String option) {
    switch (option) {
      case 'Lịch sử':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
        break;
      case 'Đổi mật khẩu':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangePasswordPage(role: 'kitchen')),
        );
        break;
      case 'Đăng xuất':
        Navigator.popUntil(context, ModalRoute.withName('/'));
        break;
    }
  }

  void _handleNotificationTap(String orderId) {
    setState(() {
      final notification = notifications.firstWhere((n) => n['id'] == orderId);
      notification['seen'] = true;
      newOrderCount = newOrderCount > 0 ? newOrderCount - 1 : 0;
    });

    order1Ref.child(orderId).update({'seen': true});
  }

  void _removeNotification(String orderId) {
    setState(() {
      notifications.removeWhere((notification) => notification['id'] == orderId);
      newOrderCount = notifications.where((n) => n['seen'] != true).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: GestureDetector(
          onTap: () {
            setState(() {
              showNotifications = false;
            });
          },
          child: const Text('Bếp', textAlign: TextAlign.center),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
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
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Lịch sử'),
              onTap: () {
                _handleMenuOption(context, 'Lịch sử');
              },
            ),
            ListTile(
              title: const Text('Đổi mật khẩu'),
              onTap: () {
                _handleMenuOption(context, 'Đổi mật khẩu');
              },
            ),
            ListTile(
              title: const Text('Đăng xuất'),
              onTap: () {
                _handleMenuOption(context, 'Đăng xuất');
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
          : StreamBuilder<DatabaseEvent>(
        stream: order1Ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Container());
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) {
            return Center(child: Container());
          }

          final sortedEntries = data.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          List<OrderItem> orderItems = sortedEntries
              .where((entry) => entry.value['status'] == 'chưa lên')
              .map((entry) {
            String key = entry.key;
            Map order = entry.value;
            return OrderItem(
              id: key,
              tableNumber: order['tableNumber'] ?? 'Unknown',
              itemName: order['itemName'] ?? 'Unknown',
              itemCount: order['itemCount'] ?? 0,
              onCompleted: () => markOrderAsInProgress(key),
              completedAt: order['completedAt'] ?? 'N/A',
            );
          }).toList();

          return ListView(
            children: orderItems,
          );
        },
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String id;
  final String tableNumber;
  final String itemName;
  final int itemCount;
  final String? completedAt;
  final VoidCallback onCompleted;

  OrderItem({
    required this.id,
    required this.tableNumber,
    required this.itemName,
    required this.itemCount,
    required this.completedAt,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('$itemName x$itemCount'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bàn: $tableNumber'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onCompleted,
          child: const Text('Hoàn thành'),
        ),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(String) onNotificationTap;

  NotificationList({
    required this.notifications,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: notifications.map((notification) {
          return Container(
            color: notification['seen'] ? Colors.white : Colors.blue[100],
            child: ListTile(
              title: Text(
                'Đơn hàng mới: ${notification['itemName']} x ${notification['itemCount']}',
                style: TextStyle(
                  color: notification['seen'] ? Colors.black : Colors.blue[900],
                ),
              ),
              subtitle: Text('Bàn: ${notification['tableNumber']}'),
              onTap: () {
                onNotificationTap(notification['id']);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
