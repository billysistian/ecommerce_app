import 'package:flutter/material.dart';
import '../../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, dynamic>? cart;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);
    final data = await CartService.getCart();
    if (mounted) {
      setState(() {
        cart = data;
        isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(int cartItemId, int newQty) async {
    if (newQty < 1) return;
    
    try {
      await CartService.updateCartItem(
        cartItemId: cartItemId,
        qty: newQty,
      );
      await _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity: $e')),
        );
      }
    }
  }

  Future<void> _removeItem(int cartItemId) async {
    try {
      await CartService.removeCartItem(cartItemId);
      await _loadCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $e')),
        );
      }
    }
  }

  List<dynamic> get _items {
    if (cart == null) return [];
    final items = cart!['items'];
    if (items is List) return items;
    return [];
  }

  double get _totalPrice {
    double total = 0;
    for (final item in _items) {
      if (item is Map) {
        final subtotal = double.tryParse(item['subtotal']?.toString() ?? '0') ?? 0;
        total += subtotal;
      }
    }
    return total;
  }

  int get _totalItems {
    int total = 0;
    for (final item in _items) {
      if (item is Map) {
        final qty = int.tryParse(item['qty']?.toString() ?? '0') ?? 0;
        total += qty;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () async {
                // Clear all items - you might want to add a confirmation dialog
                for (final item in _items) {
                  if (item is Map && item['id'] != null) {
                    await CartService.removeCartItem(item['id']);
                  }
                }
                await _loadCart();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmptyCart()
              : _buildCartList(),
      bottomNavigationBar: _items.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = _items[index];
          if (item is! Map) return const SizedBox();

          final variant = item['variant'];
          if (variant is! Map) return const SizedBox();

          final product = variant['product'];
          final color = variant['color'];
          final size = variant['size'];

          final imageUrl = variant['image_url']?.toString() ?? 
                          product?['thumbnail_url']?.toString() ?? 
                          'https://via.placeholder.com/100';
          
          final productName = product?['name']?.toString() ?? 'Unknown Product';
          final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
          final qty = int.tryParse(item['qty']?.toString() ?? '1') ?? 1;
          final subtotal = double.tryParse(item['subtotal']?.toString() ?? '0') ?? 0;
          final cartItemId = item['id'];

          final colorName = color?['name']?.toString() ?? '';
          final sizeName = size?['name']?.toString() ?? '';

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (colorName.isNotEmpty || sizeName.isNotEmpty)
                          Text(
                            '${colorName.isNotEmpty ? colorName : ''}${colorName.isNotEmpty && sizeName.isNotEmpty ? ' / ' : ''}${sizeName.isNotEmpty ? sizeName : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${price.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quantity Controls
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: qty > 1
                                  ? () => _updateQuantity(cartItemId, qty - 1)
                                  : null,
                              icon: const Icon(Icons.remove, size: 18),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                '$qty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _updateQuantity(cartItemId, qty + 1),
                              icon: const Icon(Icons.add, size: 18),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Remove Button
                      GestureDetector(
                        onTap: () => _removeItem(cartItemId),
                        child: const Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total ($_totalItems items)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Rp ${_totalPrice.toInt()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Navigate to checkout
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checkout feature coming soon')),
                  );
                },
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
