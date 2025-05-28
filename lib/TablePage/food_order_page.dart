import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodOrderPage extends StatefulWidget {
  final String tableId;
  final Function() onOrderSubmitted;

  const FoodOrderPage({
    super.key,
    required this.tableId,
    required this.onOrderSubmitted,
  });

  @override
  State<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> foodItems = []; // Danh sách món ăn từ API
  List<Map<String, dynamic>> selectedFoods = []; // Danh sách món đã chọn
  List<Map<String, dynamic>> confirmedOrders =
      []; // Danh sách món đã được xác nhận
  bool isSubmitting = false; // Trạng thái đang gửi đơn hàng

  // Controller cho TabBar
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchFoodItems(); // Lấy danh sách món ăn khi trang khởi tạo
    fetchOrderedItems(); // Lấy danh sách đơn hàng đã đặt
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  // Giảm số lượng hoặc xóa món khỏi danh sách đã chọn
  void removeFromMenu(String foodId) {
    final index = selectedFoods.indexWhere((item) => item['foodId'] == foodId);

    if (index != -1) {
      setState(() {
        if (selectedFoods[index]['quantity'] > 1) {
          selectedFoods[index]['quantity'] -= 1;
        } else {
          selectedFoods.removeAt(index);
        }
      });
    }
  }

  // Tính tổng tiền
  double getTotalPrice() {
    double total = 0;
    for (var item in selectedFoods) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  // Tính tổng tiền cho đơn hàng đã xác nhận
  double getConfirmedTotalPrice() {
    double total = 0;
    for (var item in confirmedOrders) {
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

    setState(() {
      isSubmitting = true;
    });

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

    setState(() {
      isSubmitting = false;
    });

    if (allSuccess) {
      // Gọi callback để cập nhật lại danh sách bàn
      widget.onOrderSubmitted();

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gửi đơn hàng thành công! Bạn có thể tiếp tục đặt thêm món.',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        // Copy selected foods to confirmed orders before clearing
        for (var item in selectedFoods) {
          final existingIndex = confirmedOrders.indexWhere(
            (order) => order['foodId'] == item['foodId'],
          );
          if (existingIndex != -1) {
            confirmedOrders[existingIndex]['quantity'] += item['quantity'];
          } else {
            confirmedOrders.add(Map<String, dynamic>.from(item));
          }
        }

        selectedFoods.clear(); // Xóa danh sách món đã chọn
      });

      // Chuyển sang tab "Món đã xác nhận"
      _tabController.animateTo(1);

      // Sau khi gửi đơn hàng, lấy lại đơn hàng đã đặt để hiển thị
      fetchOrderedItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Một số món không gửi được!')),
      );
    }
  }

  // Lấy danh sách đơn hàng đã đặt từ server
  Future<void> fetchOrderedItems() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/orders?tableId=${widget.tableId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> orders = json.decode(response.body);

      setState(() {
        confirmedOrders =
            orders.map((order) {
              return {
                'foodId': order['foodId']['_id'], // Lưu ID của món ăn
                'quantity': order['quantity'],
                'name': order['foodId']['name'], // Lấy tên món ăn từ foodId
                'price': order['foodId']['price'], // Lấy giá món ăn từ foodId
              };
            }).toList();
      });
    } else {
      print('Lỗi khi lấy danh sách đơn hàng: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng - Bàn ${widget.tableId}'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Quay lại danh sách bàn',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thực đơn đã gọi'),
            Tab(text: 'Món đã xác nhận'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Màn hình gọi món
          _buildOrderingScreen(),

          // Tab 2: Màn hình xác nhận đơn hàng
          _buildConfirmedOrdersScreen(),
        ],
      ),
    );
  }

  // Widget cho màn hình gọi món
  Widget _buildOrderingScreen() {
    return Column(
      children: [
        Expanded(
          child:
              foodItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final food = foodItems[index];
                      // Tìm xem món này đã được chọn chưa
                      final selectedIndex = selectedFoods.indexWhere(
                        (item) => item['foodId'] == food['_id'],
                      );
                      final isSelected = selectedIndex != -1;
                      final quantity =
                          isSelected
                              ? selectedFoods[selectedIndex]['quantity']
                              : 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: ListTile(
                          title: Text(food['name']),
                          subtitle: Text('Giá: ${food['price']} VND'),
                          trailing:
                              isSelected
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed:
                                            () => removeFromMenu(food['_id']),
                                        color: Colors.red,
                                      ),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed: () => addToMenu(food),
                                        color: Colors.green,
                                      ),
                                    ],
                                  )
                                  : IconButton(
                                    icon: const Icon(Icons.add_shopping_cart),
                                    onPressed: () => addToMenu(food),
                                    color: Colors.blue,
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
              Container(
                height: selectedFoods.isEmpty ? 30 : 100,
                child:
                    selectedFoods.isEmpty
                        ? const Center(child: Text('Chưa có món nào được chọn'))
                        : ListView.builder(
                          itemCount: selectedFoods.length,
                          itemBuilder: (context, index) {
                            final item = selectedFoods[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item['name']} x${item['quantity']}',
                                    ),
                                  ),
                                  Text(
                                    '${(item['price'] * item['quantity']).toStringAsFixed(0)} VND',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
              const SizedBox(height: 10),
              Text(
                '🧾 Tổng tiền: ${getTotalPrice().toStringAsFixed(0)} VND',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : submitOrder,
                  icon:
                      isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send),
                  label: Text(isSubmitting ? 'Đang gửi...' : 'Gửi thực đơn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget cho màn hình xác nhận đơn hàng
  Widget _buildConfirmedOrdersScreen() {
    return Column(
      children: [
        Expanded(
          child:
              confirmedOrders.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Chưa có món nào được xác nhận',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => _tabController.animateTo(0),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Đặt món ngay'),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: confirmedOrders.length,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final item = confirmedOrders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Giá: ${item['price']} VND'),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'x${item['quantity']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
        Container(
          padding: const EdgeInsets.all(15),
          color: Colors.grey[200],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng thanh toán:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${getConfirmedTotalPrice().toStringAsFixed(0)} VND',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _tabController.animateTo(0),
                      icon: const Icon(Icons.add),
                      label: const Text('Đặt thêm món'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Xử lý thanh toán ở đây
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tính năng thanh toán đang phát triển',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Thanh toán'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
