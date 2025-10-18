import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_detail_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = ProductService();
  bool isLoading = true;
  List products = [];
  bool isLoadingMore = false;
  bool hasMore = true;
  int _page = 1;
  final _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _startAutoSlide();
  }

  Future<void> _load() async {
    try {
      // Fetch featured for carousel source (fallback to newest)
      final featured = await _service.listProducts(isFeatured: true, inStock: true, ordering: '-created_at', page: 1, pageSize: 5);
      final firstPage = await _service.listProducts(inStock: true, ordering: '-created_at', page: 1, pageSize: 12);
      setState(() {
        // Merge: ensure featured appear first; then rest of first page (dedup by id)
        final List all = (firstPage['results'] ?? firstPage) as List;
        final List feats = (featured['results'] ?? featured) as List;
        final featIds = feats.map((e) => e['id']).toSet();
        final rest = all.where((e) => !featIds.contains(e['id'])).toList();
        products = [...feats, ...rest];
        isLoading = false;
        hasMore = firstPage['next'] != null;
        _page = 1;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  void _startAutoSlide() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || products.isEmpty) return;
      final next = (_currentPage + 1) % _featuredCount;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  int get _featuredCount => products.length < 5 ? products.length : 5;

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text('No products yet'));
    }

    final featured = products.take(_featuredCount).toList();
    final rest = products;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          isLoading = true;
          isLoadingMore = false;
          hasMore = true;
        });
        await _load();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (sn) {
          if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 100 && !isLoadingMore && hasMore) {
            _loadMore();
          }
          return false;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final p = featured[index] as Map<String, dynamic>;
              final imageUrl = (p['image_url'] ?? '') as String;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(color: Colors.grey.shade200),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    p['title'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${p['price']}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(featured.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              width: active ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ),
        GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.70,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: rest.length,
          itemBuilder: (context, index) {
            final p = rest[index] as Map<String, dynamic>;
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
            child: CircularProgressIndicator(),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadMore() async {
    setState(() => isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final data = await _service.listProducts(inStock: true, ordering: '-created_at', page: nextPage, pageSize: 12);
      final List more = (data['results'] ?? data) as List;
      setState(() {
        products = [...products, ...more];
        _page = nextPage;
        hasMore = data['next'] != null && more.isNotEmpty;
      });
    } catch (_) {}
    setState(() => isLoadingMore = false);
  }
}
