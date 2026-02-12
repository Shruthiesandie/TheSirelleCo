import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_controllers.dart';
import '../config/api.dart';

class OrderController {
  /// 🔥 Sends cart items to backend and creates order
  static Future<String?> createOrder({
    required String paymentMethod,
    required String address,
    required double total,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Get items from cart controller
      final items = CartController.items.value;

      final body = {
        "user_id": uid,
        "payment_method": paymentMethod,
        "address": address,
        "total": total,
        "items": items.map((e) {
          final item = e as dynamic;
          return {
            "product_id": item.product.productId,
            "product_name": item.product.name,
            "price": item.product.price,
            "quantity": item.quantity ?? 1,
          };
        }).toList(),
      };

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/create-order"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("Create Order Status: ${response.statusCode}");
      print("Create Order Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["order_id"]; // 🔥 return order id from backend
      }

      return null;
    } catch (e) {
      print("OrderController Error: $e");
      return null;
    }
  }
}