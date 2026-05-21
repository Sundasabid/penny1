import 'package:flutter/material.dart';
import 'category_management_page.dart';
import '../../../domain/entities/category.dart';
import '../../../config/themes/app_colors.dart';

class CategoryTabsPage extends StatelessWidget {
  const CategoryTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
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
            'Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.neon,
            labelColor: AppColors.neon,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            tabs: const [
              Tab(text: 'Expenses'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CategoryManagementPage(type: CategoryType.expense, showAppBar: false),
            CategoryManagementPage(type: CategoryType.income, showAppBar: false),
          ],
        ),
      ),
    );
  }
}
