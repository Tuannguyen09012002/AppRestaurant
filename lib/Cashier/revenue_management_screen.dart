import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'order.dart';

class RevenueManagementScreen extends StatefulWidget {
  @override
  _RevenueManagementScreenState createState() => _RevenueManagementScreenState();
}

class _RevenueManagementScreenState extends State<RevenueManagementScreen> {
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  double _totalRevenue = 0.0;
  List<Order> _orders = [];
  Map<DateTime, double> _dailyRevenue = {};
  Map<DateTime, List<Order>> _ordersByDate = {};

  @override
  void initState() {
    super.initState();
    _fetchRevenue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý doanh thu'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRevenueCard(),
                  if (_selectedDateRange != null) _buildDateRangeDisplay(),
                  if (_selectedDateRange != null) _buildRevenueChartOrMessage(),
                  if (_orders.isNotEmpty) _buildOrderDetailsByDate(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedDate = selectedDate;
                    _selectedDateRange = null;
                    _fetchRevenue();
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      _selectedDate == null || _isToday(_selectedDate!)
                          ? 'Hôm nay'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.white,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDateRange: _selectedDateRange,
                );
                if (picked != null) {
                  setState(() {
                    _selectedDateRange = picked;
                    _selectedDate = null;
                    _fetchRevenue();
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedDateRange == null
                          ? 'Khoảng'
                          : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Icon(Icons.filter_alt, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildRevenueCard() {
    return Card(
      color: Colors.blue.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng doanh thu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '$_totalRevenue VND',
              style: TextStyle(fontSize: 36, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        'Khoảng: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRevenueChartOrMessage() {
    if (_dailyRevenue.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      );
    } else {
      return _buildRevenueChart();
    }
  }

  Widget _buildRevenueChart() {
    if (_dailyRevenue.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      );
    }

    final maxRevenue = _dailyRevenue.values.reduce((a, b) => a > b ? a : b);
    final interval = (maxRevenue / 5).ceil().toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biểu đồ doanh thu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: _dailyRevenue.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key.millisecondsSinceEpoch,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blue,
                          width: 16,
                          borderRadius: BorderRadius.zero,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxRevenue,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value / 1000000).toStringAsFixed(1)}M', style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,  // Hiển thị tất cả các ngày
                        getTitlesWidget: (value, meta) {
                          DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(DateFormat('dd/MM').format(date)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        DateTime date = DateTime.fromMillisecondsSinceEpoch(group.x.toInt());
                        return BarTooltipItem(
                          '${DateFormat('dd/MM').format(date)}\n',
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${rod.toY} VND',
                              style: TextStyle(color: Colors.yellow),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsByDate() {
    return Expanded(
      child: ListView.builder(
        itemCount: _ordersByDate.keys.length,
        itemBuilder: (context, index) {
          DateTime date = _ordersByDate.keys.elementAt(index);
          List<Order> orders = _ordersByDate[date]!;
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngày: ${DateFormat('dd/MM/yyyy').format(date)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...ordersByTableEntries(date),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> ordersByTableEntries(DateTime date) {
    Map<String, List<Order>> ordersByTableForDate = {};
    _ordersByDate[date]!.forEach((order) {
      if (!ordersByTableForDate.containsKey(order.tableNumber)) {
        ordersByTableForDate[order.tableNumber] = [];
      }
      ordersByTableForDate[order.tableNumber]!.add(order);
    });

    return ordersByTableForDate.entries.map((entry) {
      String tableNumber = entry.key;
      List<Order> orders = entry.value;
      double tableTotal = orders.fold(
        0.0,
            (sum, order) => sum + (order.itemPrice * order.itemCount),
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bàn: $tableNumber',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...orders.map((order) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemName,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Số lượng: ${order.itemCount}  Giá: ${order.itemPrice} VND  Thành tiền: ${order.itemPrice * order.itemCount} VND',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
            Divider(),
            Text(
              'Tổng tiền: $tableTotal VND',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _fetchRevenue() async {
    double totalRevenue = 0.0;
    List<Order> orders = [];
    Map<DateTime, double> dailyRevenue = {};
    Map<DateTime, List<Order>> ordersByDate = {};

    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('order1');
    Query query = ordersRef;

    if (_selectedDate != null) {
      String selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      print('Selected Date: $selectedDateString'); // Log selected date
      query = ordersRef.orderByChild('paymentDate').equalTo(selectedDateString);
    } else if (_selectedDateRange != null) {
      print('Selected Date Range: ${_selectedDateRange!.start.toIso8601String()} - ${_selectedDateRange!.end.toIso8601String()}'); // Log selected date range
      query = ordersRef.orderByChild('paymentDate')
          .startAt(_selectedDateRange!.start.toIso8601String())
          .endAt(_selectedDateRange!.end.toIso8601String());
    }

    DatabaseEvent event = await query.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> ordersMap = event.snapshot.value as Map<dynamic, dynamic>;
      print('Orders Map: $ordersMap'); // Log orders map
      ordersMap.forEach((key, value) {
        Order order = Order.fromMap(key as String, Map<String, dynamic>.from(value));
        if (order.paymentStatus == 'đã thanh toán') {
          DateTime orderDate = DateTime.parse(order.paymentDate!);

          if ((_selectedDate != null && _isSameDay(orderDate, _selectedDate!)) ||
              (_selectedDateRange != null &&
                  orderDate.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
                  orderDate.isBefore(_selectedDateRange!.end.add(Duration(days: 1))))) {
            totalRevenue += order.itemPrice * order.itemCount;
            orders.add(order);

            DateTime day = DateTime(orderDate.year, orderDate.month, orderDate.day);
            if (!dailyRevenue.containsKey(day)) {
              dailyRevenue[day] = 0.0;
            }
            dailyRevenue[day] = dailyRevenue[day]! + (order.itemPrice * order.itemCount);

            if (!ordersByDate.containsKey(day)) {
              ordersByDate[day] = [];
            }
            ordersByDate[day]!.add(order);
          }
        }
      });
    } else {
      print('No data found');
    }

    setState(() {
      _totalRevenue = totalRevenue;
      _orders = orders;
      _dailyRevenue = dailyRevenue;
      _ordersByDate = ordersByDate;
    });
  }


  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
