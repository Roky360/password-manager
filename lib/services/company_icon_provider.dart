import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyIconProvider {
  static final CompanyIconProvider _companyIconProvider = CompanyIconProvider._();

  CompanyIconProvider._();

  factory CompanyIconProvider() => _companyIconProvider;

  /* Properties */
  // https://www.clearbit.com
  static const String nameToDomainEndpoint = "https://company.clearbit.com/v1/domains/find";

  String _apiKey = "";

  set apiKey(String key) => _apiKey = key;

  /* Methods */

  /// response structure:
  /// {
  //    "name": "Instagram",
  //    "domain": "instagram.com",
  //    "logo": "https://logo.clearbit.com/instagram.com"
  //  }
  Future<Map?> getDomainByName(String companyName) async {
    try {
      final response = await http.get(Uri.parse("$nameToDomainEndpoint?name=$companyName"),
          headers: {"Authorization": "Bearer $_apiKey"});

      if (response.statusCode != 200) {
        return null;
      } else {
        // print(response.body);
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error while communicating with Clearbit: $e");
      return null;
    }
  }
}
