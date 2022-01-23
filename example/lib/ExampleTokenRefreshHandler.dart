import 'package:tapkey_flutter_plugin2/tapkey_flutter_plugin2.dart';

class ExampleTokenRefreshHandler extends TokenRefreshHandler {
  @override
  Future<String> getIdToken() {
    // TODO: implement getIdToken. This will come from my API. My API calls flinkey API to get idtoken, which calls
    // tapkey API to generate access token
    print("ExampleTokenRefreshHandler | looking for a id token. ");
    return Future.value("eyJhbGciOiJSUzI1NiIsImtpZCI6IkU1QTUxRjZEOUY1NjNGODgzRkVDOUIxREUyM0M4QkJCNzJGM0U2QjgifQ.eyJzdWIiOiIyMDM1YzIzYS1kZTNlLTQ1Y2UtOWYyMi0zYzBmNzlkMGNkNDgiLCJpc3MiOiJodHRwczovL3d3dy53aXR0ZS5kaWdpdGFsIiwiYXVkIjoiZjhiOGJiMTctNTkzYS00NzUwLTliNGUtMmZiMDY5ZDZkMjlhIiwiaWF0IjoxNjQyODIzMTc2LCJleHAiOjE2NDI4MjY3NzYsImVtYWlsIjoiMjAzNWMyM2EtZGUzZS00NWNlLTlmMjItM2MwZjc5ZDBjZDQ4In0.NozTrggOU6pauHBArrtWKXyk8iketZ5GuqkTxJ8Pb2uguOJJhn39_01iOhuYyjZD3W0AIQoiLCF6yNXCZ4ORGfUCrqTo1wN6z5i-Ha0PtoXoEFb6CBsifQPGlAcdTjaPDNpN1lIPdz_PgDgoC3yd1lBxfn-WRN1ml84zKNqxkMNZynN5SeeIjg8N5alDboxXVrzlhCPxs_AtfUpWXfthe5cdk1AVzDVzph8d-N1UjqC6MdzC2CXuVvgMqaPR5uNUAkzOvoNht-NO1SXoULmaJC4m05DDGu_uBf3ODgHBXXxxMtFLhlhUez4fJzuuV2_NkA-UG-l9ycJC9NWCEuAgUw");
  }

}