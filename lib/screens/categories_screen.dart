import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'products_screen.dart';
import 'category_products_tabbed_screen.dart';
import '../services/category_service.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List categories = [];
  bool isLoading = true;
  final _service = CategoryService();

  IconData _categoryIcon(String name) {
    final n = name.toLowerCase();
    // Eyewear / Eye glasses
    if (n.contains('eyewear') || n.contains('eye') || n.contains('glass')) return Icons.visibility_outlined;
    // Cosmetics / beauty
    if (n.contains('cosmetic') || n.contains('beauty') || n.contains('makeup')) return Icons.brush_outlined;
    // Men
    if (n.contains('men') || n.contains('male')) return Icons.male;
    // Female / women
    if (n.contains('female') || n.contains('women') || n.contains('lady')) return Icons.female;
    // Kids / children
    if (n.contains('kid') || n.contains('child') || n.contains('children')) return Icons.child_care;
    // Electronics
    if (n.contains('electronic') || n.contains('electronics') || n.contains('device') || n.contains('gadget')) return Icons.devices_other;
    // Computer / laptop
    if (n.contains('computer') || n.contains('laptop') || n.contains('pc')) return Icons.computer;
    // Accessories
    if (n.contains('accessor') || n.contains('accessories') || n.contains('watch') || n.contains('bag')) return Icons.style_outlined;
    return Icons.category_outlined;
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await _service.listCategories();
      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 8, // Number of shimmer items to show
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
              ),
              title: Container(
                height: 16,
                width: 120,
                color: Colors.white,
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.categories)),
        body: _buildShimmerLoading(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.categories)),
      body: categories.isEmpty
          ? const Center(child: Text('No categories found'))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final rawName = (category['name'] ?? '').toString();
                String name = rawName;
                // Localize known categories
                final t = AppLocalizations.of(context)!;
                final n = rawName.toLowerCase();
                if (n.contains('eyewear') || n.contains('eye') || n.contains('glass')) {
                  name = t.categoryEyeGlasses;
                } else if (n.contains('cosmetic') || n.contains('beauty') || n.contains('makeup')) {
                  name = t.categoryCosmetics;
                } else if (n.contains('men') || n.contains('male')) {
                  name = t.categoryMen;
                } else if (n.contains('female') || n.contains('women') || n.contains('lady')) {
                  name = t.categoryFemale;
                } else if (n.contains('kid') || n.contains('child') || n.contains('children')) {
                  name = t.categoryKids;
                } else if (n.contains('electronic') || n.contains('electronics') || n.contains('device') || n.contains('gadget')) {
                  name = t.categoryElectronics;
                } else if (n.contains('computer') || n.contains('laptop') || n.contains('pc')) {
                  name = t.categoryComputer;
                } else if (n.contains('accessor') || n.contains('accessories') || n.contains('watch') || n.contains('bag')) {
                  name = t.categoryAccessories;
                }
                final icon = _categoryIcon(name);
                final theme = Theme.of(context);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.10),
                      child: Icon(icon, color: theme.colorScheme.primary),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final id = category['id'] as int;
                      final rawName = (category['name'] ?? '').toString();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryProductsTabbedScreen(parentCategoryId: id, parentCategoryName: rawName),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
