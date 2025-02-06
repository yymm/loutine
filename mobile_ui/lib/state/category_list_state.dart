import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/category.dart';

class CategoryListNotifier extends StateNotifier<List<Category>> {
  CategoryListNotifier() : super([]);

  Future<void> add(String name, String description) async {
    CategoryApiClient apiClient = CategoryApiClient();
    final resBody = await apiClient.post(name, description);
    final Map<String, dynamic> decodedString = json.decode(resBody);
    final category = Category.fromJson(decodedString);
    state = [...state, category];
  }

  Future<List<Category>> getList() async {
    CategoryApiClient apiClient = CategoryApiClient();
    final resBody = await apiClient.list();
    final List<dynamic> categorysJson= json.decode(resBody);
    final categoryList = categorysJson.map((category) {
      return Category.fromJson(category);
    }).toList();
    state = categoryList;
    return categoryList;
  }
}

final categoryListProvider = StateNotifierProvider<CategoryListNotifier, List<Category>>((ref) => CategoryListNotifier());

final categoryListFutureProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  return ref.read(categoryListProvider.notifier).getList();
});
