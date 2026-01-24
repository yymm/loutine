import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/category.dart';

part 'category_list_provider.g.dart';

@riverpod
class CategoryList extends _$CategoryList {
  @override
  List<Category> build() => [];

  Future<void> add(String name, String description) async {
    CategoryApiClient apiClient = CategoryApiClient();
    final resBody = await apiClient.post(name, description);
    final Map<String, dynamic> decodedString = json.decode(resBody);
    final category = Category.fromJson(decodedString);
    if (!ref.mounted) return;
    state = [...state, category];
  }

  Future<List<Category>> getList() async {
    CategoryApiClient apiClient = CategoryApiClient();
    final resBody = await apiClient.list();
    final List<dynamic> categorysJson= json.decode(resBody);
    final categoryList = categorysJson.map((category) {
      return Category.fromJson(category);
    }).toList();
    if (!ref.mounted) return categoryList;
    state = categoryList;
    return categoryList;
  }
}

@riverpod
Future<List<Category>> categoryListFuture(Ref ref) async {
  return ref.read(categoryListProvider.notifier).getList();
}
