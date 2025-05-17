import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'food_order_page.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  List<dynamic> tables = [];

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  Future<void> fetchTables() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/tables'),
    );
    if (response.statusCode == 200) {
      setState(() {
        tables = json.decode(response.body);
      });
    } else {
      print('Lỗi khi tải danh sách bàn: ${response.body}');
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
      body: Padding(
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
                    if (!isUsing) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodOrderPage(tableId: tableId),
                        ),
                      );
                    }
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
                            color: isUsing ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (orders.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            orderSummary,
                            style: TextStyle(
                              color: isUsing ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tổng: ${totalPrice.toStringAsFixed(0)} VND',
                            style: TextStyle(
                              color: isUsing ? Colors.yellow[100] : Colors.red,
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
    );
  }
}
