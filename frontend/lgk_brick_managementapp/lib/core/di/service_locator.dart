import 'package:get_it/get_it.dart';
import 'package:lgk_brick_managementapp/business/providers/order_history_provider.dart';
import 'package:lgk_brick_managementapp/business/providers/payment_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/brick_type_repository.dart';
import '../../data/repositories/requisition_repository.dart';
import '../../data/repositories/delivery_challan_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../business/providers/auth_provider.dart';
import '../../business/providers/user_management_provider.dart';
import '../../business/providers/brick_type_provider.dart';
import '../../business/providers/requisition_provider.dart';
import '../../business/providers/delivery_challan_provider.dart';
import '../../data/repositories/order_history_repository.dart';
import '../../core/services/network_service.dart';
import '../../core/services/security_service.dart';

/// Service locator for dependency injection
final getIt = GetIt.instance;

/// Initialize all dependencies
/// 
/// This function sets up the dependency injection container with all required
/// services, repositories, and providers following the service locator pattern.
/// 
/// Registration order:
/// 1. External dependencies (SharedPreferences, FlutterSecureStorage)
/// 2. Core services (ApiService, StorageService, NetworkService)
/// 3. Repositories (AuthRepository, UserRepository, etc.)
/// 4. Providers (AuthProvider, UserManagementProvider, etc.)
Future<void> setupServiceLocator() async {
  // ============================================================================
  // External Dependencies
  // ============================================================================
  
  // Register SharedPreferences as singleton
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Register FlutterSecureStorage as singleton
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);
  
  // ============================================================================
  // Core Services
  // ============================================================================
  
  // Register StorageService as singleton
  getIt.registerLazySingleton<StorageService>(() => StorageService(
    prefs: getIt<SharedPreferences>(),
    secureStorage: getIt<FlutterSecureStorage>(),
  ));
  
  // Register NetworkService as singleton (initialize asynchronously)
  final networkService = NetworkService();
  getIt.registerSingleton<NetworkService>(networkService);
  // Initialize in background to avoid blocking app startup
  networkService.initialize().catchError((e) {
    print('NetworkService initialization failed: $e');
  });
  
  // Register SecurityService as singleton
  getIt.registerLazySingleton<SecurityService>(() => SecurityService());
  
  // Register ApiService as singleton
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  
  // ============================================================================
  // Repositories
  // ============================================================================
  
  // Register AuthRepository as singleton
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
    apiService: getIt<ApiService>(),
    storageService: getIt<StorageService>(),
  ));
  
  // Register UserRepository as singleton
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(
    apiService: getIt<ApiService>(),
  ));
  
  // Register BrickTypeRepository as singleton
  getIt.registerLazySingleton<BrickTypeRepository>(() => BrickTypeRepository(
    apiService: getIt<ApiService>(),
  ));
  
  // Register RequisitionRepository as singleton
  getIt.registerLazySingleton<RequisitionRepository>(() => RequisitionRepository(
    apiService: getIt<ApiService>(),
  ));
  
  // Register DeliveryChallanRepository as singleton
  getIt.registerLazySingleton<DeliveryChallanRepository>(() => DeliveryChallanRepository(
    apiService: getIt<ApiService>(),
  ));
  
  // Register PaymentRepository as singleton
  getIt.registerLazySingleton<PaymentRepository>(() => PaymentRepository(
    apiService: getIt<ApiService>(),
  ));
  
  // Register OrderHistoryRepository as singleton
  getIt.registerLazySingleton<OrderHistoryRepository>(() => OrderHistoryRepository(
    apiService: getIt<ApiService>(),
  ));
  
  // ============================================================================
  // Providers (State Management)
  // ============================================================================
  
  // Register AuthProvider as factory (new instance for each widget tree)
  getIt.registerFactory<AuthProvider>(() => AuthProvider(
    authRepository: getIt<AuthRepository>(),
  ));
  
  // Register UserManagementProvider as factory
  getIt.registerFactory<UserManagementProvider>(() => UserManagementProvider(
    userRepository: getIt<UserRepository>(),
  ));
  
  // Register BrickTypeProvider as factory
  getIt.registerFactory<BrickTypeProvider>(() => BrickTypeProvider(
    brickTypeRepository: getIt<BrickTypeRepository>(),
  ));
  
  // Register RequisitionProvider as factory
  getIt.registerFactory<RequisitionProvider>(() => RequisitionProvider(
    requisitionRepository: getIt<RequisitionRepository>(),
  ));
  
  // Register DeliveryChallanProvider as factory
  getIt.registerFactory<DeliveryChallanProvider>(() => DeliveryChallanProvider(
    requisitionRepository: getIt<RequisitionRepository>(),
    challanRepository: getIt<DeliveryChallanRepository>(),
  ));
  
  // Register PaymentProvider as factory
  getIt.registerFactory<PaymentProvider>(() => PaymentProvider(
    paymentRepository: getIt<PaymentRepository>(),
  ));
  
  // Register OrderHistoryProvider as factory
  getIt.registerFactory<OrderHistoryProvider>(() => OrderHistoryProvider(
    orderHistoryRepository: getIt<OrderHistoryRepository>(),
  ));
}
