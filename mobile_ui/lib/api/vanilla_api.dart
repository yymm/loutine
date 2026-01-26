import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// load from dart-define-from-file
const envBaseUrl = String.fromEnvironment('baseUrl');
const baseUrl = envBaseUrl == "" ? 'http://10.0.2.2:8787' : envBaseUrl;

class LinkApiClient {
  Future<String> list(DateTime startDate, DateTime endDate) async {
    final outputFormat = DateFormat('yyyy-MM-dd');
    final startDateStr = outputFormat.format(startDate);
    final endDateStr = outputFormat.format(endDate);
    final url = Uri.parse(
      '$baseUrl/api/v1/links?start_date=$startDateStr&end_date=$endDateStr',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to load links');
    }
  }

  Future<String> post(String url, String title, List<int> tagIds) async {
    final postUrl = Uri.parse('$baseUrl/api/v1/links');
    final headers = {'content-type': 'application/json'};
    final body = json.encode({'url': url, 'title': title, 'tag_ids': tagIds});
    print('LinkApi(post): $body');
    final res = await http.post(postUrl, headers: headers, body: body);
    if (res.statusCode == 201) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to add link');
    }
  }
}

class PurchaseApiClient {
  Future<String> list(DateTime startDate, DateTime endDate) async {
    final outputFormat = DateFormat('yyyy-MM-dd');
    final startDateStr = outputFormat.format(startDate);
    final endDateStr = outputFormat.format(endDate);
    final url = Uri.parse(
      '$baseUrl/api/v1/purchases?start_date=$startDateStr&end_date=$endDateStr',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to load purchases');
    }
  }

  Future<String> post(double cost, String title, int? categoryId) async {
    final postUrl = Uri.parse('$baseUrl/api/v1/purchases');
    final headers = {'content-type': 'application/json'};
    final bodyObject = categoryId != null ? {'cost': cost, 'title': title, 'categoryId': categoryId} : {'cost': cost, 'title': title};
    final body = json.encode(bodyObject);
    print('PurchaseApi(post): $body');
    final res = await http.post(postUrl, headers: headers, body: body);
    if (res.statusCode == 201) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to add link');
    }
  }
}

class NoteApiClient {
  Future<String> list(DateTime startDate, DateTime endDate) async {
    final outputFormat = DateFormat('yyyy-MM-dd');
    final startDateStr = outputFormat.format(startDate);
    final endDateStr = outputFormat.format(endDate);
    final url = Uri.parse(
      '$baseUrl/api/v1/notes?start_date=$startDateStr&end_date=$endDateStr',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to load purchases');
    }
  }

  Future<String> post(String text, String title, List<int> tagIds) async {
    final postUrl = Uri.parse('$baseUrl/api/v1/notes');
    final headers = {'content-type': 'application/json'};
    final body = json.encode({'text': text, 'title': title, 'tag_ids': tagIds});
    print('NoteApi(post): $body');
    final res = await http.post(postUrl, headers: headers, body: body);
    if (res.statusCode == 201) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to add link');
    }
  }
}

class TagApiClient {
  Future<String> list() async {
    final url = Uri.parse('$baseUrl/api/v1/tags');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to load tags');
    }
  }

  Future<String> post(String name, String description) async {
    final url = Uri.parse('$baseUrl/api/v1/tags');
    final headers = {'content-type': 'application/json'};
    final body = json.encode({'name': name, 'description': description});
    final res = await http.post(url, headers: headers, body: body);
    if (res.statusCode == 201) {
      print('TagApi(post): $res.body');
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to add tag');
    }
  }
}

class CategoryApiClient {
  Future<String> list() async {
    final url = Uri.parse('$baseUrl/api/v1/categories');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to load categories');
    }
  }

  Future<String> post(String name, String description) async {
    final url = Uri.parse('$baseUrl/api/v1/categories');
    final headers = {'content-type': 'application/json'};
    final body = json.encode({'name': name, 'description': description});
    final res = await http.post(url, headers: headers, body: body);
    if (res.statusCode == 201) {
      print('TagApi(post): $res.body');
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to add category');
    }
  }
}

class UrlApiClient {
  Future<String> getTitleFromUrl(String url) async {
    final apiUrl = Uri.parse('$baseUrl/api/v1/url/title');
    final headers = {'content-type': 'application/json'};
    final body = json.encode({'url': url});
    final res = await http.post(apiUrl, headers: headers, body: body);
    if (res.statusCode == 200) {
      return utf8.decode(res.bodyBytes);
    } else {
      throw StateError('Failure to get title from url');
    }
  }
}
