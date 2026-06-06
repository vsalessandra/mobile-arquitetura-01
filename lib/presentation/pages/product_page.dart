import 'package:flutter/material.dart';

import '../../core/network/session_manager.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import 'product_detail_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    super.key,
    required this.viewModel,
    required this.detailViewModel,
  });

  final ProductViewModel viewModel;
  final ProductDetailViewModel detailViewModel;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();
    final user = session.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (user?.image != null && user!.image.isNotEmpty)
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(user.image),
                backgroundColor: Colors.grey.shade200,
              )
            else
              const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Produtos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user != null ? 'Olá, ${user.fullName}' : 'Olá',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sair da Conta',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              session.logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.viewModel.loadProducts,
        child: ValueListenableBuilder<ProductState>(
          valueListenable: widget.viewModel.state,
          builder: (context, state, _) {
            if (state.isLoading && state.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.products.isEmpty) {
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
                        onPressed: widget.viewModel.loadProducts,
                        child: const Text('Recarregar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = state.products[index];
                return _ProductCard(
                  product: product,
                  detailViewModel: widget.detailViewModel,
                  onReload: widget.viewModel.loadProducts,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.viewModel.loadProducts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.detailViewModel,
    required this.onReload,
  });

  final Product product;
  final ProductDetailViewModel detailViewModel;

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: Hero(
            tag: 'product_image_${product.id}',
            child: Image.network(
              product.image,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        title: Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'US\$ ${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.green.shade700,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListenableBuilder(
              listenable: sessionManager,
              builder: (context, _) {
                final isFav = sessionManager.isFavorite(product.id);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : null,
                  ),
                  onPressed: () {
                    sessionManager.toggleFavorite(product.id);
                  },
                );
              },
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                productId: product.id,
                initialProduct: product,
                viewModel: detailViewModel,
              ),
            ),
          );
          if (changed == true) {
            onReload();
          }
        },
      ),
    );
  }
}
