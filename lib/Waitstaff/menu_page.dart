import 'package:flutter/material.dart';
import '../menuitem.dart';

class MenuPage extends StatefulWidget {
  final Function(MenuItem) onItemTap;
  final ScrollController scrollController;

  MenuPage({required this.onItemTap, required this.scrollController});

  @override
  State<StatefulWidget> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final menus = MenuItem.fooddata;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: menus.length,
      itemBuilder: (BuildContext context, int index) {
        return buildRow(menus[index]);
      },
    );
  }

  Widget buildRow(MenuItem menu) {
    return InkWell(
      onTap: () {
        widget.onItemTap(menu);
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.network(menu.imageUrl),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    Text(
                      menu.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'số lượng: ${menu.count}',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    Text(
                      'Giá: ${menu.price.toStringAsFixed(2)} ₫',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
