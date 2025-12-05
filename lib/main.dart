import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'core/database/db_helper.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/products/data/datasources/product_local_data_source.dart';
import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/products/presentation/bloc/product_event.dart';
import 'features/products/presentation/pages/product_list_page.dart';
import 'features/clients/data/datasources/client_local_data_source.dart';
import 'features/clients/data/datasources/client_remote_data_source.dart';
import 'features/clients/data/repositories/client_repository_impl.dart';
import 'features/clients/domain/repositories/client_repository.dart';
import 'features/clients/presentation/bloc/client_bloc.dart';
import 'features/clients/presentation/bloc/client_event.dart';
import 'features/clients/presentation/pages/client_list_page.dart';
import 'features/sales/data/datasources/sale_local_data_source.dart';
import 'features/sales/data/datasources/sale_remote_data_source.dart';
import 'features/sales/data/repositories/sale_repository_impl.dart';
import 'features/sales/domain/repositories/sale_repository.dart';
import 'features/sales/presentation/bloc/sale_bloc.dart';
import 'features/sales/presentation/bloc/sales_history_bloc.dart';
import 'features/sales/presentation/pages/pos_page.dart';
import 'features/sync/data/repositories/sync_repository_impl.dart';
import 'features/sync/domain/repositories/sync_repository.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';
import 'features/sync/presentation/bloc/sync_event.dart';
import 'pages/about_page.dart';
import 'pages/team_page.dart';
import 'pages/home_page.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/export_service.dart';
import 'core/presentation/bloc/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await _secureScreen();
  }

  final apiService = ApiService();
  final authService = AuthService();
  final dbHelper = DBHelper();
  final exportService = ExportService();

  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiService: apiService);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localAuthService: authService,
  );

  final syncRepository = SyncRepositoryImpl(dbHelper: dbHelper, apiService: apiService);

  final productLocalDataSource = ProductLocalDataSourceImpl(dbHelper: dbHelper);
  final productRemoteDataSource = ProductRemoteDataSourceImpl(apiService: apiService);
  final productRepository = ProductRepositoryImpl(
    remoteDataSource: productRemoteDataSource,
    localDataSource: productLocalDataSource,
  );

  final clientLocalDataSource = ClientLocalDataSourceImpl(dbHelper: dbHelper);
  final clientRemoteDataSource = ClientRemoteDataSourceImpl(apiService: apiService);
  final clientRepository = ClientRepositoryImpl(
    remoteDataSource: clientRemoteDataSource,
    localDataSource: clientLocalDataSource,
  );

  final saleLocalDataSource = SaleLocalDataSourceImpl(dbHelper: dbHelper);
  final saleRemoteDataSource = SaleRemoteDataSourceImpl(apiService: apiService);
  final saleRepository = SaleRepositoryImpl(
    remoteDataSource: saleRemoteDataSource,
    localDataSource: saleLocalDataSource,
    syncRepository: syncRepository,
  );

  runApp(MyApp(
    authRepository: authRepository,
    productRepository: productRepository,
    clientRepository: clientRepository,
    saleRepository: saleRepository,
    syncRepository: syncRepository,
    exportService: exportService,
  ));
}

Future<void> _secureScreen() async {
  // Screenshot blocking removed for web compatibility
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final ClientRepository clientRepository;
  final SaleRepository saleRepository;
  final SyncRepository syncRepository;
  final ExportService exportService;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.productRepository,
    required this.clientRepository,
    required this.saleRepository,
    required this.syncRepository,
    required this.exportService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: clientRepository),
        RepositoryProvider.value(value: saleRepository),
        RepositoryProvider.value(value: syncRepository),
        RepositoryProvider.value(value: exportService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(authRepository: authRepository)..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ProductBloc(productRepository: productRepository)..add(ProductLoadRequested()),
          ),
          BlocProvider(
            create: (context) => ClientBloc(clientRepository: clientRepository)..add(ClientLoadRequested()),
          ),
          BlocProvider(
            create: (context) => SaleBloc(saleRepository: saleRepository),
          ),
          BlocProvider(
            create: (context) => SyncBloc(syncRepository: syncRepository),
          ),
          BlocProvider(
            create: (context) => SalesHistoryBloc(saleRepository: saleRepository),
          ),
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'StockLite POS',
              theme: ThemeData(
                primarySwatch: Colors.indigo,
                useMaterial3: true,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                primarySwatch: Colors.indigo,
                useMaterial3: true,
                brightness: Brightness.dark,
              ),
              themeMode: themeMode,
              initialRoute: '/',
              routes: {
                '/': (_) => const LoginPage(),
                '/register': (_) => const RegisterPage(),
                '/home': (_) => const HomePage(),
                '/clients': (_) => const ClientListPage(),
                '/pos': (_) => const POSPage(),
                '/about': (_) => const AboutPage(),
                '/team': (_) => const TeamPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
