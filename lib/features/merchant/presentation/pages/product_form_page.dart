import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _loading = false;
  int? _categorieProdId;

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
      _price.text = match.price.toStringAsFixed(0);
      _description.text = match.description;
      _stock.text = match.stock.toString();
      _categorieProdId = match.categorieProdId;
    });
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
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _imagePath = file.path);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      success: (_) {
        ref.invalidate(merchantOverviewProvider);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(productCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          MerchantBackHeader(
            title: _isEdit ? 'Modifier le produit' : 'Ajouter un produit',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                MerchantCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.light,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: AppColors.muted,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _imagePath != null
                                      ? 'Photo sélectionnée'
                                      : 'Ajouter des photos',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        MerchantTextField(
                          controller: _name,
                          hint: 'Nom du produit',
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        categories.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (error, _) => Text(
                            error.toString().replaceFirst('Exception: ', ''),
                            style: const TextStyle(color: AppColors.error),
                          ),
                          data: (items) {
                            final ids = items.map((item) => item.id).toSet();
                            final selected =
                                ids.contains(_categorieProdId)
                                    ? _categorieProdId
                                    : null;
                            return MerchantDropdown<int>(
                              hint: 'Catégorie produit',
                              value: selected,
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
                        const SizedBox(height: 12),
                        MerchantTextField(
                          controller: _price,
                          hint: 'Prix (CFA)',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        MerchantTextField(
                          controller: _description,
                          hint: 'Description',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        MerchantTextField(
                          controller: _stock,
                          hint: 'Stock',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _loading ? null : _submit,
                          child: Text(
                            _loading
                                ? 'Enregistrement...'
                                : _isEdit
                                    ? 'Enregistrer'
                                    : 'Enregistrer',
                          ),
                        ),
                      ],
                    ),
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
