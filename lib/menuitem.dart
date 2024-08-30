class MenuItem {
  String name;
  String imageUrl;
  int count;
  double price;


  MenuItem(this.name, this.imageUrl, {this.count = 0, required this.price});

  static List<MenuItem> fooddata = [
    MenuItem('CUA RANG ME', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/cuarangme.jpg?alt=media', price: 105000),
    MenuItem('Cua Xào Sốt Ớt Singapore', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/cuaxoasotot.jpg?alt=media', price: 200000),
    MenuItem('Tôm Mũ Ni Rang Me', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/tomhummunyrangme.jpg?alt=media', price: 150000),
    MenuItem('Tôm Hùm Rang Muối Xanh', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/tomhumrangmuoixanh.jpg?alt=media', price: 3000000),
    MenuItem('Tôm Hùm Rang Nướng Bơ tỏi', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/tomhumnuongbotoi.jpg?alt=media', price: 400000),
    MenuItem('Tôm Càng Quay Sốt Mặn', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/tomcangquaysotman.jpg?alt=media', price: 300000),
    MenuItem('Hàu Đút Lò Phô Mai', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/haunuongphomai.jpg?alt=media', price: 2000000),
    MenuItem('Bò Mỹ Sốt Nấm', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/bomysotnam.jpg?alt=media', price: 250000),
    MenuItem('Sườn Heo Nướng Sốt BBQ', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/suonheonuongbbq.jpg?alt=media', price: 200000),
    MenuItem('Gà Quay', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/gaquay.jpg?alt=media', price: 320000),
    MenuItem('Gỏi Bưởi Hải Sản', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/goibuoihaisan.jpg?alt=media', price: 500000),
    MenuItem('Bánh Canh Cua', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/banhcanhcua.jpg?alt=media', price: 200000),
    MenuItem('Bào Ngư Sốt Thịt Cua', 'https://firebasestorage.googleapis.com/v0/b/aaaa-3261d.appspot.com/o/baongu.jpg?alt=media', price: 250000),
  ];
}
