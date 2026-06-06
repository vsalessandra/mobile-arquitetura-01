import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductDetailState {
  const ProductDetailState({
    this.isLoading = false,
    this.product,
    this.error,
  });

  final bool isLoading;
  final Product? product;
  final String? error;

  ProductDetailState copyWith({
    bool? isLoading,
    Product? product,
    String? error,
    bool clearError = false,
  }) {
    return ProductDetailState(
      isLoading: isLoading ?? this.isLoading,
      product: product ?? this.product,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductDetailViewModel {
  ProductDetailViewModel(this.repository);

  final ProductRepository repository;
  final ValueNotifier<ProductDetailState> state =
      ValueNotifier(const ProductDetailState());

  Future<void> loadProduct(int id, Product? initialProduct) async {
    if (initialProduct != null) {
      state.value = ProductDetailState(product: initialProduct);
    }

    state.value = state.value.copyWith(isLoading: true, clearError: true);

    try {
      final product = await repository.getProductById(id);
      state.value = ProductDetailState(product: product);
    } catch (error) {
      if (state.value.product == null) {
        state.value = state.value.copyWith(
          isLoading: false,
          error: error
              .toString()
              .replaceFirst('Failure: ', '')
              .replaceFirst('Exception: ', ''),
        );
      } else {
        state.value = state.value.copyWith(isLoading: false);
      }
    }
  }

  void dispose() {
    state.dispose();
  }
}
