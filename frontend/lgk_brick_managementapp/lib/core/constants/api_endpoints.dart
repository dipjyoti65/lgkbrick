/// API endpoint constants for backend communication
class ApiEndpoints {
  // Base URL - should be configured per environment
  // Use HTTP for local development, HTTPS for production
  // For Android emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator localhost
  
  // Authentication endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String currentUser = '/user';
  
  // User management endpoints
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
  static const String usersFormData = '/users-form-data';
  
  // Brick type endpoints
  static const String brickTypes = '/brick-types';
  static String brickTypeById(int id) => '/brick-types/$id';
  static const String activeBrickTypes = '/brick-types/active';
  static String brickTypeStatus(int id) => '/brick-types/$id/status';
  static String brickTypePrice(int id) => '/brick-types/$id/price';
  
  // Requisition endpoints
  static const String requisitions = '/requisitions';
  static String requisitionById(int id) => '/requisitions/$id';
  static const String pendingRequisitions = '/requisitions/pending';
  
  // Delivery challan endpoints
  static const String deliveryChallans = '/delivery-challans';
  static String deliveryChallanById(int id) => '/delivery-challans/$id';
  static const String pendingOrders = '/delivery-challans/pending-orders';
  static String deliveryChallanStatus(int id) => '/delivery-challans/$id/status';
  static String deliveryChallanPrint(int id) => '/delivery-challans/$id/print';
  
  // Payment endpoints
  static const String payments = '/payments';
  static String paymentById(int id) => '/payments/$id';
  static const String pendingChallans = '/payments/pending-challans';
  static const String allChallans = '/payments/all-challans';
  static String paymentApprove(int id) => '/payments/$id/approve';
  static const String paymentReports = '/payments/reports';
  
  // Report endpoints
  static const String reportsDaily = '/reports/daily';
  static const String reportsRange = '/reports/range';
  static const String reportsDailyPdf = '/reports/daily/export/pdf';
  static const String reportsDailyExcel = '/reports/daily/export/excel';
  static const String reportsRangePdf = '/reports/range/export/pdf';
  static const String reportsRangeExcel = '/reports/range/export/excel';
  
  // Order History endpoints
  static const String orderHistory = '/order-history';
  static String orderHistoryById(int id) => '/order-history/$id';
  static const String orderHistoryStatistics = '/order-history/statistics';
  static String orderHistoryPdf(int id) => '/order-history/$id/pdf';
  static const String orderHistoryExportExcel = '/order-history/export/excel';
}
