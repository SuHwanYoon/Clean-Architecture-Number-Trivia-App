# Number Trivia

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13%2B-0175C2?logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/State%20Management-flutter__bloc-42A5F5)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-6DB33F)
![Dio](https://img.shields.io/badge/Networking-Dio-00B4AB)
![Tests](https://img.shields.io/badge/Tests-flutter__test%20%7C%20mocktail-4CAF50)

**Number Trivia** は、入力した数字またはランダムな数字に関する豆知識をすばやく表示する Flutter アプリです。
単なる REST API クライアントではなく、通信状態に応じたキャッシュフォールバック、入力エラーの明示、テスト可能な依存関係分離を備えた、保守性を重視したモバイルアプリとして設計しています。

| 項目 | 内容 |
| --- | --- |
| 開発期間 / 人員 | 2026.08–2026.10 / 個人開発 |
| 対象プラットフォーム | Android / iOS（Flutter のマルチプラットフォーム構成） |
| API | Number Trivia REST API |
| 主な実装 | Dart 3、Flutter、flutter_bloc、Dio、SharedPreferences、GetIt |
| テスト | `flutter_test`、`mocktail`、`mockito` |

## Project Overview

ユーザーは、数字を入力して検索するか、ワンタップでランダムな数字の豆知識を取得できます。

- **学習・探索体験:** 日常的な数字を起点に、短時間で新しい知識へアクセス。
- **入力フィードバック:** `0` 以上の整数以外の不正入力を API 呼び出し前に検出し、原因を明示。
- **オフライン耐性:** 通信できない場合は最後に保存した結果を表示し、ネットワーク断による体験の中断を抑制。
- **状態の可視化:** 初期・読み込み中・成功・エラーを UI に反映し、操作に対する応答を明確化。

## Architecture Overview

機能単位で `data`・`domain`・`presentation` を分離し、依存方向を内側（ドメイン）へ向けています。Presentation と Domain は具体的な通信・保存実装を知らず、Domain の Repository 契約を通じてデータへアクセスします。

```text
┌──────────────────────────────────────────────────────────────┐
│ Presentation                                                  │
│ NumberTriviaPage / Widgets / NumberTriviaBloc                │
│  Event ───────────────► UseCase 呼び出し ───────► State       │
└──────────────────────────────┬───────────────────────────────┘
                               │ depends on abstraction
                               ▼
┌──────────────────────────────────────────────────────────────┐
│ Domain                                                       │
│ NumberTrivia Entity / Repository interface / UseCases        │
│  Result<NumberTrivia, Failure>                               │
└──────────────────────────────┬───────────────────────────────┘
                               ▲ implements (DIP)
                               │
┌──────────────────────────────┴───────────────────────────────┐
│ Data                                                         │
│ Repository implementation                                    │
│  ├─ RemoteDataSource ── Dio ── Number Trivia REST API         │
│  └─ LocalDataSource  ── SharedPreferences ── last result     │
└──────────────────────────────────────────────────────────────┘

実行時のデータフロー:
User action → Bloc Event → InputConverter → UseCase
→ Repository → Network/Cache → Result → Bloc State → UI
```

## Key Technical Highlights

| 判断 | 選択 | 選択理由 |
| --- | --- | --- |
| 状態管理 | `flutter_bloc` | Event と State の境界が明確で、入力検証・非同期処理・UI 状態を個別にテストできる。レガシーな `mapEventToState` ではなく `on<Event>` を使用。 |
| エラー表現 | Dart 3 `sealed class Result<S, E>` | `dartz` の Either に依存せず、`Success` / `FailureResult` をコンパイル時に限定。パターンマッチングで成功・失敗の分岐漏れを把握しやすい。 |
| 依存性注入 | `get_it` | Repository の契約と実装を実行時に差し替えられ、テストではモックを注入できる。BLoC は `registerFactory`、共有サービスは `registerLazySingleton` とライフサイクルを分離。 |
| ネットワーク | `Dio` | HTTP クライアントを Data 層へ閉じ込め、Remote DataSource を差し替え可能にした。 |
| ローカル保存 | `SharedPreferences` | 最後の Number Trivia の軽量キャッシュに適しており、通信断時のフォールバックを実装できる。 |
| 値の比較 | `Equatable` | Entity・Event・State の値比較を定義し、BLoC テストと状態遷移の検証を安定させる。 |

### 採用候補との位置づけ

現在のコードベースでは `Freezed`、`Retrofit`、`Riverpod`、Codemagic、Sentry は未導入です。モデル生成・型安全な API 定義・コンパイル時 DI・リリース監視を拡張する場合は、以下の方針で段階的に導入します。

- **Freezed / `json_serializable`:** ネストした immutable model と `copyWith` が増えた段階で導入し、手書き変換コードの保守コストを削減。
- **Retrofit:** エンドポイント数が増えた段階で API 宣言を集約し、DataSource の HTTP ボイラープレートを削減。
- **Riverpod:** GetIt の実行時サービスロケータから移行する場合は、provider graph による依存関係の可視化と compile-time に近い安全性を優先。
- **Codemagic / Fastlane / Sentry:** リリース運用を開始する段階で CI/CD、署名、クラッシュ監視をパイプラインへ追加。

## Engineering Challenges & Troubleshooting

### 1. Either 依存を外し、Result の型安全性を高める

| 段階 | 内容 |
| --- | --- |
| **Problem** | 成功値と失敗値を非同期処理で扱う際、例外と戻り値の境界が曖昧になると、UI 層の分岐が複雑化する。 |
| **Root Cause** | プロジェクト固有の失敗表現が処理箇所ごとに分散すると、Failure の取り扱い漏れと型キャストの増加を招く。 |
| **Solution** | Dart 3 の `sealed class Result<S, E>` と `Success` / `FailureResult` を共通型として定義し、BLoC では `switch` パターンマッチングで状態へ変換。`dartz` には依存しない構成にした。 |
| **Impact** | Repository、UseCase、BLoC の契約が `Result<NumberTrivia, Failure>` に統一され、通信成功・サーバー失敗・キャッシュ失敗を同じ境界でテストできる。 |

### 2. UI の入力検証と非同期状態遷移を分離する

| 段階 | 内容 |
| --- | --- |
| **Problem** | 数字入力の失敗を API エラーとして扱うと、不正入力でも不要な通信が発生し、ユーザーが原因を判断しにくい。 |
| **Root Cause** | Presentation から直接データ取得を行うと、入力変換・ユースケース実行・画面表示が一つの処理へ集中する。 |
| **Solution** | `InputConverter` で `0` 以上の整数へ変換し、失敗時は API を呼ばず `Loading → Error` を明示。正常値だけを `Params` として UseCase へ渡し、BLoC は `Empty / Loading / Loaded / Error` を出力する。 |
| **Impact** | 入力エラーをサーバー障害と区別でき、不要な通信を抑制。UseCase と BLoC をモックで独立検証できるため、仕様変更時の回帰範囲も限定できる。 |

### 3. 通信断でも最後の結果を保持する

| 段階 | 内容 |
| --- | --- |
| **Problem** | 電波の弱い環境や一時的な通信断では、毎回エラー画面になると直前に取得した知識まで失われたように感じられる。 |
| **Root Cause** | リモート取得だけに依存すると、ネットワーク状態とデータの可用性を分離できない。 |
| **Solution** | `NetworkInfo` で接続状態を確認し、オンライン時は取得結果を `SharedPreferences` に保存。オフライン時は最後のキャッシュを返し、キャッシュがない場合だけ `CacheFailure` として通知する。 |
| **Impact** | 通信状態に応じた明示的なフォールバックが可能になり、アプリ起動直後や移動中でも直前の結果を再利用できる。 |

## Testing Strategy & DevOps Pipeline

### テスト戦略

テスト対象を責務ごとに分割し、外部 API や端末ストレージをモック化します。

| レイヤー | 検証内容 | 使用技術 |
| --- | --- | --- |
| Core | 入力変換、接続状態、DI 初期化 | `flutter_test`、`mocktail` |
| Domain | Concrete / Random UseCase が Repository 契約を正しく呼ぶこと | `flutter_test`、モック Repository |
| Data | JSON Model、Remote / Local DataSource、キャッシュ分岐 | `flutter_test`、Dio / SharedPreferences のモック |
| Presentation | BLoC の `Empty → Loading → Loaded/Error` と入力エラー | `bloc_test` 相当の BLoC テスト、`mocktail` |

現時点ではカバレッジ率を CI の合格基準として固定していません。リリース運用へ移行する際は `flutter test --coverage` を Codemagic の PR チェックに追加し、UseCase・Repository・BLoC の主要分岐を測定可能な品質ゲートにします。

### CI/CD とモニタリングの拡張フロー

```text
Pull Request
    │
    ├─ flutter pub get
    ├─ dart analyze
    ├─ flutter test --coverage
    └─ (release) Codemagic build
                    ├─ Android / iOS artifact
                    ├─ Fastlane / App Store Connect 配布
                    └─ Sentry CLI: dSYM / ProGuard mapping upload
                               │
                               └─ crash / performance monitoring
```

Codemagic、Fastlane、Sentry は本リポジトリの現行構成では導入前の拡張候補です。導入時には、PR 検証とリリース署名を分離し、難読化解除ファイルのアップロード失敗を成功扱いにしないパイプラインを構築します。

## Getting Started

### 前提条件

- Flutter SDK（Dart `^3.13.1` を満たすバージョン）
- Android Studio または Xcode（対象プラットフォームで実行する場合）

### セットアップと実行

```bash
git clone https://github.com/SuHwanYoon/Clean-Architecture-Number-Trivia-App.git
cd Clean-Architecture-Number-Trivia-App

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

生成コードを使用しない状態でも `build_runner` は開発依存として実行可能です。Freezed や `json_serializable` のモデル生成を導入した場合は、同じコマンドをコード生成ステップとして継続利用します。

### 主なディレクトリ

```text
lib/
├── core/                         # Result、Failure、NetworkInfo、共通 UseCase
├── features/number_trivia/
│   ├── data/                     # DataSource、Model、Repository 実装
│   ├── domain/                   # Entity、Repository 契約、UseCase
│   └── presentation/             # Page、Widget、BLoC
├── injection_container.dart      # GetIt による依存性登録
└── main.dart                     # アプリエントリーポイント
test/                             # Core / Data / Domain / Presentation テスト
```

## License

本リポジトリのライセンス条件は、GitHub リポジトリの設定に従います。
