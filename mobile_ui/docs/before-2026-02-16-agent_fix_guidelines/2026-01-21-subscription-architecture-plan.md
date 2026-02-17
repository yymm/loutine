# サブスクリプション型アーキテクチャ実装プラン

作成日: 2026-01-21

## 🎯 ビジネス要件

### モデル
- **無料ユーザー**: ローカルDB（端末内のみ、同期なし）
- **課金ユーザー**: API通信（クラウド同期、複数端末対応）

### メリット
- 無料ユーザーでも基本機能が使える（App Storeの審査に有利）
- 課金の価値が明確（クラウド同期、複数端末、バックアップ）
- 段階的な収益化が可能

## ✅ 提案アーキテクチャの有効性

**結論**: 提案した DataSource分離 + Repository パターンは**このユースケースに最適**です。

### 理由

1. **データソースの透過的な切り替え**
   ```dart
   // Repositoryが課金状態に応じて自動で判断
   Future<List<Tag>> getTags() async {
     if (await _isSubscribed()) {
       return _remote.getTags();  // 課金ユーザー → API
     } else {
       return _local.getTags();   // 無料ユーザー → ローカルDB
     }
   }
   ```

2. **UI層は課金状態を意識しない**
   ```dart
   // UIは同じコードで動作
   final tags = ref.watch(tagListProvider);
   ```

3. **段階的な実装が可能**
   - Phase 1: ローカルDBのみ（無料版）
   - Phase 2: 課金機能追加
   - Phase 3: API連携追加
   - Phase 4: データ移行機能

## 📱 課金機能の実装方針

### Flutterにおける課金の選択肢

| 方法 | iOS | Android | Web | 手数料 | 難易度 | 推奨度 |
|------|-----|---------|-----|--------|--------|--------|
| **in_app_purchase** | ✅ | ✅ | ❌ | 30% (Apple/Google) | 中 | ⭐⭐⭐⭐⭐ |
| **Stripe** | ✅ | ✅ | ✅ | 2.9% + 30円 | 高 | ⭐⭐⭐ |
| **RevenueCat** | ✅ | ✅ | ✅ | 無料 (+ IAP手数料) | 低 | ⭐⭐⭐⭐⭐ |

### 推奨: RevenueCat + in_app_purchase

**理由**:
1. **in_app_purchase必須**: iOS/AndroidのApp Store審査では、アプリ内課金はIAP（In-App Purchase）を使う必要がある
2. **RevenueCatのメリット**: 
   - IAP実装の複雑さを吸収
   - iOS/Androidの課金を統一管理
   - サーバーサイドの領収書検証を自動化
   - Webhookでバックエンドと連携
   - 無料プランで月1万ドルまでの収益に対応

**Stripeの位置づけ**:
- Web版のみの課金に使用
- または、企業向けプランなど特殊な課金に使用
- iOS/Androidでは Apple/Google の規約上、IAP必須

### 実装パッケージ

```yaml
# pubspec.yaml
dependencies:
  purchases_flutter: ^6.28.1  # RevenueCat SDK
  in_app_purchase: ^3.2.0     # Apple/Google IAP (RevenueCatが内部で使用)
  
  # Stripeは将来的にWeb版課金で使用
  # flutter_stripe: ^10.0.0
```

## 🏗️ アーキテクチャ設計

### フォルダ構成

```
lib/
├── core/
│   ├── constants/
│   │   └── subscription_config.dart    # サブスクプラン定義
│   ├── exceptions/
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── tag_remote_datasource.dart
│   │   │   └── subscription_remote_datasource.dart  # 課金状態をバックエンドと同期
│   │   └── local/
│   │       ├── tag_local_datasource.dart
│   │       └── subscription_local_datasource.dart   # 課金状態のキャッシュ
│   ├── models/
│   └── repositories/
│       ├── tag_repository.dart
│       └── subscription_repository.dart              # 課金管理
├── models/
│   ├── subscription_status.dart                      # 課金状態モデル
│   └── subscription_plan.dart                        # プラン情報
├── providers/
│   ├── subscription_provider.dart                    # 課金状態のProvider
│   └── repository_provider.dart
└── ui/
    ├── subscription/                                  # 課金関連UI
    │   ├── paywall_page.dart                         # 課金誘導画面
    │   ├── subscription_manage_page.dart             # サブスク管理
    │   └── widgets/
    │       ├── pricing_card.dart
    │       └── feature_comparison.dart
    └── settings/
        └── subscription_section.dart                 # 設定内の課金状態表示
```

## 🔐 課金状態管理の実装

### 1. サブスクリプションモデル

```dart
// models/subscription_status.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';

@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const SubscriptionStatus._();
  
  const factory SubscriptionStatus({
    required bool isActive,              // サブスク有効か
    required SubscriptionTier tier,      // プラン種別
    DateTime? expirationDate,            // 有効期限
    String? purchaseToken,               // 課金トークン
    DateTime? lastVerified,              // 最終検証日時
  }) = _SubscriptionStatus;
  
  factory SubscriptionStatus.free() {
    return const SubscriptionStatus(
      isActive: false,
      tier: SubscriptionTier.free,
    );
  }
  
  // API利用可否
  bool get canUseApi => isActive && tier != SubscriptionTier.free;
  
  // 期限切れチェック
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }
}

enum SubscriptionTier {
  free,      // 無料（ローカルのみ）
  premium,   // プレミアム（月額）
  lifetime,  // 買い切り
}

// models/subscription_plan.dart
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,                  // RevenueCat Product ID
    required String name,
    required SubscriptionTier tier,
    required String price,               // "¥500/月"
    required List<String> features,
  }) = _SubscriptionPlan;
}

// core/constants/subscription_config.dart
class SubscriptionConfig {
  // RevenueCat Product IDs
  static const String monthlyProductId = 'premium_monthly';
  static const String lifetimeProductId = 'premium_lifetime';
  
  // プラン定義
  static final List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      id: monthlyProductId,
      name: 'プレミアムプラン',
      tier: SubscriptionTier.premium,
      price: '¥500/月',
      features: [
        'クラウド同期',
        '複数端末で利用可能',
        'データバックアップ',
        '無制限のタグ・カテゴリ',
      ],
    ),
    SubscriptionPlan(
      id: lifetimeProductId,
      name: '買い切りプラン',
      tier: SubscriptionTier.lifetime,
      price: '¥3,000',
      features: [
        'プレミアムプランの全機能',
        '永久利用可能',
        '今後の新機能も利用可能',
      ],
    ),
  ];
}
```

### 2. SubscriptionRepository実装

```dart
// data/repositories/subscription_repository.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionRepository {
  final Purchases _purchases;
  final SubscriptionLocalDataSource _local;
  final SubscriptionRemoteDataSource? _remote;  // バックエンドがある場合
  
  SubscriptionRepository(this._purchases, this._local, [this._remote]);
  
  // 初期化
  Future<void> initialize(String userId) async {
    await _purchases.configure(
      PurchasesConfiguration('YOUR_REVENUECAT_API_KEY')
        ..appUserID = userId,
    );
  }
  
  // 現在の課金状態を取得
  Future<SubscriptionStatus> getStatus() async {
    try {
      final customerInfo = await _purchases.getCustomerInfo();
      
      // アクティブなサブスクリプションをチェック
      if (customerInfo.entitlements.active.isNotEmpty) {
        final entitlement = customerInfo.entitlements.active.values.first;
        
        final tier = _getTierFromProductId(entitlement.productIdentifier);
        final status = SubscriptionStatus(
          isActive: true,
          tier: tier,
          expirationDate: entitlement.expirationDate != null
              ? DateTime.parse(entitlement.expirationDate!)
              : null,
          purchaseToken: entitlement.originalPurchaseDate,
          lastVerified: DateTime.now(),
        );
        
        // ローカルにキャッシュ
        await _local.saveStatus(status);
        
        // バックエンドと同期（オプション）
        await _remote?.syncStatus(status);
        
        return status;
      }
      
      // サブスクなし
      return SubscriptionStatus.free();
      
    } catch (e) {
      // エラー時はローカルキャッシュから取得
      final cached = await _local.getStatus();
      return cached ?? SubscriptionStatus.free();
    }
  }
  
  // プラン一覧取得
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final offerings = await _purchases.getOfferings();
      
      if (offerings.current == null) {
        return SubscriptionConfig.plans;
      }
      
      // RevenueCatから価格情報を取得してマージ
      return SubscriptionConfig.plans.map((plan) {
        final package = offerings.current!.availablePackages.firstWhere(
          (pkg) => pkg.storeProduct.identifier == plan.id,
          orElse: () => offerings.current!.availablePackages.first,
        );
        
        return plan.copyWith(
          price: package.storeProduct.priceString,
        );
      }).toList();
      
    } catch (e) {
      return SubscriptionConfig.plans;
    }
  }
  
  // 購入処理
  Future<SubscriptionStatus> purchase(String productId) async {
    try {
      final offerings = await _purchases.getOfferings();
      final package = offerings.current?.availablePackages.firstWhere(
        (pkg) => pkg.storeProduct.identifier == productId,
      );
      
      if (package == null) {
        throw Exception('Product not found');
      }
      
      final customerInfo = await _purchases.purchasePackage(package);
      
      // 購入成功後、状態を更新
      return await getStatus();
      
    } on PlatformException catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError.toString()) {
        throw Exception('購入がキャンセルされました');
      } else if (e.code == PurchasesErrorCode.paymentPendingError.toString()) {
        throw Exception('支払い処理中です');
      }
      throw Exception('購入に失敗しました: ${e.message}');
    }
  }
  
  // リストア（機種変更時など）
  Future<SubscriptionStatus> restore() async {
    try {
      await _purchases.restorePurchases();
      return await getStatus();
    } catch (e) {
      throw Exception('リストアに失敗しました');
    }
  }
  
  SubscriptionTier _getTierFromProductId(String productId) {
    if (productId == SubscriptionConfig.monthlyProductId) {
      return SubscriptionTier.premium;
    } else if (productId == SubscriptionConfig.lifetimeProductId) {
      return SubscriptionTier.lifetime;
    }
    return SubscriptionTier.free;
  }
}

// data/datasources/local/subscription_local_datasource.dart
class SubscriptionLocalDataSource {
  final SharedPreferences _prefs;
  
  SubscriptionLocalDataSource(this._prefs);
  
  static const String _keyIsActive = 'subscription_is_active';
  static const String _keyTier = 'subscription_tier';
  static const String _keyExpiration = 'subscription_expiration';
  
  Future<SubscriptionStatus?> getStatus() async {
    final isActive = _prefs.getBool(_keyIsActive);
    if (isActive == null) return null;
    
    final tierName = _prefs.getString(_keyTier);
    final tier = SubscriptionTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => SubscriptionTier.free,
    );
    
    final expirationMs = _prefs.getInt(_keyExpiration);
    final expiration = expirationMs != null
        ? DateTime.fromMillisecondsSinceEpoch(expirationMs)
        : null;
    
    return SubscriptionStatus(
      isActive: isActive,
      tier: tier,
      expirationDate: expiration,
      lastVerified: DateTime.now(),
    );
  }
  
  Future<void> saveStatus(SubscriptionStatus status) async {
    await _prefs.setBool(_keyIsActive, status.isActive);
    await _prefs.setString(_keyTier, status.tier.name);
    if (status.expirationDate != null) {
      await _prefs.setInt(
        _keyExpiration,
        status.expirationDate!.millisecondsSinceEpoch,
      );
    }
  }
  
  Future<void> clear() async {
    await _prefs.remove(_keyIsActive);
    await _prefs.remove(_keyTier);
    await _prefs.remove(_keyExpiration);
  }
}
```

### 3. SubscriptionProvider

```dart
// providers/subscription_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'subscription_provider.g.dart';

@riverpod
Purchases purchases(PurchasesRef ref) => Purchases();

@riverpod
SubscriptionLocalDataSource subscriptionLocalDataSource(
  SubscriptionLocalDataSourceRef ref,
) {
  return SubscriptionLocalDataSource(
    SharedPreferencesInstance().prefs,
  );
}

@riverpod
SubscriptionRepository subscriptionRepository(
  SubscriptionRepositoryRef ref,
) {
  return SubscriptionRepository(
    ref.watch(purchasesProvider),
    ref.watch(subscriptionLocalDataSourceProvider),
  );
}

// 課金状態のストリーム
@riverpod
class SubscriptionStatus extends _$SubscriptionStatus {
  @override
  Future<SubscriptionStatusModel> build() async {
    final repo = ref.watch(subscriptionRepositoryProvider);
    
    // 初期化（ユーザーIDは認証システムから取得）
    await repo.initialize('user_${DateTime.now().millisecondsSinceEpoch}');
    
    // 定期的に課金状態を確認（1時間ごと）
    ref.listenSelf((previous, next) {
      Future.delayed(const Duration(hours: 1), () {
        ref.invalidateSelf();
      });
    });
    
    return repo.getStatus();
  }
  
  Future<void> purchase(String productId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      return repo.purchase(productId);
    });
  }
  
  Future<void> restore() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      return repo.restore();
    });
  }
  
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// プラン一覧
@riverpod
Future<List<SubscriptionPlan>> subscriptionPlans(
  SubscriptionPlansRef ref,
) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getAvailablePlans();
}

// API利用可否の便利Provider
@riverpod
bool canUseApi(CanUseApiRef ref) {
  final status = ref.watch(subscriptionStatusProvider);
  return status.when(
    data: (s) => s.canUseApi,
    loading: () => false,
    error: (_, __) => false,
  );
}
```

## 🔄 Repository層での切り替え実装

### TagRepository（課金状態に応じた分岐）

```dart
// data/repositories/tag_repository.dart
class TagRepository {
  final TagRemoteDataSource _remote;
  final TagLocalDataSource _local;
  final SubscriptionRepository _subscription;
  
  TagRepository(this._remote, this._local, this._subscription);
  
  Future<List<Tag>> getTags() async {
    final status = await _subscription.getStatus();
    
    if (status.canUseApi) {
      // 課金ユーザー: APIから取得
      try {
        final remoteTags = await _remote.getTags();
        // ローカルにもバックアップ（オフライン時のフォールバック用）
        await _local.saveTags(remoteTags);
        return remoteTags.map((e) => e.toEntity()).toList();
      } catch (e) {
        // APIエラー時はローカルから
        final localTags = await _local.getTags();
        if (localTags.isEmpty) rethrow;
        return localTags.map((e) => e.toEntity()).toList();
      }
    } else {
      // 無料ユーザー: ローカルDBから取得
      final localTags = await _local.getTags();
      return localTags.map((e) => e.toEntity()).toList();
    }
  }
  
  Future<Tag> createTag(String name, String description) async {
    final status = await _subscription.getStatus();
    
    if (status.canUseApi) {
      // 課金ユーザー: APIに送信してローカルにも保存
      final remoteTag = await _remote.createTag(name, description);
      await _local.saveTag(remoteTag);
      return remoteTag.toEntity();
    } else {
      // 無料ユーザー: ローカルのみ
      final localTag = TagModel.createLocal(name: name, description: description);
      await _local.saveTag(localTag);
      return localTag.toEntity();
    }
  }
  
  // 課金後のデータ移行
  Future<void> migrateToCloud() async {
    final localTags = await _local.getTags();
    
    for (final tag in localTags) {
      // ローカルIDは負数、リモートIDは正数で管理
      if (tag.id < 0) {
        try {
          // ローカルデータをAPIに送信
          final remoteTag = await _remote.createTag(tag.name, tag.description);
          // ローカルの古いデータを削除して、新しいIDで保存
          await _local.deleteTag(tag.id);
          await _local.saveTag(remoteTag);
        } catch (e) {
          // エラーはログのみ（後でリトライ）
          print('Failed to migrate tag: ${tag.id}');
        }
      }
    }
  }
}

// data/models/tag_model.dart (追加)
extension TagModelExtension on TagModel {
  static TagModel createLocal({required String name, required String description}) {
    final now = DateTime.now();
    return TagModel(
      id: -now.millisecondsSinceEpoch,  // 負数でローカル作成を識別
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      isPending: false,  // ローカルオンリーなのでpendingではない
    );
  }
  
  bool get isLocal => id < 0;
}
```

### Provider設定

```dart
// providers/repository_provider.dart
@riverpod
TagRepository tagRepository(TagRepositoryRef ref) {
  return TagRepository(
    ref.watch(tagRemoteDataSourceProvider),
    ref.watch(tagLocalDataSourceProvider),
    ref.watch(subscriptionRepositoryProvider),  // 課金管理を追加
  );
}
```

## 🎨 UI実装

### 1. Paywall（課金誘導画面）

```dart
// ui/subscription/paywall_page.dart
class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(subscriptionPlansProvider);
    final subscriptionState = ref.watch(subscriptionStatusProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレミアムにアップグレード'),
      ),
      body: plans.when(
        data: (planList) => Column(
          children: [
            // ヘッダー
            _buildHeader(),
            
            // 機能比較
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFeatureComparison(),
                  const SizedBox(height: 24),
                  
                  // プラン選択
                  ...planList.map((plan) => PricingCard(
                    plan: plan,
                    onTap: () => _purchasePlan(context, ref, plan.id),
                  )),
                  
                  const SizedBox(height: 16),
                  
                  // リストアボタン
                  TextButton(
                    onPressed: () => _restore(context, ref),
                    child: const Text('購入を復元'),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('エラー: $e')),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_sync, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'クラウド同期で\nどこでも使える',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '無料版との違い',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow('クラウド同期', free: false, premium: true),
            _buildFeatureRow('複数端末対応', free: false, premium: true),
            _buildFeatureRow('データバックアップ', free: false, premium: true),
            _buildFeatureRow('基本機能', free: true, premium: true),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureRow(String feature, {required bool free, required bool premium}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(feature)),
          _buildCheckMark(free),
          const SizedBox(width: 32),
          _buildCheckMark(premium),
        ],
      ),
    );
  }
  
  Widget _buildCheckMark(bool enabled) {
    return Icon(
      enabled ? Icons.check_circle : Icons.cancel,
      color: enabled ? Colors.green : Colors.grey,
    );
  }
  
  Future<void> _purchasePlan(BuildContext context, WidgetRef ref, String productId) async {
    try {
      await ref.read(subscriptionStatusProvider.notifier).purchase(productId);
      
      if (!context.mounted) return;
      
      // 購入成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('購入が完了しました！')),
      );
      
      // データ移行を促す
      final shouldMigrate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('データをクラウドに移行しますか？'),
          content: const Text('ローカルに保存されているデータをクラウドに移行できます。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('後で'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('移行する'),
            ),
          ],
        ),
      );
      
      if (shouldMigrate == true) {
        // データ移行処理
        await ref.read(tagRepositoryProvider).migrateToCloud();
        await ref.read(categoryRepositoryProvider).migrateToCloud();
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('データ移行が完了しました')),
        );
      }
      
      if (!context.mounted) return;
      Navigator.pop(context);
      
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }
  
  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(subscriptionStatusProvider.notifier).restore();
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('復元が完了しました')),
      );
      Navigator.pop(context);
      
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }
}

// ui/subscription/widgets/pricing_card.dart
class PricingCard extends StatelessWidget {
  const PricingCard({
    super.key,
    required this.plan,
    required this.onTap,
  });
  
  final SubscriptionPlan plan;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    plan.price,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...plan.features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 20, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. 設定画面での課金状態表示

```dart
// ui/settings/subscription_section.dart
class SubscriptionSection extends ConsumerWidget {
  const SubscriptionSection({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionStatusProvider);
    
    return status.when(
      data: (s) => Card(
        child: ListTile(
          leading: Icon(
            s.isActive ? Icons.cloud_done : Icons.cloud_off,
            color: s.isActive ? Colors.green : Colors.grey,
          ),
          title: Text(s.isActive ? 'プレミアム会員' : '無料プラン'),
          subtitle: Text(
            s.isActive
                ? 'クラウド同期が有効です'
                : 'ローカルのみで動作中',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (s.isActive) {
              // サブスク管理画面へ
              context.push('/subscription/manage');
            } else {
              // Paywall表示
              context.push('/paywall');
            }
          },
        ),
      ),
      loading: () => const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('読み込み中...'),
        ),
      ),
      error: (_, __) => const Card(
        child: ListTile(
          leading: Icon(Icons.error, color: Colors.red),
          title: Text('エラーが発生しました'),
        ),
      ),
    );
  }
}
```

### 3. 機能制限の表示

```dart
// ui/tag/tag_list.dart（例）
class TagList extends ConsumerWidget {
  const TagList({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUseApi = ref.watch(canUseApiProvider);
    final tags = ref.watch(tagListProvider);
    
    return Column(
      children: [
        // 無料ユーザーにバナー表示
        if (!canUseApi)
          Container(
            color: Colors.amber.shade100,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.amber),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('ローカルのみで動作中。クラウド同期を有効にしますか？'),
                ),
                TextButton(
                  onPressed: () => context.push('/paywall'),
                  child: const Text('詳細'),
                ),
              ],
            ),
          ),
        
        // タグリスト
        Expanded(
          child: tags.when(
            data: (list) => TagListWidget(list),
            loading: () => const LoadingWidget(),
            error: (e, s) => ErrorWidget(e),
          ),
        ),
      ],
    );
  }
}
```

## 🔄 データ移行フロー

### 課金後のローカルデータ → クラウド移行

```dart
// data/repositories/migration_repository.dart
class MigrationRepository {
  final TagRepository _tagRepo;
  final CategoryRepository _categoryRepo;
  final LinkRepository _linkRepo;
  // 他のリポジトリも同様
  
  MigrationRepository(this._tagRepo, this._categoryRepo, this._linkRepo);
  
  Future<MigrationResult> migrateAllDataToCloud() async {
    final result = MigrationResult();
    
    try {
      // 1. Tag移行
      await _tagRepo.migrateToCloud();
      result.tagsCount = await _tagRepo.getLocalCount();
      
      // 2. Category移行
      await _categoryRepo.migrateToCloud();
      result.categoriesCount = await _categoryRepo.getLocalCount();
      
      // 3. Link移行
      await _linkRepo.migrateToCloud();
      result.linksCount = await _linkRepo.getLocalCount();
      
      result.success = true;
      
    } catch (e) {
      result.success = false;
      result.error = e.toString();
    }
    
    return result;
  }
}

class MigrationResult {
  bool success = false;
  int tagsCount = 0;
  int categoriesCount = 0;
  int linksCount = 0;
  String? error;
  
  int get totalCount => tagsCount + categoriesCount + linksCount;
}

// UI: 移行進捗ダイアログ
class MigrationDialog extends ConsumerWidget {
  const MigrationDialog({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final migration = ref.watch(migrationProvider);
    
    return migration.when(
      data: (result) {
        if (result.success) {
          return AlertDialog(
            title: const Text('移行完了'),
            content: Text('${result.totalCount}件のデータを移行しました'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('エラー'),
            content: Text('移行に失敗しました: ${result.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
              ElevatedButton(
                onPressed: () => ref.invalidate(migrationProvider),
                child: const Text('再試行'),
              ),
            ],
          );
        }
      },
      loading: () => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('データを移行しています...'),
          ],
        ),
      ),
      error: (e, s) => AlertDialog(
        title: const Text('エラー'),
        content: Text('$e'),
      ),
    );
  }
}
```

## 📱 RevenueCatセットアップ手順

### 1. RevenueCatアカウント作成

1. https://www.revenuecat.com/ でアカウント作成
2. プロジェクト作成
3. iOS/Androidアプリを登録

### 2. App Store Connect / Google Play Console設定

**iOS (App Store Connect)**:
```
1. App Store Connect にログイン
2. アプリを作成
3. 「App内課金」セクションで商品を作成
   - 自動更新サブスクリプション: premium_monthly
   - 非消耗型: premium_lifetime
4. 価格設定（例: ¥500/月、¥3,000買い切り）
5. RevenueCatにApp Store Connect APIキーを設定
```

**Android (Google Play Console)**:
```
1. Google Play Console にログイン
2. アプリを作成
3. 「収益化」→「定期購入」で商品作成
   - premium_monthly
   - premium_lifetime（非消耗型アイテム）
4. 価格設定
5. RevenueCatにGoogle Play APIキーを設定
```

### 3. RevenueCat設定

```
1. RevenueCat Dashboard → Products
2. iOS/Androidの Product ID を登録
   - premium_monthly
   - premium_lifetime
3. Entitlement作成（例: "premium"）
4. API Keys をコピー
```

### 4. Flutterプロジェクトに実装

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // RevenueCat初期化
  await Purchases.setLogLevel(LogLevel.debug);  // デバッグ時のみ
  
  await SharedPreferencesInstance.initialize();
  
  runApp(ProviderScope(child: const LoutineApp()));
}
```

### 5. テスト

**iOS**: Sandbox環境でテスト
- Xcode → Product → Scheme → Edit Scheme → Run → Arguments
- Environment Variables に `StoreKitConfigurationFile` を設定

**Android**: テストライセンスキー使用
- Google Play Console でテスター登録
- 内部テストトラックでテスト

## 💰 価格設定の参考

### 一般的なFlutterアプリの価格帯

| プラン | 価格 | 用途 |
|--------|------|------|
| 月額 | ¥300-800 | 継続的な収益 |
| 年額 | ¥2,000-5,000 | 月額の10ヶ月分程度 |
| 買い切り | ¥2,000-10,000 | 一度きりの支払い |

### 推奨価格（Loutineアプリの場合）

```dart
// 提案
- 月額: ¥500
- 買い切り: ¥3,000（月額6ヶ月分）

// 理由
- 個人の生産性アプリとして妥当な価格帯
- 買い切りで月額6ヶ月分 = 継続利用の期待値
- App Storeの最低価格 (¥120) より高く、競合と比較して中程度
```

## 🎯 実装フェーズ

### Phase 1: ローカルDB実装（2週間）
```
✓ Drift導入
✓ LocalDataSource実装
✓ 無料版として動作確認
```

### Phase 2: RevenueCat導入（1週間）
```
✓ RevenueCatアカウント・商品登録
✓ SubscriptionRepository実装
✓ 課金状態のProvider作成
```

### Phase 3: Paywall UI（1週間）
```
✓ 課金誘導画面
✓ 設定画面での課金状態表示
✓ 購入フロー実装
```

### Phase 4: API連携切り替え（1週間）
```
✓ Repository層での課金状態判定
✓ RemoteDataSource実装
✓ 課金ユーザーのAPI通信確認
```

### Phase 5: データ移行機能（1週間）
```
✓ ローカル→クラウド移行
✓ ID変換処理
✓ エラーハンドリング
```

### Phase 6: テスト・リリース（1週間）
```
✓ Sandbox環境でのテスト
✓ App Store審査対応
✓ 本番リリース
```

**合計: 約7週間**

## ⚠️ 注意点

### App Store審査のポイント

1. **無料版でも基本機能が使える**: 必須（審査に通らない）
2. **課金の価値が明確**: クラウド同期など分かりやすいメリット
3. **リストア機能**: 機種変更時の購入復元が必須
4. **Sandbox環境でのテスト動画**: 審査時に提出

### ビジネス面の考慮

1. **手数料**:
   - Apple/Google: 30%（1年後は15%）
   - RevenueCat: 無料（月1万ドルまで）

2. **返金ポリシー**:
   - App Store: 原則返金可能
   - 返金対応はApple/Googleが実施

3. **法対応**:
   - 特定商取引法の表記（設定画面に必要）
   - プライバシーポリシー

## 📝 まとめ

### アーキテクチャの有効性

✅ **提案したDataSource分離 + Repositoryパターンは最適**
- 課金状態に応じたデータソース切り替えが容易
- UI層は課金を意識しない
- 段階的な実装が可能

### 課金方法

✅ **RevenueCat + in_app_purchase を推奨**
- iOS/Android必須のIAPを簡単に実装
- 無料プランで十分
- Stripeは将来的にWeb版で検討

### 実装方針

1. Phase 1-2: ローカルDB実装（無料版）
2. Phase 3-4: 課金機能追加
3. Phase 5-6: API連携・データ移行

**総所要時間: 約7週間**

この構成により、無料ユーザーにも価値を提供しつつ、課金ユーザーには明確なメリット（クラウド同期）を提供できます。
