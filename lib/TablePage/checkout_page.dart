// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// class CheckoutPage extends StatefulWidget {
//   final String tableId;
//   final String tableName;

//   const CheckoutPage({
//     super.key,
//     required this.tableId,
//     required this.tableName,
//   });

//   @override
//   State<CheckoutPage> createState() => _CheckoutPageState();
// }

// class _CheckoutPageState extends State<CheckoutPage> {
//   List<dynamic> orders = [];
//   bool isLoading = true;
//   double totalAmount = 0;
//   final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
//   final TextEditingController discountController = TextEditingController();
//   double discountAmount = 0;
//   String paymentMethod = 'Tiền mặt';

//   @override
//   void initState() {
//     super.initState();
//     fetchOrders();
//   }

//   Future<void> fetchOrders() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:3000/api/orders/table/${widget.tableId}'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           orders = data;
//           calculateTotal();
//           isLoading = false;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Lỗi khi tải đơn hàng: ${response.body}')),
//         );
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Không thể kết nối đến máy chủ: $e')),
//       );
//       setState(() => isLoading = false);
//     }
//   }

//   void calculateTotal() {
//     double total = 0;
//     for (var order in orders) {
//       total += order['food']['price'] * order['quantity'];
//     }
//     totalAmount = total;
//   }

//   void applyDiscount() {
//     final discount = double.tryParse(discountController.text) ?? 0;
//     if (discount > 100) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Giảm giá không thể vượt quá 100%')),
//       );
//       return;
//     }
//     setState(() {
//       discountAmount = (totalAmount * discount) / 100;
//     });
//   }

//   Future<void> processPayment() async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:3000/api/bills'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'tableId': widget.tableId,
//           'totalAmount': totalAmount - discountAmount,
//           'discount': discountAmount,
//           'paymentMethod': paymentMethod,
//           'items': orders.map((order) => {
//             'foodId': order['food']['_id'],
//             'name': order['food']['name'],
//             'price': order['food']['price'],
//             'quantity': order['quantity'],
//           }).toList(),
//         }),
//       );

//       if (response.statusCode == 201) {
//         await http.put(
//           Uri.parse('http://localhost:3000/api/tables/${widget.tableId}'),
//           headers: {'Content-Type': 'application/json'},
//           body: json.encode({
//             'isUsing': false,
//             'totalPrice': 0,
//             'timeUsed': 0,
//           }),
//         );

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Thanh toán thành công!')),
//         );

//         Future.delayed(const Duration(seconds: 2), () {
//           Navigator.pop(context, true);
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Lỗi khi thanh toán: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Không thể kết nối đến máy chủ: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final finalAmount = totalAmount - discountAmount;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Thanh toán - ${widget.tableName}'),
//         backgroundColor: Colors.orange,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // LEFT: Order List
//                   Expanded(
//                     flex: 3,
//                     child: Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Hóa đơn thanh toán',
//                                 style: Theme.of(context).textTheme.headlineSmall),
//                             const SizedBox(height: 8),
//                             Text('Bàn: ${widget.tableName}'),
//                             Text('Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
//                             const Divider(),
//                             Expanded(
//                               child: ListView.builder(
//                                 itemCount: orders.length,
//                                 itemBuilder: (context, index) {
//                                   final order = orders[index];
//                                   final name = order['food']['name'];
//                                   final price = order['food']['price'];
//                                   final qty = order['quantity'];
//                                   final itemTotal = price * qty;
//                                   return ListTile(
//                                     title: Text(name),
//                                     subtitle: Text('${currencyFormat.format(price)} x $qty'),
//                                     trailing: Text(
//                                       currencyFormat.format(itemTotal),
//                                       style: const TextStyle(fontWeight: FontWeight.bold),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                             const Divider(),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Tổng tiền:',
//                                     style: TextStyle(fontWeight: FontWeight.bold)),
//                                 Text(currencyFormat.format(totalAmount),
//                                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                             if (discountAmount > 0)
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text('Giảm giá:',
//                                       style: TextStyle(color: Colors.green)),
//                                   Text('- ${currencyFormat.format(discountAmount)}',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold, color: Colors.green)),
//                                 ],
//                               ),
//                             const SizedBox(height: 8),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Thanh toán:',
//                                     style: TextStyle(
//                                         fontSize: 18, fontWeight: FontWeight.bold)),
//                                 Text(currencyFormat.format(finalAmount),
//                                     style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.red)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // RIGHT: Payment Panel
//                   Expanded(
//                     flex: 2,
//                     child: Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Thanh toán',
//                                 style: Theme.of(context).textTheme.headlineSmall),
//                             const SizedBox(height: 16),
//                             const Text('Giảm giá (%):',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     controller: discountController,
//                                     keyboardType: TextInputType.number,
//                                     decoration: const InputDecoration(
//                                       border: OutlineInputBorder(),
//                                       hintText: '0',
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 ElevatedButton(
//                                   onPressed: applyDiscount,
//                                   child: const Text('Áp dụng'),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             const Text('Phương thức thanh toán:',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 8),
//                             DropdownButtonFormField<String>(
//                               value: paymentMethod,
//                               decoration: const InputDecoration(border: OutlineInputBorder()),
//                               items: const [
//                                 DropdownMenuItem(value: 'Tiền mặt', child: Text('Tiền mặt')),
//                                 DropdownMenuItem(value: 'Thẻ ngân hàng', child: Text('Thẻ ngân hàng')),
//                                 DropdownMenuItem(value: 'Momo', child: Text('Momo')),
//                                 DropdownMenuItem(value: 'VNPay', child: Text('VNPay')),
//                               ],
//                               onChanged: (value) {
//                                 setState(() {
//                                   paymentMethod = value!;
//                                 });
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             const Spacer(),
//                             SizedBox(
//                               width: double.infinity,
//                               height: 50,
//                               child: ElevatedButton(
//                                 onPressed: orders.isEmpty ? null : processPayment,
//                                 style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//                                 child: const Text(
//                                   'XÁC NHẬN THANH TOÁN',
//                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             SizedBox(
//                               width: double.infinity,
//                               height: 50,
//                               child: OutlinedButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: const Text(
//                                   'HỦY',
//                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
