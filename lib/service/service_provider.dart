import 'screen_service.dart';

class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._();

  static ServiceProvider get instance => _instance;

  ServiceProvider._();


  ScreenService screenService;
  
}