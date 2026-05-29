import 'package:flutter/material.dart';

class HomeFilterSheet extends StatefulWidget {
  final String selectedSort;

  final Function(String) onApply;

  const HomeFilterSheet({
    super.key,
    required this.selectedSort,
    required this.onApply,
  });

  @override
  State<HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<HomeFilterSheet> {
  late String tempSort;

  static const String sortLatest = 'latest';

  static const String sortPriceAsc = 'price_asc';

  static const String sortPriceDesc = 'price_desc';

  @override
  void initState() {
    super.initState();

    tempSort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          RadioListTile<String>(
            value: sortLatest,
            groupValue: tempSort,
            title: const Text('Latest'),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  tempSort = value;
                });
              }
            },
          ),

          RadioListTile<String>(
            value: sortPriceAsc,
            groupValue: tempSort,
            title: const Text('Price: Low to High'),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  tempSort = value;
                });
              }
            },
          ),

          RadioListTile<String>(
            value: sortPriceDesc,
            groupValue: tempSort,
            title: const Text('Price: High to Low'),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  tempSort = value;
                });
              }
            },
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    tempSort = sortLatest;
                  });
                },

                child: const Text('Reset'),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  widget.onApply(tempSort);
                },

                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
