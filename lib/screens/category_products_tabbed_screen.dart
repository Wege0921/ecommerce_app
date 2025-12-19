import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../utils/format.dart';
import '../state/cart_state.dart';
import 'product_detail_screen.dart';

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

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        children: List.generate(6, (index) => Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.parentCategoryName)),
        body: _buildShimmerLoading(),
      );
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

class _CategoryProductsListState extends State<_CategoryProductsList> with AutomaticKeepAliveClientMixin<_CategoryProductsList> {
  final _service = ProductService();
  List products = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int _page = 1;

  String _productThumbUrl(Map<String, dynamic> p) {
    final images = p['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map) {
        if (first['tiny'] is String) return first['tiny'] as String;
        if (first['thumb'] is String) return first['thumb'] as String;
      }
      if (first is String) return first;
    }
    return (p['image_url'] ?? '') as String;
  }

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

  Widget _buildProductShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70,
      ),
      itemCount: 6, // Number of shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                // Title placeholder
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 120,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                // Price placeholder
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 60,
                  height: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading) {
      return _buildProductShimmer();
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
          cacheExtent: 800,
          children: [
            isLoadingMore
                ? _buildProductShimmer()
                : GridView.builder(
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
                final imageUrl = _productThumbUrl(p);
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p as Map<String, dynamic>),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade100,
                            width: double.infinity,
                            child: imageUrl.isNotEmpty
                                ? Builder(builder: (context) {
                                    final dpr = MediaQuery.of(context).devicePixelRatio;
                                    return CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      memCacheWidth: (240 * dpr).round(),
                                      fadeInDuration: const Duration(milliseconds: 120),
                                      placeholder: (c, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      errorWidget: (c, _, __) => const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                                    );
                                  })
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
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'In stock: ${p['stock'] ?? ''}',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_shopping_cart),
                                    tooltip: 'Add to cart',
                                    onPressed: () {
                                      final stock = p['stock'] is int ? p['stock'] as int : null;
                                      context.read<CartState>().add(p as Map<String, dynamic>, quantity: 1, stock: stock);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Added to cart')),
                                      );
                                    },
                                  ),
                                ],
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

  @override
  bool get wantKeepAlive => true;
}
