import 'package:flutter/material.dart';
import 'package:app/presentation/pages/receipts/widgets/receipt_grid_item.dart';
import 'package:app/presentation/pages/receipts/widgets/receipt_image_viewer.dart';

class ReceiptsGalleryPage extends StatelessWidget {
  ReceiptsGalleryPage({super.key});

  final List<Map<String, dynamic>> receipts = [
    {
      'merchant': 'Imtiaz Super Market',
      'date': 'Oct 24, 2:30 PM',
      'amount': 4250.00,
      'imageUrl':
      'https://images.pexels.com/photos/5242813/pexels-photo-5242813.jpeg',
    },
    {
      'merchant': 'Gloria Jeans',
      'date': 'Oct 22, 9:15 AM',
      'amount': 1800.00,
      'imageUrl':
      'https://images.pexels.com/photos/3570240/pexels-photo-3570240.jpeg',
    },
    {
      'merchant': 'Shell Station F-10',
      'date': 'Oct 20, 6:45 PM',
      'amount': 5500.00,
      'imageUrl':
      'https://images.pexels.com/photos/5933209/pexels-photo-5933209.jpeg',
    },
    {
      'merchant': 'Outfitters',
      'date': 'Oct 18, 4:20 PM',
      'amount': 8990.00,
      'imageUrl':
      'https://images.pexels.com/photos/3570235/pexels-photo-3570235.jpeg',
    },
    {
      'merchant': 'Bakery & Co.',
      'date': 'Oct 16, 11:00 AM',
      'amount': 950.00,
      'imageUrl':
      'https://images.pexels.com/photos/14647295/pexels-photo-14647295.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Receipts Gallery',
          style: textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            color: colorScheme.onSurface,
            tooltip: 'Filter receipts',
            onPressed: () {
              // TODO: implement filtering logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: receipts.length,
          itemBuilder: (context, index) {
            final receipt = receipts[index];
            return ReceiptGridItem(
              merchant: receipt['merchant'],
              date: receipt['date'],
              amount: receipt['amount'],
              imageUrl: receipt['imageUrl'],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReceiptImageViewer(
                      imageUrl: receipt['imageUrl'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add a new receipt (open camera / file picker)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}