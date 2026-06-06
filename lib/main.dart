import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/network/session_manager.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/product_page.dart';
import 'presentation/viewmodels/login_viewmodel.dart';
import 'presentation/viewmodels/product_detail_viewmodel.dart';
import 'presentation/viewmodels/product_viewmodel.dart';

void main() {
  final apiClient = ApiClient();

  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);

  final productRemoteDataSource = ProductRemoteDataSourceImpl(apiClient);
  final productRepository = ProductRepositoryImpl(productRemoteDataSource);

  final sessionManager = SessionManager();

  final loginViewModel = LoginViewModel(authRepository, sessionManager);
  final productViewModel = ProductViewModel(productRepository);
  final productDetailViewModel = ProductDetailViewModel(productRepository);

  runApp(MyApp(
    loginViewModel: loginViewModel,
    productViewModel: productViewModel,
    productDetailViewModel: productDetailViewModel,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.loginViewModel,
    required this.productViewModel,
    required this.productDetailViewModel,
  });

  final LoginViewModel loginViewModel;
  final ProductViewModel productViewModel;
  final ProductDetailViewModel productDetailViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SessionManager(),
      builder: (context, _) {
        final isAuthenticated = SessionManager().isAuthenticated;

        return MaterialApp(
          title: 'DummyJSON Shop',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.light,
            ),
          ),
          home: isAuthenticated
              ? ProductPage(
                  viewModel: productViewModel,
                  detailViewModel: productDetailViewModel,
                )
              : LoginPage(viewModel: loginViewModel),
        );
      },
    );
  }
}
