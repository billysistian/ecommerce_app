import 'package:flutter/material.dart';
import '../../../cart/data/services/cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? product;
  int qty = 1;
  String? selectedColorId; // Untuk menyimpan id warna yang dipilih
  String? selectedSizeId; // Untuk menyimpan id size yang dipilih
  PageController? _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    _pageController = PageController();

    if (product?['color'] is Map && product!['color']['id'] != null) {
      selectedColorId = product!['color']['id'].toString();
    }
    if (product?['size'] is Map && product!['size']['id'] != null) {
      selectedSizeId = product!['size']['id'].toString();
    }

    final firstVariant = _firstVariant(product);
    if (firstVariant != null) {
      selectedColorId ??= firstVariant['color']?['id']?.toString();
      selectedSizeId ??= firstVariant['size']?['id']?.toString();
    }

    if (selectedColorId == null && _colorOptions.isNotEmpty) {
      selectedColorId = _colorOptions.first['id']?.toString();
    }
    if (selectedSizeId == null && _sizeOptions.isNotEmpty) {
      selectedSizeId = _sizeOptions.first['id']?.toString();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  List<String> get _imageUrls {
    final urls = <String>{};
    final thumb = product?['thumbnail_url']?.toString();
    if (thumb != null && thumb.isNotEmpty) {
      urls.add(thumb);
    }
    for (final variant in _variants) {
      final image = variant['image_url']?.toString();
      if (image != null && image.isNotEmpty) {
        urls.add(image);
      }
    }
    return urls.isNotEmpty
        ? urls.toList()
        : ['https://via.placeholder.com/300'];
  }

  String get _categoryName {
    return product?['category']?['name']?.toString() ?? 'Category';
  }

  List<Map<String, dynamic>> get _variants {
    final variants = product?['variants'];
    if (variants is List) {
      return variants
          .map((variant) {
            if (variant is Map<String, dynamic>) {
              return Map<String, dynamic>.from(variant);
            }
            if (variant is Map) {
              return Map<String, dynamic>.from(variant);
            }
            return <String, dynamic>{};
          })
          .where((variant) => variant.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic>? _firstVariant(Map<String, dynamic>? product) {
    final variants = product?['variants'];
    if (variants is List && variants.isNotEmpty) {
      final first = variants.first;
      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }
    }
    return null;
  }

  Map<String, dynamic>? _variantFor({String? colorId, String? sizeId}) {
    for (final variant in _variants) {
      final color = variant['color'];
      final size = variant['size'];

      final matchesColor =
          colorId == null ||
          (color is Map && color['id']?.toString() == colorId);
      final matchesSize =
          sizeId == null || (size is Map && size['id']?.toString() == sizeId);

      if (matchesColor && matchesSize) {
        return variant;
      }
    }
    return null;
  }

  void _selectColor(String id) {
    setState(() {
      selectedColorId = id;
      if (selectedSizeId != null &&
          _variantFor(colorId: selectedColorId, sizeId: selectedSizeId) ==
              null) {
        selectedSizeId = null;
      }
    });
  }

  void _selectSize(String id) {
    setState(() {
      selectedSizeId = id;
      if (selectedColorId != null &&
          _variantFor(colorId: selectedColorId, sizeId: selectedSizeId) ==
              null) {
        selectedColorId = null;
      }
    });
  }

  Map<String, dynamic>? get _currentVariant {
    if (selectedColorId != null && selectedSizeId != null) {
      return _variantFor(colorId: selectedColorId, sizeId: selectedSizeId) ??
          _variantFor(colorId: selectedColorId) ??
          _variantFor(sizeId: selectedSizeId);
    }
    if (selectedColorId != null) {
      return _variantFor(colorId: selectedColorId);
    }
    if (selectedSizeId != null) {
      return _variantFor(sizeId: selectedSizeId);
    }
    return _firstVariant(product);
  }

  Future<void> _addToCart() async {
    final variant = _currentVariant;
    if (variant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a variant')),
      );
      return;
    }

    final variantId = variant['id'];
    if (variantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid variant')),
      );
      return;
    }

    try {
      await CartService.addToCart(
        productVariantId: int.parse(variantId.toString()),
        qty: qty,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to cart'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _colorOptions {
    final colors = _variants
        .map((variant) => variant['color'])
        .whereType<Map<String, dynamic>>()
        .where((color) => color['id'] != null)
        .map((color) => Map<String, dynamic>.from(color))
        .toList();

    return _uniqueItemsById(colors);
  }

  List<Map<String, dynamic>> get _sizeOptions {
    final sizes = _variants
        .where(
          (variant) =>
              selectedColorId == null ||
              (variant['color'] is Map &&
                  variant['color']['id']?.toString() == selectedColorId),
        )
        .map((variant) => variant['size'])
        .whereType<Map<String, dynamic>>()
        .where((size) => size['id'] != null)
        .map((size) => Map<String, dynamic>.from(size))
        .toList();

    return _uniqueItemsById(sizes);
  }

  List<Map<String, dynamic>> _uniqueItemsById(
    List<Map<String, dynamic>> items,
  ) {
    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final item in items) {
      final id = item['id']?.toString();
      if (id == null || seen.contains(id)) continue;
      seen.add(id);
      unique.add(item);
    }
    return unique;
  }

  String get _priceString {
    return _currentVariant?['price']?.toString() ??
        product?['price']?.toString() ??
        '0';
  }

  int get _stock {
    return int.tryParse(
          _currentVariant?['stock']?.toString() ??
              product?['stock']?.toString() ??
              '0',
        ) ??
        0;
  }

  String get _description {
    final desc = product?['description']?.toString();
    if (desc == null || desc == '-' || desc.isEmpty) {
      return 'No description available for this product.';
    }
    return desc;
  }

  // Fungsi helper untuk mengubah hex code menjadi object Color
  Color hexToColor(String hexString) {
    var hexColor = hexString.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Tambahkan opacity 100% jika belum ada
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Colors.grey; // Default color jika format salah
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Mendapatkan status stock
    final int stock = _stock;
    final bool isInStock = stock > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE SECTION (with yellow background per design)
                Container(
                  width: double.infinity,
                  height: 400,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFCC00), // Yellow background from design
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Main Product Image
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: _imageUrls.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              _imageUrls[index],
                              height: 250,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: Colors.black26,
                                  ),
                            );
                          },
                        ),

                        // Top Bar Actions
                        Positioned(
                          top: 10,
                          left: 20,
                          right: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              circleButton(
                                Icons.arrow_back,
                                () => Navigator.pop(context),
                              ),
                              Row(
                                children: [
                                  circleButton(Icons.share_outlined, () {}),
                                  const SizedBox(width: 12),
                                  circleButton(
                                    Icons.favorite,
                                    () {},
                                    iconColor: Colors.red,
                                  ), // Filled red heart
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Carousel Indicator
                        Positioned(
                          bottom: 30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                _imageUrls.length,
                                (index) =>
                                    _buildDot(index == _currentImageIndex),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// DETAILS SECTION
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Label
                      Text(
                        _categoryName.toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Product Title
                      Text(
                        product!['name'],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating & Stock Row
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          const Text(
                            "4.9", // Mock
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "1,248 Reviews", // Mock
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const Spacer(),
                          // Dinamis Stock Info
                          Text(
                            isInStock ? "In Stock ($stock)" : "Out of Stock",
                            style: TextStyle(
                              color: isInStock ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Price & Delivery Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price Column (Expanded to avoid overflow)
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  children: [
                                    Text(
                                      "Rp ${double.parse(_priceString).toInt()}",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Mock old price
                                    Text(
                                      "Rp ${(double.parse(_priceString) * 1.15).toInt()}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Or Rp ${(double.parse(_priceString) / 6).toInt()}/mo for 6 months",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Delivery Info Box (Flexible to adapt)
                          Flexible(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_shipping,
                                      color: Colors.blue.shade700,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Flexible(
                                      child: Text(
                                        "Free Delivery",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Arrives by Tue, Oct 24", // Mock Date
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      /// DYNAMIC COLORS SELECTION
                      if (_colorOptions.isNotEmpty) ...[
                        const Text(
                          "Choose Color",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _colorOptions.map((color) {
                            return _buildColorChip(
                              id: color['id'].toString(),
                              name: color['name'],
                              hexCode: color['code'],
                              isSelected:
                                  selectedColorId == color['id'].toString(),
                              onTap: () => _selectColor(color['id'].toString()),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],

                      /// DYNAMIC SIZE SELECTION
                      if (_sizeOptions.isNotEmpty) ...[
                        const Text(
                          "Choose Size",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _sizeOptions.map((size) {
                            return _buildSizeChip(
                              id: size['id'].toString(),
                              name: size['name'],
                              isSelected:
                                  selectedSizeId == size['id'].toString(),
                              onTap: () => _selectSize(size['id'].toString()),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],

                      /// DESCRIPTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "View More",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// BOTTOM ACTION BAR (Sticky)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // QTY Selector
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (qty > 1) setState(() => qty--);
                          },
                          icon: const Icon(Icons.remove, size: 20),
                        ),
                        Text(
                          "$qty",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (qty < stock) {
                              setState(() => qty++);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Maximum stock reached'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Add to Cart Button
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: isInStock
                            ? _addToCart
                            : null, // Disable jika habis
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isInStock ? "Add To Cart" : "Out of Stock",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget builder for Color Chip
  Widget _buildColorChip({
    required String id,
    required String name,
    required String hexCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color chipColor = hexToColor(hexCode);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 0.5,
                ), // Supaya warna putih tetap kelihatan batasnya
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget builder for Size Chip
  Widget _buildSizeChip({
    required String id,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  // Helper function for top buttons
  Widget circleButton(
    IconData icon,
    VoidCallback onTap, {
    Color iconColor = Colors.black87,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  // Helper for carousel dots
  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
