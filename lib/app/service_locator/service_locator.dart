import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:jerseyhub/app/shared_prefs/token_shared_prefs.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:jerseyhub/core/network/hive_service.dart';
import 'package:jerseyhub/features/auth/data/data_source/local_datasource/user_local_datasource.dart';
import 'package:jerseyhub/features/auth/domain/repository/user_repository.dart';
import 'package:jerseyhub/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:jerseyhub/features/auth/domain/use_case/user_logout_usecase.dart';
import 'package:jerseyhub/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:jerseyhub/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
import 'package:jerseyhub/features/auth/presentation/view_model/signup_view_model/signup_view_model.dart';
import 'package:jerseyhub/features/home/presentation/viewmodel/homepage_viewmodel.dart';
import 'package:jerseyhub/features/product/data/data_source/remote_datasource/product_remote_datasource.dart';
import 'package:jerseyhub/features/product/data/repository/product_repository_impl.dart';
import 'package:jerseyhub/features/product/domain/repository/product_repository.dart';
import 'package:jerseyhub/features/category/data/data_source/remote_datasource/category_remote_datasource.dart';
import 'package:jerseyhub/features/category/data/repository/category_repository_impl.dart';
import 'package:jerseyhub/features/category/domain/repository/category_repository.dart';
import 'package:jerseyhub/features/category/domain/use_case/get_all_categories_usecase.dart';
import 'package:jerseyhub/features/category/domain/use_case/get_category_by_id_usecase.dart';
import 'package:jerseyhub/features/category/presentation/viewmodel/category_viewmodel.dart';
import 'package:jerseyhub/features/product/domain/use_case/get_all_products_usecase.dart';
import 'package:jerseyhub/features/product/domain/use_case/get_product_by_id_usecase.dart';
import 'package:jerseyhub/features/product/domain/use_case/get_products_by_category_usecase.dart';
import 'package:jerseyhub/features/product/domain/use_case/search_products_usecase.dart';
import 'package:jerseyhub/features/product/presentation/viewmodel/product_viewmodel.dart';
import 'package:jerseyhub/features/splash/presentation/view_model/splash_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_service.dart';
import '../../features/auth/data/data_source/remote_datasource/user_remote_datasource.dart';
import '../../features/auth/data/repository/remote_repository/user_remote_repository.dart';
import '../../features/cart/data/data_source/local_datasource/cart_local_datasource.dart';
import '../../features/cart/data/data_source/remote_datasource/cart_remote_datasource.dart';
import '../../features/cart/data/repository/cart_repository_impl.dart';
import '../../features/cart/domain/repository/cart_repository.dart';
import '../../features/cart/domain/use_case/add_to_cart_usecase.dart';
import '../../features/cart/domain/use_case/clear_cart_usecase.dart';
import '../../features/cart/domain/use_case/get_cart_usecase.dart';
import '../../features/cart/domain/use_case/remove_from_cart_usecase.dart';
import '../../features/cart/domain/use_case/update_quantity_usecase.dart';
import '../../features/cart/presentation/viewmodel/cart_viewmodel.dart';
import '../../features/order/data/data_source/local_datasource/order_local_datasource.dart';
import '../../features/order/data/data_source/remote_datasource/order_remote_datasource.dart';
import '../../features/order/data/repository/order_repository_impl.dart';
import '../../features/order/domain/repository/order_repository.dart';
import '../../features/order/domain/use_case/get_all_orders_usecase.dart';
import '../../features/order/domain/use_case/get_order_by_id_usecase.dart';
import '../../features/order/domain/use_case/create_order_usecase.dart';
import '../../features/order/domain/use_case/update_order_status_usecase.dart';
import '../../features/order/domain/use_case/delete_order_usecase.dart';
import '../../features/order/presentation/viewmodel/order_viewmodel.dart';
import '../../features/payment/data/data_source/payment_remote_datasource.dart';
import '../../features/payment/data/repository/payment_repository_impl.dart';
import '../../features/payment/domain/repository/payment_repository.dart';
import '../../features/payment/domain/use_case/create_payment_usecase.dart';
import '../../features/payment/presentation/viewmodel/payment_viewmodel.dart';
import '../../features/profile/data/data_source/profile_remote_datasource.dart';
import '../../features/profile/data/repository/profile_repository_impl.dart';
import '../../features/profile/domain/repository/profile_repository.dart';
import '../../features/profile/domain/use_case/change_password_usecase.dart';
import '../../features/profile/domain/use_case/get_profile_usecase.dart';
import '../../features/profile/domain/use_case/update_profile_usecase.dart';
import '../../features/profile/domain/use_case/upload_profile_image_usecase.dart';
import '../../features/profile/presentation/viewmodel/profile_viewmodel.dart';
import '../../features/notification/data/data_source/notification_remote_datasource.dart';
import '../../features/notification/data/repository/notification_repository_impl.dart';
import '../../features/notification/domain/repository/notification_repository.dart';
import '../../features/notification/domain/use_case/get_notifications_usecase.dart';
import '../../features/notification/domain/use_case/mark_notification_read_usecase.dart';
import '../../features/notification/domain/use_case/mark_all_notifications_read_usecase.dart';
import '../../features/notification/domain/use_case/clear_all_notifications_usecase.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/cart/data/services/cart_notification_service.dart';
import '../../app/services/sensor_service.dart';
import '../../app/services/theme_service.dart';
import 'package:jerseyhub/main.dart';
import '../../features/notification/data/data_source/notification_local_datasource.dart';
import '../../features/notification/domain/use_case/add_notification_usecase.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  await _initAuthModule();
  await _initApiService();
  await _initSplashModule();
  await _initHomeModule();
  await _initProductModule(); // Make sure to call this!
  await _initCategoryModule(); // Make sure to call this!
  await _initCartModule(); // Make sure to call this!
  await _initOrderModule(); // Make sure to call this!
  await _initPaymentModule();
  await _initProfileModule();
  await _initNotificationModule();
  await _initSensorAndThemeServices();
}

Future<void> _initProfileModule() async {
  // Data layer - Use real backend data source
  serviceLocator.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(serviceLocator<ApiService>()),
  );

  serviceLocator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(serviceLocator<ProfileRemoteDataSource>()),
  );
  serviceLocator.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(serviceLocator<ProfileRepository>()),
  );
  serviceLocator.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(serviceLocator<ProfileRepository>()),
  );
  serviceLocator.registerLazySingleton<UploadProfileImageUseCase>(
    () => UploadProfileImageUseCase(serviceLocator<ProfileRepository>()),
  );
  serviceLocator.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(serviceLocator<ProfileRepository>()),
  );
  serviceLocator.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      getProfileUseCase: serviceLocator<GetProfileUseCase>(),
      updateProfileUseCase: serviceLocator<UpdateProfileUseCase>(),
      uploadProfileImageUseCase: serviceLocator<UploadProfileImageUseCase>(),
      changePasswordUseCase: serviceLocator<ChangePasswordUseCase>(),
    ),
  );
}

Future<void> _initCore() async {
  final hiveService = HiveService();
  await hiveService.init(); // Initialize Hive
  serviceLocator.registerLazySingleton<HiveService>(() => hiveService);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );

  // Register TokenSharedPrefs
  serviceLocator.registerLazySingleton<TokenSharedPrefs>(
    () => TokenSharedPrefs(
      sharedPreferences: serviceLocator<SharedPreferences>(),
    ),
  );

  // Register UserSharedPrefs
  serviceLocator.registerLazySingleton<UserSharedPrefs>(
    () => UserSharedPrefs(serviceLocator<SharedPreferences>()),
  );
}

Future<void> _initApiService() async {
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton(() {
    final apiService = ApiService(serviceLocator<Dio>());

    // Try to set authentication token if available
    _setAuthTokenIfAvailable(apiService);

    return apiService;
  });
}

Future<void> _setAuthTokenIfAvailable(ApiService apiService) async {
  try {
    final tokenSharedPrefs = serviceLocator<TokenSharedPrefs>();
    final tokenResult = await tokenSharedPrefs.getToken();
    tokenResult.fold(
      (failure) => print('⚠️ Could not get token: ${failure.message}'),
      (token) {
        if (token != null && token.isNotEmpty) {
          apiService.setAuthToken(token);
          print('🔐 Authentication token set for API service');
        }
      },
    );
  } catch (e) {
    print('⚠️ Could not set authentication token: $e');
  }
}

Future<void> _initAuthModule() async {
  // Data layer
  serviceLocator.registerLazySingleton<UserLocalDatasource>(
    () => UserLocalDatasource(hiveService: serviceLocator<HiveService>()),
  );

  serviceLocator.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );

  serviceLocator.registerLazySingleton<IUserRepository>(
    () => UserRemoteRepository(
      remoteDataSource: serviceLocator<UserRemoteDataSource>(),
    ),
  );

  // Domain layer
  serviceLocator.registerLazySingleton<UserLoginUsecase>(
    () => UserLoginUsecase(
      userRepository: serviceLocator<IUserRepository>(),
      tokenSharedPrefs: serviceLocator<TokenSharedPrefs>(),
      sharedPreferences: serviceLocator<SharedPreferences>(),
    ),
  );

  serviceLocator.registerLazySingleton<UserRegisterUsecase>(
    () =>
        UserRegisterUsecase(userRepository: serviceLocator<IUserRepository>()),
  );

  serviceLocator.registerLazySingleton<UserLogoutUseCase>(
    () => UserLogoutUseCase(
      repository: serviceLocator<IUserRepository>(),
      tokenSharedPrefs: serviceLocator<TokenSharedPrefs>(),
    ),
  );

  // Presentation layer
  serviceLocator.registerFactory<LoginViewModel>(
    () => LoginViewModel(serviceLocator<UserLoginUsecase>()),
  );

  serviceLocator.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(serviceLocator<UserRegisterUsecase>()),
  );
}

Future<void> _initSplashModule() async {
  serviceLocator.registerFactory(() => SplashViewModel());
}

Future<void> _initHomeModule() async {
  serviceLocator.registerFactory<HomeViewModel>(
    () => HomeViewModel(logoutUseCase: serviceLocator<UserLogoutUseCase>()),
  );
}

Future<void> _initProductModule() async {
  // Data layer - ProductRemoteDataSource already has mock fallback
  serviceLocator.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );

  serviceLocator.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: serviceLocator<ProductRemoteDataSource>(),
    ),
  );

  // Domain layer
  serviceLocator.registerLazySingleton<GetAllProductsUseCase>(
    () =>
        GetAllProductsUseCase(repository: serviceLocator<IProductRepository>()),
  );

  serviceLocator.registerLazySingleton<GetProductByIdUseCase>(
    () =>
        GetProductByIdUseCase(repository: serviceLocator<IProductRepository>()),
  );

  serviceLocator.registerLazySingleton<GetProductsByCategoryUseCase>(
    () => GetProductsByCategoryUseCase(
      repository: serviceLocator<IProductRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<SearchProductsUseCase>(
    () =>
        SearchProductsUseCase(repository: serviceLocator<IProductRepository>()),
  );

  // Presentation layer
  serviceLocator.registerFactory<ProductViewModel>(
    () => ProductViewModel(
      getAllProductsUseCase: serviceLocator<GetAllProductsUseCase>(),
      getProductByIdUseCase: serviceLocator<GetProductByIdUseCase>(),
      getProductsByCategoryUseCase:
          serviceLocator<GetProductsByCategoryUseCase>(),
      searchProductsUseCase: serviceLocator<SearchProductsUseCase>(),
    ),
  );
}

Future<void> _initCategoryModule() async {
  // Data layer - CategoryRemoteDataSource already has mock fallback
  serviceLocator.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );

  serviceLocator.registerLazySingleton<ICategoryRepository>(
    () => CategoryRepositoryImpl(
      remoteDataSource: serviceLocator<CategoryRemoteDataSource>(),
    ),
  );

  // Domain layer
  serviceLocator.registerLazySingleton<GetAllCategoriesUseCase>(
    () => GetAllCategoriesUseCase(
      repository: serviceLocator<ICategoryRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<GetCategoryByIdUseCase>(
    () => GetCategoryByIdUseCase(
      repository: serviceLocator<ICategoryRepository>(),
    ),
  );

  // Presentation layer
  serviceLocator.registerFactory<CategoryViewModel>(
    () => CategoryViewModel(
      getAllCategoriesUseCase: serviceLocator<GetAllCategoriesUseCase>(),
      getCategoryByIdUseCase: serviceLocator<GetCategoryByIdUseCase>(),
    ),
  );
}

Future<void> _initCartModule() async {
  // Data layer
  serviceLocator.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(),
  );

  // Cart remote data source - already has mock fallback
  serviceLocator.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(serviceLocator<ApiService>().dio),
  );

  serviceLocator.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      serviceLocator<CartLocalDataSource>(),
      serviceLocator<CartRemoteDataSource>(),
    ),
  );

  // Cart notification service
  serviceLocator.registerLazySingleton<CartNotificationService>(
    () => CartNotificationService(
      dio: serviceLocator<ApiService>().dio,
      userSharedPrefs: serviceLocator<UserSharedPrefs>(),
      scaffoldMessengerKey: globalScaffoldMessengerKey,
    ),
  );

  // Domain layer
  serviceLocator.registerLazySingleton<GetCartUseCase>(
    () => GetCartUseCase(serviceLocator<CartRepository>()),
  );

  serviceLocator.registerLazySingleton<AddToCartUseCase>(
    () => AddToCartUseCase(serviceLocator<CartRepository>()),
  );

  serviceLocator.registerLazySingleton<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(serviceLocator<CartRepository>()),
  );

  serviceLocator.registerLazySingleton<UpdateQuantityUseCase>(
    () => UpdateQuantityUseCase(serviceLocator<CartRepository>()),
  );

  serviceLocator.registerLazySingleton<ClearCartUseCase>(
    () => ClearCartUseCase(serviceLocator<CartRepository>()),
  );

  // Presentation layer
  serviceLocator.registerFactory<CartViewModel>(
    () => CartViewModel(
      getCartUseCase: serviceLocator<GetCartUseCase>(),
      addToCartUseCase: serviceLocator<AddToCartUseCase>(),
      removeFromCartUseCase: serviceLocator<RemoveFromCartUseCase>(),
      updateQuantityUseCase: serviceLocator<UpdateQuantityUseCase>(),
      clearCartUseCase: serviceLocator<ClearCartUseCase>(),
      cartNotificationService: serviceLocator<CartNotificationService>(),
      userSharedPrefs: serviceLocator<UserSharedPrefs>(),
    ),
  );
}

Future<void> _initOrderModule() async {
  // Data layer
  serviceLocator.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(),
  );

  serviceLocator.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(serviceLocator<ApiService>().dio),
  );

  serviceLocator.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      serviceLocator<OrderLocalDataSource>(),
      serviceLocator<OrderRemoteDataSource>(),
    ),
  );

  // Domain layer
  serviceLocator.registerLazySingleton<GetAllOrdersUseCase>(
    () => GetAllOrdersUseCase(serviceLocator<OrderRepository>()),
  );

  serviceLocator.registerLazySingleton<GetOrderByIdUseCase>(
    () => GetOrderByIdUseCase(serviceLocator<OrderRepository>()),
  );

  serviceLocator.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(serviceLocator<OrderRepository>()),
  );

  serviceLocator.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(serviceLocator<OrderRepository>()),
  );

  serviceLocator.registerLazySingleton<DeleteOrderUseCase>(
    () => DeleteOrderUseCase(serviceLocator<OrderRepository>()),
  );

  // Presentation layer
  serviceLocator.registerFactory<OrderViewModel>(
    () => OrderViewModel(
      getAllOrdersUseCase: serviceLocator<GetAllOrdersUseCase>(),
      getOrderByIdUseCase: serviceLocator<GetOrderByIdUseCase>(),
      createOrderUseCase: serviceLocator<CreateOrderUseCase>(),
      updateOrderStatusUseCase: serviceLocator<UpdateOrderStatusUseCase>(),
      deleteOrderUseCase: serviceLocator<DeleteOrderUseCase>(),
      userSharedPrefs: serviceLocator<UserSharedPrefs>(),
    ),
  );
}

Future<void> _initPaymentModule() async {
  // Data layer
  serviceLocator.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(serviceLocator<ApiService>()),
  );

  serviceLocator.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(serviceLocator<PaymentRemoteDataSource>()),
  );

  // Domain layer
  serviceLocator.registerLazySingleton<CreatePaymentUseCase>(
    () => CreatePaymentUseCase(serviceLocator<PaymentRepository>()),
  );

  // Presentation layer
  serviceLocator.registerFactory<PaymentViewModel>(
    () => PaymentViewModel(
      createPaymentUseCase: serviceLocator<CreatePaymentUseCase>(),
    ),
  );
}

Future<void> _initNotificationModule() async {
  // Data layer
  serviceLocator.registerLazySingleton<INotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(serviceLocator<Dio>()),
  );

  serviceLocator.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(),
  );

  serviceLocator.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      serviceLocator<INotificationRemoteDataSource>(),
      serviceLocator<NotificationLocalDataSource>(),
    ),
  );

  // Domain layer
  serviceLocator.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(serviceLocator<INotificationRepository>()),
  );

  serviceLocator.registerLazySingleton<MarkNotificationReadUseCase>(
    () =>
        MarkNotificationReadUseCase(serviceLocator<INotificationRepository>()),
  );

  serviceLocator.registerLazySingleton<MarkAllNotificationsReadUseCase>(
    () => MarkAllNotificationsReadUseCase(
      serviceLocator<INotificationRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<ClearAllNotificationsUseCase>(
    () =>
        ClearAllNotificationsUseCase(serviceLocator<INotificationRepository>()),
  );

  serviceLocator.registerLazySingleton<AddNotificationUseCase>(
    () => AddNotificationUseCase(serviceLocator<INotificationRepository>()),
  );

  // Presentation layer
  serviceLocator.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      repository: serviceLocator<INotificationRepository>(),
      getNotificationsUseCase: serviceLocator<GetNotificationsUseCase>(),
      markAsReadUseCase: serviceLocator<MarkNotificationReadUseCase>(),
      markAllAsReadUseCase: serviceLocator<MarkAllNotificationsReadUseCase>(),
      clearAllNotificationsUseCase:
          serviceLocator<ClearAllNotificationsUseCase>(),
    ),
  );
}

Future<void> _initSensorAndThemeServices() async {
  // Register sensor service
  serviceLocator.registerLazySingleton<SensorService>(() => SensorService());

  // Register theme service
  serviceLocator.registerLazySingleton<ThemeService>(() => ThemeService());

  // Initialize theme service
  await serviceLocator<ThemeService>().initialize();
}
