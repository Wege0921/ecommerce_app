import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/format.dart';

class CategoryProductsTabbedScreen extends StatefulWidget {
  final int parentCategoryId;
  final String parentCategoryName;
  const CategoryProductsTabbedScreen({super.key, required this.parentCategoryId, required this.parentCategoryName});

  @override
  State<CategoryProductsTabbedScreen> createState() => _CategoryProductsTabbedScreenState();
}

 

class _CategoryProductsTabbedScreenState extends State<CategoryProductsTabbedScreen> {
  final _categoryService = CategoryService();
  List<Map<String, dynamic>> subcategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    try {
      final data = await _categoryService.listCategories(parent: widget.parentCategoryId);
      setState(() {
        subcategories = data.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load subcategories: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabs = <Tab>[
      const Tab(text: 'All'),
      ...subcategories.map((c) => Tab(text: (c['name'] ?? '').toString())).toList(),
    ];
    final tabCategoryIds = <int>[
      widget.parentCategoryId,
      ...subcategories.map((c) => c['id'] as int),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.parentCategoryName),
          bottom: TabBar(isScrollable: true, tabs: tabs),
        ),
        body: TabBarView(
          children: [
            for (int i = 0; i < tabCategoryIds.length; i++)
              _CategoryProductsList(
                categoryId: tabCategoryIds[i],
                descendants: i == 0, // All tab aggregates descendants
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryProductsList extends StatefulWidget {
  final int categoryId;
  final bool descendants;
  const _CategoryProductsList({required this.categoryId, this.descendants = false});

  @override
  State<_CategoryProductsList> createState() => _CategoryProductsListState();
}

class _CategoryProductsListState extends State<_CategoryProductsList> {
  final _service = ProductService();
  List products = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
  }

  Future<void> _fetch({bool reset = false}) async {
    try {
      final page = reset ? 1 : (_page + 1);
      final data = await _service.listProducts(
        categoryId: widget.categoryId,
        descendants: widget.descendants,
        inStock: true,
        ordering: '-created_at',
        page: page,
        pageSize: 12,
      );
      final List pageItems = (data['results'] ?? data) as List;
      setState(() {
        if (reset) {
          products = pageItems;
          _page = 1;
        } else {
          products = [...products, ...pageItems];
          _page = page;
        }
        hasMore = (data['next'] != null) && pageItems.isNotEmpty;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          isLoading = true;
          isLoadingMore = false;
          hasMore = true;
        });
        await _fetch(reset: true);
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (sn) {
          if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 100 && !isLoadingMore && hasMore) {
            setState(() => isLoadingMore = true);
            _fetch(reset: false);
          }
          return false;
        },
        child: ListView(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.70,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index] as Map<String, dynamic>;
                final imageUrl = (p['image_url'] ?? '') as String;
                final dynamic priceRaw = p['price'];
                num priceNum;
                if (priceRaw is num) {
                  priceNum = priceRaw;
                } else if (priceRaw is String) {
                  priceNum = num.tryParse(priceRaw) ?? 0;
                } else {
                  priceNum = 0;
                }
                return Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {/* Implement product detail navigation if needed */},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade100,
                            width: double.infinity,
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (c, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    errorWidget: (c, _, __) => const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                                  )
                                : const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['title'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Format.price(context, priceNum, currency: 'ETB'),
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
