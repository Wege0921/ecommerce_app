import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_detail_screen.dart';
import 'dart:async';
import '../services/location_service.dart';
import '../utils/format.dart';
import 'package:ecommerce_app/l10n/generated/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = ProductService();
  final _locationService = LocationService();
  bool isLoading = true;
  List products = [];
  bool isLoadingMore = false;
  bool hasMore = true;
  int _page = 1;
  final _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _autoTimer;
  String? _location;
  String? _lastLocaleCode;
  // Search & filter state
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  num? _priceMin;
  num? _priceMax;
  bool _inStockOnly = true;
  String _ordering = '-created_at'; // '-created_at', 'price', '-price'

  @override
  void initState() {
    super.initState();
    _load();
    _startAutoSlide();
    _fetchLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (_lastLocaleCode != code) {
      _lastLocaleCode = code;
      // Refresh data according to new locale
      _load();
      _fetchLocation();
    }
  }

  Future<void> _load() async {
    try {
      Map<String, dynamic> firstPage;
      List featured = [];
      final searching = _searchQuery.isNotEmpty || _priceMin != null || _priceMax != null || _ordering != '-created_at' || _inStockOnly != true;
      if (!searching) {
        // Fetch featured for carousel source (fallback to newest)
        final featuredRes = await _service.listProducts(isFeatured: true, inStock: true, ordering: '-created_at', page: 1, pageSize: 5);
        featured = (featuredRes['results'] ?? featuredRes) as List;
      }
      firstPage = await _service.listProducts(
        inStock: _inStockOnly,
        ordering: _ordering,
        page: 1,
        pageSize: 12,
        priceMin: _priceMin,
        priceMax: _priceMax,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      setState(() {
        // Merge: ensure featured appear first; then rest of first page (dedup by id)
        final List all = (firstPage['results'] ?? firstPage) as List;
        if (featured.isNotEmpty) {
          final featIds = featured.map((e) => e['id']).toSet();
          final rest = all.where((e) => !featIds.contains(e['id'])).toList();
          products = [...featured, ...rest];
        } else {
          products = all;
        }
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

  Future<void> _fetchLocation() async {
    try {
      final loc = await _locationService.getCityAndCountry();
      if (!mounted) return;
      setState(() => _location = loc);
    } catch (_) {
      // ignore errors silently
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noProducts));
    }

    final featured = (_searchQuery.isEmpty && _priceMin == null && _priceMax == null && _ordering == '-created_at' && _inStockOnly == true)
        ? products.take(_featuredCount).toList()
        : <dynamic>[];
    final rest = featured.isNotEmpty ? products : products; // keep structure

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          isLoading = true;
          isLoadingMore = false;
          hasMore = true;
        });
        await _load();
        await _fetchLocation();
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
        // Location banner
        if (_location != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.redAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: _fetchLocation,
                  child: Text(AppLocalizations.of(context)!.refresh),
                )
              ],
            ),
          ),
        if (featured.isNotEmpty)
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
                                  Format.price(context, Format.toNum(p['price']), currency: 'ETB'),
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
        if (featured.isNotEmpty)
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
        // Search & Filters moved below featured
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              onPressed: () {
                                _searchCtrl.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) => _applySearch(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Filters',
                icon: const Icon(Icons.tune),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: _openFilters,
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
                            Format.price(context, Format.toNum(p['price']), currency: 'ETB'),
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
      final data = await _service.listProducts(
        inStock: _inStockOnly,
        ordering: _ordering,
        page: nextPage,
        pageSize: 12,
        priceMin: _priceMin,
        priceMax: _priceMax,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      final List more = (data['results'] ?? data) as List;
      setState(() {
        products = [...products, ...more];
        _page = nextPage;
        hasMore = data['next'] != null && more.isNotEmpty;
      });
    } catch (_) {}
    setState(() => isLoadingMore = false);
  }

  void _onSearchChanged(String v) {
    _searchDebounce?.cancel();
    _searchQuery = v.trim();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _applySearch);
  }

  Future<void> _applySearch() async {
    setState(() => isLoading = true);
    await _load();
  }

  Future<void> _openFilters() async {
    final minCtrl = TextEditingController(text: _priceMin?.toString() ?? '');
    final maxCtrl = TextEditingController(text: _priceMax?.toString() ?? '');
    bool inStock = _inStockOnly;
    String ordering = _ordering;
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Min Price', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Max Price', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('In stock only'),
                  contentPadding: EdgeInsets.zero,
                  value: inStock,
                  onChanged: (v) => inStock = v,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: ordering,
                  items: const [
                    DropdownMenuItem(value: '-created_at', child: Text('Newest')),
                    DropdownMenuItem(value: 'price', child: Text('Price: Low to High')),
                    DropdownMenuItem(value: '-price', child: Text('Price: High to Low')),
                  ],
                  onChanged: (v) => ordering = v ?? '-created_at',
                  decoration: const InputDecoration(labelText: 'Sort by', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          minCtrl.clear();
                          maxCtrl.clear();
                          inStock = true;
                          ordering = '-created_at';
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx, true);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
    if (res == true) {
      setState(() {
        _priceMin = num.tryParse(minCtrl.text.trim());
        _priceMax = num.tryParse(maxCtrl.text.trim());
        _inStockOnly = inStock;
        _ordering = ordering;
        isLoading = true;
      });
      await _load();
    }
  }
}
