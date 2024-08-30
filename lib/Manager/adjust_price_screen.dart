import 'package:flutter/material.dart';
import '../menuitem.dart';

class AdjustPriceScreen extends StatefulWidget {
  @override
  _AdjustPriceScreenState createState() => _AdjustPriceScreenState();
}

class _AdjustPriceScreenState extends State<AdjustPriceScreen> {
  final List<MenuItem> menus = MenuItem.fooddata;
  MenuItem? _selectedItem;
  ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: _selectedItem == null,
        title: const Center(child: Text('Chỉnh giá món ăn')),
      ),
      body: _selectedItem == null ? _buildListView() : _buildDetailView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: menus.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _scrollPosition = _scrollController.position.pixels;
              _selectedItem = menus[index];
            });
          },
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: Image.network(menus[index].imageUrl),
              title: Center(child: Text(menus[index].name)),
              subtitle: Center(child: Text('Giá: ${menus[index].price.toStringAsFixed(2)} VND')),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailView() {
    TextEditingController priceController = TextEditingController(text: _selectedItem!.price.toString());

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(_selectedItem!.imageUrl),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                _selectedItem!.name,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Giá: '),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Nhập giá mới',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    double newPrice = double.tryParse(priceController.text) ?? _selectedItem!.price;
                    _updatePrice(_selectedItem!, newPrice);
                  },
                ),
              ],
            ),
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

  void _updatePrice(MenuItem menu, double newPrice) {
    setState(() {
      menu.price = newPrice;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Giá đã được cập nhật thành công!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
