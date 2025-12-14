// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';

import '../data/product_data.dart';
import '../models/product.dart';

class AllCategoriesPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AllCategoriesPage({super.key, this.onBackToHome});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage>
    with SingleTickerProviderStateMixin {
  bool showSearch = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();

  int selectedCategoryIndex = -1;

  List<Product> _visibleProducts = [];

  final List<String> categories = [
    "All",
    "Dresses",
    "Jewellery",
    "Tops",
    "Hoodies",
    "Shoes",
    "Bags",
    "Accessories"
  ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _visibleProducts = List.from(allProducts);
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _visibleProducts = allProducts.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(query);
        final matchesCategory = selectedCategoryIndex <= 0
            ? true
            : product.category ==
                categories[selectedCategoryIndex];

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASSET TEST'),
      ),
      body: Center(
        child: Image.asset(
          'assets/images/bottles/b1/bottle.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}