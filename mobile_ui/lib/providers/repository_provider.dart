import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/repositories/tag_repository.dart';
import 'package:mobile_ui/repositories/category_repository.dart';

part 'repository_provider.g.dart';

/// TagApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる
@riverpod
TagApiClient tagApiClient(Ref ref) {
  return TagApiClient();
}

/// TagRepositoryのインスタンスを提供
///
/// tagApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する
@riverpod
TagRepository tagRepository(Ref ref) {
  return TagRepository(ref.watch(tagApiClientProvider));
}

/// CategoryApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる
@riverpod
CategoryApiClient categoryApiClient(Ref ref) {
  return CategoryApiClient();
}

/// CategoryRepositoryのインスタンスを提供
///
/// categoryApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する
@riverpod
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepository(ref.watch(categoryApiClientProvider));
}
