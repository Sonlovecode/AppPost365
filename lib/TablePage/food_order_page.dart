import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodOrderPage extends StatefulWidget {
  final String tableId; // ID bàn được truyền từ TablePage

  const FoodOrderPage({super.key, required this.tableId});

  @override
  State<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage> {
  List<dynamic> foodItems = []; // Danh sách món ăn từ API
  List<Map<String, dynamic>> selectedFoods = []; // Danh sách món đã chọn

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  // Lấy danh sách món ăn từ API
  Future<void> fetchFoodItems() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/food-items'),
    );
    if (response.statusCode == 200) {
      setState(() {
        foodItems = json.decode(response.body);
      });
    } else {
      print('Lỗi khi tải danh sách món ăn: ${response.body}');
    }
  }

  // Thêm món vào danh sách đã chọn hoặc tăng số lượng
  void addToMenu(Map<String, dynamic> food) {
    final index = selectedFoods.indexWhere(
      (item) => item['foodId'] == food['_id'],
    );
    setState(() {
      if (index != -1) {
        selectedFoods[index]['quantity'] += 1;
      } else {
        selectedFoods.add({
          'foodId': food['_id'],
          'name': food['name'],
          'price': food['price'],
          'quantity': 1,
        });
      }
    });
  }

  // Tính tổng tiền
  double getTotalPrice() {
    double total = 0;
    for (var item in selectedFoods) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  // Gửi tất cả món đã chọn lên server
  Future<void> submitOrder() async {
    if (selectedFoods.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn chưa chọn món nào!')));
      return;
    }

    bool allSuccess = true;

    for (var item in selectedFoods) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tableId': widget.tableId,
          'foodId': item['foodId'],
          'quantity': item['quantity'],
        }),
      );

      if (response.statusCode != 201) {
        allSuccess = false;
        print('Lỗi đặt món: ${response.body}');
      }
    }

    if (allSuccess) {
      setState(() {
        selectedFoods.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gửi đơn hàng thành công!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Một số món không gửi được!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt món'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final food = foodItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    title: Text(food['name']),
                    subtitle: Text('Giá: ${food['price']} VND'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => addToMenu(food),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📝 Thực đơn đã chọn:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                ...selectedFoods.map(
                  (item) => Text(
                    '${item['name']} x${item['quantity']} = ${item['price'] * item['quantity']} VND',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '🧾 Tổng tiền: ${getTotalPrice().toStringAsFixed(0)} VND',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: submitOrder,
                  icon: const Icon(Icons.send),
                  label: const Text('Gửi đơn hàng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
