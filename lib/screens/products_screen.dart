import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import '../services/product_service.dart';
import '../config/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/format.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';

class ProductsScreen extends StatefulWidget {
  final int? categoryId; // optional filter by category
  const ProductsScreen({super.key, this.categoryId});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List products = [];
  bool isLoading = true;
  final _service = ProductService();
  int _page = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  // type filter (e.g., cap types)
  Set<String> _types = {};
  String? _activeType;

  String _productThumbUrl(Map<String, dynamic> p) {
    final images = p['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map && first['thumb'] is String) return first['thumb'] as String;
      if (first is String) return first;
    }
    return (p['image_url'] ?? '') as String;
  }

  String? _typeOf(Map<String, dynamic> p) {
    final dynamic t1 = p['type'];
    if (t1 is String && t1.trim().isNotEmpty) return t1.trim();
    final dynamic t2 = p['sub_category'] ?? p['subcategory'] ?? p['subtype'];
    if (t2 is String && t2.trim().isNotEmpty) return t2.trim();
    if (p['attributes'] is Map<String, dynamic>) {
      final attrs = p['attributes'] as Map<String, dynamic>;
      final dynamic t3 = attrs['type'] ?? attrs['subtype'];
      if (t3 is String && t3.trim().isNotEmpty) return t3.trim();
    }
    if (p['tags'] is List) {
      final tags = (p['tags'] as List).whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (tags.isNotEmpty) return tags.first;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    fetchProducts(reset: true);
  }

  Future<void> fetchProducts({bool reset = false}) async {
    try {
      final page = reset ? 1 : (_page + 1);
      final data = await _service.listProducts(
        categoryId: widget.categoryId,
        type: _activeType,
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
        hasMore = data['next'] != null && pageItems.isNotEmpty;
        isLoading = false;
        isLoadingMore = false;
        // build type facets
        final types = <String>{};
        for (final it in products) {
          if (it is Map<String, dynamic>) {
            final t = _typeOf(it);
            if (t != null && t.isNotEmpty) types.add(t);
          }
        }
        _types = types;
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
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.productsTitle)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                  isLoadingMore = false;
                  hasMore = true;
                });
                await fetchProducts(reset: true);
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (sn) {
                  if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 100 && !isLoadingMore && hasMore) {
                    setState(() => isLoadingMore = true);
                    fetchProducts(reset: false);
                  }
                  return false;
                },
                child: ListView(
                  children: [
                    if (_types.isNotEmpty)
                      SizedBox(
                        height: 48,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: const Text('All'),
                                selected: _activeType == null,
                                onSelected: (_) {
                                  if (_activeType != null) {
                                    setState(() {
                                      _activeType = null;
                                      isLoading = true;
                                      isLoadingMore = false;
                                      hasMore = true;
                                    });
                                    fetchProducts(reset: true);
                                  }
                                },
                              ),
                            ),
                            for (final t in _types)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(t),
                                  selected: _activeType == t,
                                  onSelected: (_) {
                                    if (_activeType != t) {
                                      setState(() {
                                        _activeType = t;
                                        isLoading = true;
                                        isLoadingMore = false;
                                        hasMore = true;
                                      });
                                      fetchProducts(reset: true);
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
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
                        final imageUrl = _productThumbUrl(p);
                        // Coerce price to numeric even if backend returns it as String
                        final dynamic priceRaw = p['price'];
                        num priceNum;
                        if (priceRaw is num) {
                          priceNum = priceRaw;
                        } else if (priceRaw is String) {
                          priceNum = num.tryParse(priceRaw) ?? 0;
                        } else {
                          priceNum = 0;
                        }
                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                          ),
                          child: Card(
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
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
                                              memCacheWidth: (300 * dpr).round(),
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
            ),
    );
  }
}
