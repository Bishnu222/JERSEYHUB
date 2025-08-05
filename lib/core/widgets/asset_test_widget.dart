import 'package:flutter/material.dart';

class AssetTestWidget extends StatelessWidget {
  const AssetTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> testAssets = [
      'assets/images/Real_Madrid.png',
      'assets/images/Real_Madrid_Away_2019-20.png',
      'assets/images/Liverpool.png',
      'assets/images/Liverpool_FC_Home_Jersey.webp',
      'assets/images/Barcelona.png',
      'assets/images/Barcelona_Away_jersey.png',
      'assets/images/Manchester_United.png',
      'assets/images/Manchester_United_FC_Jersey.png',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Asset Test')),
      body: ListView.builder(
        itemCount: testAssets.length,
        itemBuilder: (context, index) {
          final asset = testAssets[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text('Testing: $asset'),
                SizedBox(
                  height: 200,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Asset test failed for $asset: $error');
                      return Container(
                        color: Colors.red[100],
                        child: Center(child: Text('Failed: $asset\n$error')),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
