import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class CarCardShimmer extends StatelessWidget {
  const CarCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Container(height: 16, width: 150, color: Colors.white),
              const SizedBox(height: 10),

              // Chips
              Wrap(
                spacing: 8,
                children: List.generate(
                  4,
                  (index) =>
                      Container(height: 20, width: 60, color: Colors.white),
                ),
              ),

              const SizedBox(height: 12),

              // Image
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.white,
              ),

              const SizedBox(height: 12),

              // Dealer text
              Container(height: 14, width: 200, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
