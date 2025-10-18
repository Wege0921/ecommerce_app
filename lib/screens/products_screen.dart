import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import '../services/product_service.dart';
import '../config/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      appBar: AppBar(title: const Text("Products")),
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
                                        '\$${p['price']}',
                                        style: const TextStyle(color: Colors.green),
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
