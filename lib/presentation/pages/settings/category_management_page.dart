import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';
import '../../../domain/entities/category.dart';
import '../../../config/themes/app_colors.dart';

class CategoryManagementPage extends StatelessWidget {
  final CategoryType type;
  final bool showAppBar;
  const CategoryManagementPage({
    super.key,
    this.type = CategoryType.expense,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : const Color(0xFF101828),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                type == CategoryType.expense
                    ? 'Expense Categories'
                    : 'Income Categories',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.restart_alt_rounded,
                    color: isDark ? Colors.white : const Color(0xFF101828),
                  ),
                  tooltip: 'Reset to Defaults',
                  onPressed: () {
                    // Confirm Reset
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Reset Categories?"),
                        content: const Text(
                          "This will delete all custom categories and restore defaults. This cannot be undone.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<CategoryBloc>().add(
                                    ResetCategoriesRequested(),
                                  );
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              "Reset",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state.status == CategoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CategoryStatus.error) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          }

          final categories = state.categories.where((c) => c.type == type).toList();

          if (categories.isEmpty) {
            return Center(
              child: Text(
                "No categories found.",
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, index) {
              final cat = categories[index];
              final iconCode = int.tryParse(cat.iconCodePoint.replaceFirst('0x', ''), radix: 16) ?? 0xe586;
              final color = int.tryParse(cat.colorHex.replaceFirst('0x', ''), radix: 16) ?? 0xFF9E9E9E;

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131A21) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E272E)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(color).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(iconCode, fontFamily: 'MaterialIcons'),
                      color: Color(color),
                    ),
                  ),
                  title: Text(
                    cat.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: cat.isDefault
                      ? const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: Colors.grey,
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _confirmDelete(context, cat);
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'category_management_fab',
        backgroundColor: AppColors.neon,
        onPressed: () {
          // Show Add Dialog
          _showAddCategoryDialog(context);
        },
        label: const Text(
          "New Category",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryEntity cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Category?"),
        content: Text("Are you sure you want to delete '${cat.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategoryRequested(cat.id));
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Category Name",
            hintText: "e.g. Gym, Pets, Subscriptions",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                final newCat = CategoryEntity(
                  id: DateTime.now().millisecondsSinceEpoch
                      .toString(), // Temp ID gen
                  name: name,
                  iconCodePoint: '0xe5cd', // Specific icon or default
                  colorHex: type == CategoryType.expense ? '0xFF2196F3' : '0xFF4CAF50', // blue for expense, green for income
                  type: type,
                  isDefault: false,
                );
                context.read<CategoryBloc>().add(AddCategoryRequested(newCat));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
