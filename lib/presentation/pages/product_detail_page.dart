import 'package:flutter/material.dart';
import '../../core/network/session_manager.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.initialProduct,
    required this.viewModel,
  });

  final int productId;
  final Product? initialProduct;
  final ProductDetailViewModel viewModel;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _favoriteChanged = false;
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProduct(widget.productId, widget.initialProduct);
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _favoriteChanged),
        ),
        title: const Text('Detalhes do Produto'),
        actions: [
          ListenableBuilder(
            listenable: sessionManager,
            builder: (context, _) {
              final isFav = sessionManager.isFavorite(widget.productId);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : null,
                ),
                onPressed: () {
                  sessionManager.toggleFavorite(widget.productId);
                  setState(() {
                    _favoriteChanged = true;
                  });
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<ProductDetailState>(
        valueListenable: widget.viewModel.state,
        builder: (context, state, _) {
          if (state.isLoading && state.product == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.product == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => widget.viewModel.loadProduct(
                        widget.productId,
                        widget.initialProduct,
                      ),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final product = state.product;
          if (product == null) {
            return const Center(child: Text('Produto não encontrado.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 300,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'US\$ ${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.green.shade700,
                            ),
                          ),
                          ListenableBuilder(
                            listenable: sessionManager,
                            builder: (context, _) {
                              final isFav =
                                  sessionManager.isFavorite(product.id);
                              return Chip(
                                avatar: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.redAccent : Colors.grey,
                                  size: 16,
                                ),
                                label: Text(isFav ? 'Favoritado' : 'Favoritar'),
                                deleteIcon: isFav
                                    ? const Icon(Icons.close, size: 14)
                                    : null,
                                onDeleted: isFav
                                    ? () {
                                        sessionManager
                                            .toggleFavorite(product.id);
                                        setState(() {
                                          _favoriteChanged = true;
                                        });
                                      }
                                    : null,
                                backgroundColor: isFav
                                    ? Colors.red.shade50
                                    : Colors.grey.shade100,
                                side: BorderSide(
                                  color: isFav
                                      ? Colors.red.shade200
                                      : Colors.grey.shade300,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Descrição do Produto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
