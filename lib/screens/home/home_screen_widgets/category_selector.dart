import 'package:flutter/material.dart';
import '../../../constants/tap_feedback_helpers.dart';

class CategorySelector extends StatelessWidget {
  final List<String> allCategories;
  final int selectedCategory;
  final Function(int) onCategorySelected;
  final VoidCallback onAddCategory;

  const CategorySelector({
    super.key,
    required this.allCategories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length + 1,
        itemBuilder: (context, index) {
          if (index == allCategories.length) {
            return TapFeedbackHelpers.feedbackChip(
              context: context,
              onTap: onAddCategory,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+ Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              margin: const EdgeInsets.only(right: 12),
            );
          }

          final isSelected = index == selectedCategory;
          return GestureDetector(
            onTap: () => onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF7DF27)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                allCategories[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}