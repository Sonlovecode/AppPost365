import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'food_order_page.dart';
import 'checkout_page.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  List<dynamic> tables = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  Future<void> fetchTables() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/tables'),
    );

    if (response.statusCode == 200) {
      setState(() {
        tables = json.decode(response.body);
        isLoading = false;
      });
    } else {
      print('Lỗi khi tải danh sách bàn: ${response.body}');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm cập nhật trạng thái isUsing của bàn
  Future<void> updateTableStatus(String tableId, bool isUsing) async {
    // Thử sử dụng PUT thay vì PATCH
    final response = await http.put(
      Uri.parse('http://localhost:3000/api/tables/$tableId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isUsing': isUsing}),
    );

    if (response.statusCode == 200) {
      fetchTables(); // Tải lại danh sách bàn sau khi cập nhật
    } else {
      print('Lỗi khi cập nhật trạng thái bàn: ${response.body}');

      // Nếu PUT không hoạt động, chúng ta cần làm mới danh sách bàn để đảm bảo hiển thị dữ liệu mới nhất
      // sau khi thêm đơn hàng mới
      fetchTables();
    }
  }

  double calculateTotal(List<dynamic> orders) {
    double total = 0;
    for (var order in orders) {
      if (order['food'] != null && order['food']['price'] != null) {
        total += order['food']['price'] * order['quantity'];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhân viên order'),
        backgroundColor: Colors.orange,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children:
                      tables.map((table) {
                        final isUsing = table['isUsing'];
                        final tableName = table['name'];
                        final tableId = table['_id'];
                        final orders = table['orders'] ?? [];

                        final totalPrice = calculateTotal(orders);
                        final orderSummary = orders
                            .map<String>((order) {
                              return '${order['food']['name']} x${order['quantity']}';
                            })
                            .join('\n');

                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder:
                                  (context) => Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Bàn $tableName',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => FoodOrderPage(
                                                      tableId: tableId,
                                                      onOrderSubmitted: () {
                                                        // Cập nhật trạng thái bàn thành 'đang sử dụng' và tải lại danh sách
                                                        updateTableStatus(
                                                          tableId,
                                                          true,
                                                        );
                                                      },
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.restaurant_menu,
                                          ),
                                          label: const Text('Đặt món'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                          ),
                                        ),
                                        if (isUsing) ...[
                                          const SizedBox(height: 8),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              // Thêm chức năng thanh toán ở đây
                                              // Navigate to CheckoutPage
                                              Navigator.pop(context);
                                              // Giả sử bạn đã có CheckoutPage
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => CheckoutPage(tableId: tableId),
                                              //   ),
                                              // );
                                            },
                                            icon: const Icon(Icons.payment),
                                            label: const Text('Thanh toán'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            // Thêm chức năng làm mới bàn khi cần
                                            fetchTables();
                                          },
                                          child: const Text('Đóng'),
                                        ),
                                      ],
                                    ),
                                  ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isUsing ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tableName,
                                  style: TextStyle(
                                    color:
                                        isUsing ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (orders.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        orderSummary,
                                        style: TextStyle(
                                          color:
                                              isUsing
                                                  ? Colors.white
                                                  : Colors.black87,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tổng: ${totalPrice.toStringAsFixed(0)} VND',
                                    style: TextStyle(
                                      color:
                                          isUsing
                                              ? Colors.yellow[100]
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchTables,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
