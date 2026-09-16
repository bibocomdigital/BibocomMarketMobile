import 'dart:io';

import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/product_added_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/image_source_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.productId});

  final int? productId;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _stock = TextEditingController(text: '10');
  String? _imagePath;
  String? _imageUrl;
  bool _loading = false;
  int? _categorieProdId;
  ProductAddedArgs? _added;

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _hydrate();
    }
  }

  Future<void> _hydrate() async {
    final overview = await ref.read(merchantOverviewProvider.future);
    final match = overview.products
        .where((item) => item.id == widget.productId)
        .firstOrNull;
    if (match == null || !mounted) return;
    setState(() {
      _name.text = match.name;
      _price.text = _spacedNumber(match.price);
      _description.text = match.description;
      _stock.text = match.stock.toString();
      _categorieProdId = match.categorieProdId;
      _imageUrl = match.imageUrl;
    });
  }

  String _spacedNumber(num value) {
    final digits = value.round().abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await pickAppImage(context);
    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final result = await ref.read(merchantRepositoryProvider).saveProduct(
          ProductFormParams(
            id: widget.productId,
            name: _name.text.trim(),
            description: _description.text.trim(),
            price: double.tryParse(_price.text.replaceAll(' ', '')) ?? 0,
            stock: int.tryParse(_stock.text) ?? 0,
            category: '',
            categorieProdId: _categorieProdId,
            imagePath: _imagePath,
          ),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      failure: (failure) {
        context.showSnack(failure.message);
      },
      success: (product) {
        ref.invalidate(merchantOverviewProvider);
        if (_isEdit) {
          Navigator.of(context).pop();
          return;
        }
        setState(() {
          _added = ProductAddedArgs(
            id: product.id,
            name: product.name.isEmpty ? _name.text.trim() : product.name,
            price: product.price == 0
                ? (double.tryParse(_price.text.replaceAll(' ', '')) ?? 0)
                : product.price,
            imageUrl: product.imageUrl ?? _imageUrl,
            imagePath: _imagePath,
          );
        });
      },
    );
  }

  void _resetForAnother() {
    _formKey.currentState?.reset();
    _name.clear();
    _price.clear();
    _description.clear();
    _stock.text = '10';
    setState(() {
      _imagePath = null;
      _imageUrl = null;
      _categorieProdId = null;
      _added = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_added != null) {
      return ProductAddedPage(
        args: _added!,
        onViewProduct: () {
          final id = _added!.id;
          if (id > 0) {
            context.push(AppRoutes.editProductPath(id));
          } else {
            context.go(AppRoutes.products);
          }
        },
        onAddAnother: _resetForAnother,
      );
    }

    final categories = ref.watch(productCategoriesProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MerchantCenteredHeader(
            title: _isEdit ? 'Modifier le produit' : 'Ajouter un produit',
            onBack: () => context.popOrFallback(fallback: AppRoutes.products),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 148,
                            height: 132,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFD7E4EE),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _ProductImagePreview(
                                filePath: _imagePath,
                                imageUrl: _imageUrl,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _FieldLabel('Nom du produit'),
                      _ProductInput(
                        controller: _name,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Requis'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Catégorie'),
                      categories.when(
                        loading: () => const LinearProgressIndicator(minHeight: 2),
                        error: (error, _) => Text(
                          error.toString().replaceFirst('Exception: ', ''),
                          style: const TextStyle(color: AppColors.error),
                        ),
                        data: (items) {
                          final ids = items.map((item) => item.id).toSet();
                          final selected = ids.contains(_categorieProdId)
                              ? _categorieProdId
                              : null;
                          return DropdownButtonFormField<int>(
                            key: ValueKey(selected),
                            initialValue: selected,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.muted,
                            ),
                            hint: const Text(
                              'Catégorie',
                              style: TextStyle(
                                color: Color(0xFF9BB0C3),
                                fontSize: 15,
                              ),
                            ),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            decoration: _productInputDecoration(),
                            items: items
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _categorieProdId = value),
                            validator: (value) =>
                                value == null ? 'Catégorie requise' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Prix (FCFA)'),
                      _ProductInput(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Requis'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Description'),
                      _ProductInput(controller: _description),
                      const SizedBox(height: 16),
                      const _FieldLabel('Stock'),
                      _ProductInput(
                        controller: _stock,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.accent.withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(
                            _loading ? 'Enregistrement...' : 'Enregistrer',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _productInputDecoration() {
  const border = Color(0xFFD4E2ED);
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.secondary, width: 1.4),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8A9BB0),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ProductInput extends StatelessWidget {
  const _ProductInput({
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
      decoration: _productInputDecoration(),
    );
  }
}

class _ProductImagePreview extends StatelessWidget {
  const _ProductImagePreview({
    this.filePath,
    this.imageUrl,
  });

  final String? filePath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (filePath != null && filePath!.isNotEmpty) {
      return Image.file(File(filePath!), fit: BoxFit.contain);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const _ImagePlaceholder(),
      );
    }
    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF7FAFC),
      child: Icon(
        Icons.add_photo_alternate_outlined,
        color: AppColors.muted,
        size: 36,
      ),
    );
  }
}
