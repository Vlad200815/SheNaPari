# MVVM + BLoC Architecture Guide

> A practical reference for the custom base-class layer that wraps `flutter_bloc` in this project.  
> Read this before touching any screen, ViewModel, or event.

---

## Table of Contents

1. [Big Picture](#1-big-picture)
2. [The Five Core Types](#2-the-five-core-types)
3. [Communication Channels](#3-communication-channels)
4. [Lifecycle Hooks](#4-lifecycle-hooks)
5. [Utilities Reference](#5-utilities-reference)
6. [UseCase Contracts](#6-usecase-contracts)
7. [Error Handling Pipeline](#7-error-handling-pipeline)
8. [Creating a New Screen — Step by Step](#8-creating-a-new-screen--step-by-step)
9. [Full Data-Flow Diagram](#9-full-data-flow-diagram)
10. [Folder Map](#10-folder-map)

---

## 1. Big Picture

The app uses a **MVVM architecture** where the "ViewModel" is a standard BLoC.  
A thin custom layer on top of flutter_bloc gives every screen:

- A **typed, consistent contract** between UI and logic (`ViewAction`, `ViewState`, `ViewEvent`).
- **Lifecycle awareness** (`onInit`, `onResume`, `onStop`, `onDestroy`).
- **Automatic loading / error overlays** that any ViewModel can trigger with one line.
- **Cross-screen messaging** via a global `EventBus` and `GlobalAction`.

There are **three widget base classes** and **one bloc base class**, each with four generic type parameters that must match:

```
BasePage / BaseView / BaseApplication
    VM  →  your ViewModel class
    VS  →  your ViewState class
    VE  →  your ViewEvent class
    VA  →  your ViewAction class
```

---

## 2. The Five Core Types

### 2.1 `ViewState` — What the UI renders

```dart
// lib/src/core/base_view_state.dart
abstract class ViewState extends Equatable {}
```

One concrete subclass per screen.  
Every field that drives a rebuild goes here.  
`Equatable` prevents unnecessary BlocBuilder rebuilds.

```dart
// Example
final class PhoneAuthState extends ViewState {
  final bool isLoading;
  final String? errorMessage;

  const PhoneAuthState({this.isLoading = false, this.errorMessage});

  @override
  List<Object?> get props => [isLoading, errorMessage];
}
```

---

### 2.2 `ViewAction` — What the UI sends to the ViewModel

```dart
// lib/src/core/base_view_action.dart
abstract class ViewAction extends Equatable {}
```

Treat these as **commands** — one class per user interaction.  
Three built-in subtypes exist and are handled automatically:

| Built-in Action | When it fires |
|---|---|
| `InitialViewAction` | Immediately when the screen is created (carries route `uri`, `pathParameters`, `extra`) |
| `ErrorViewAction` | When a `ViewEvent` of type `ErrorViewEvent` is posted |
| `GlobalAction<T>` | When another screen broadcasts via `appEventBus` |

Custom actions extend your screen's `ViewAction` subclass:

```dart
// phone_auth_action.dart
class PhoneAuthAction extends ViewAction {}

final class OnClearInputButtonPressedAction extends PhoneAuthAction {
  final TextEditingController phoneNumberController;
  OnClearInputButtonPressedAction({required this.phoneNumberController});
}
```

---

### 2.3 `ViewEvent` — What the ViewModel sends back to the UI (one-shot)

```dart
// lib/src/core/base_view_event.dart
abstract class ViewEvent extends Equatable {}
```

These are **side-effects** — navigation, snackbars, dialogs. They do **not** trigger a rebuild.  
Three built-in events are handled by `BasePage` transparently:

| Built-in Event | Effect |
|---|---|
| `LoadingViewEvent(show: true/false)` | Shows / hides the full-screen loading overlay |
| `MessageViewEvent(text)` | Shows a snackbar with the given text |
| `ErrorViewEvent(exception, type, message)` | Shows the error overlay + optional snackbar |

Custom events extend your screen's `ViewEvent` subclass. Use `sealed class` so the `switch` in `handleEvent` is exhaustive:

```dart
// phone_auth_event.dart
sealed class PhoneAuthEvent extends ViewEvent {}

final class OpenTermsOfUsePage extends PhoneAuthEvent {}
final class OpenPrivacyPolicyPage extends PhoneAuthEvent {}
```

---

### 2.4 `BaseViewModel` — Business logic (extends `Bloc`)

```dart
// lib/src/core/base_view_model.dart
abstract class BaseViewModel<VS, VE, VA> extends Bloc<ViewAction, VS>
```

Override these three hook methods — **do not** call `on()` in the constructor:

| Method | Purpose |
|---|---|
| `onViewCreate(emitter, uri, pathParams, extra)` | First entry point. Register all `on<VA>()` handlers here. |
| `onViewAction(action, emitter)` | Catch-all for any `VA` action not registered individually. |
| `onAppAction(globalAction, emitter)` | Receives actions broadcast app-wide via `EventBus`. |
| `onErrors(emitter, exception, type, message)` | Override to react to errors in the ViewModel itself. |

Three helper methods post events back to the UI:

```dart
loading(true);               // shows full-screen spinner
message("Saved!");           // shows snackbar
postEvent(MyEvent(), emit);  // sends a custom ViewEvent
setThrowable(exception);     // classifies + posts ErrorViewEvent automatically
```

**Registration pattern** — always inside `onViewCreate`:

```dart
@override
Future<void> onViewCreate(emitter, uri, pathParams, extra) async {
  on<OnClearInputButtonPressedAction>(_handleClear);
  on<OnTermsOfUseHyperTextPressedAction>(_handleTerms);
}

Future<void> _handleClear(
  OnClearInputButtonPressedAction action,
  Emitter<PhoneAuthState> emit,
) async {
  action.phoneNumberController.clear();
}
```

---

### 2.5 `BasePage` — The screen widget (StatefulWidget)

```dart
// lib/src/core/base_page.dart
abstract class BasePage<VM, VS, VE, VA> extends StatefulWidget
    implements BaseWidgetLifecycle
```

Implement these three methods on every screen:

```dart
// 1. Provide the ViewModel instance
PhoneAuthViewModel viewModelProvider(uri, pathParams, extra) =>
    PhoneAuthViewModel();

// 2. Build the screen UI from state
Widget createView(BuildContext context, PhoneAuthState state) { ... }

// 3. Handle one-shot events from the ViewModel
void handleEvent(BuildContext context, PhoneAuthEvent event) {
  switch (event) {
    case OpenTermsOfUsePage _: TermsOfUsePage.open(context);
    case OpenPrivacyPolicyPage _: PrivacyPolicyPage.open(context);
  }
}
```

Optional overrides:

```dart
Widget createErrorView(context, state, exception, message, type) { ... }
Widget createLoadingView(context, progress) { ... }
List<Widget> backgroundView(context, state) => [];   // layers behind createView
bool get isWantKeepAlive => false;                   // keep page alive in tabs
bool get isShowErrorMessage => false;                // auto-snackbar on errors
bool onBackInvokedDispatcher(stopDefault, info) => false;
```

---

## 3. Communication Channels

There are **three separate channels** between the UI and ViewModel:

```
  ┌──────────────────────────────────────────────────────────────────┐
  │                          UI  (BasePage)                          │
  └──────┬───────────────────────┬──────────────────────────────────┘
         │ postAction(VA)        │ handleEvent(VE)
         │ add() → Bloc          │ LiveData<ViewEvent?>.stream
         ↓                       ↑
  ┌──────────────────────────────────────────────────────────────────┐
  │                       ViewModel (Bloc)                           │
  │   onViewAction(VA) ─────────────────────────────────────────>   │
  │   emit(VS) ──────────────────── BlocBuilder rebuild ─────────>  │
  │   postEvent(VE) / loading() / message() ─────────────────────>  │
  └──────────────────────────────────────────────────────────────────┘
```

| Channel | Direction | Mechanism | Use for |
|---|---|---|---|
| `postAction(context, action)` | UI → VM | `context.read<VM>().add(action)` | User interactions |
| `emit(newState)` | VM → UI | BlocBuilder | Data / UI state updates |
| `postEvent(event, emitter)` | VM → UI | `LiveData.events` stream | Navigation, dialogs, one-shot side-effects |

### Global cross-screen channel

```dart
// Broadcast from anywhere
appEventBus.post(GlobalAction(myData));

// Received in every active BasePage automatically via subscription in onInit()
// Override onAppAction() in the ViewModel to react
```

---

## 4. Lifecycle Hooks

`BasePage` implements `BaseWidgetLifecycle`. These hooks fire at the right moment — you never call them manually:

```dart
// lib/src/core/base_widget_lifecycle.dart
abstract class BaseWidgetLifecycle {
  void onInit(BuildContext context);      // first build, after BLoC is ready
  Widget onCreateView(BuildContext context); // builds the widget tree
  void onResume(BuildContext context);    // returned to this screen (GoRouter)
  void onStop(BuildContext context);      // app goes to background
  void onDestroy();                       // widget disposed
}
```

Execution order for a normal screen open:

```
onCreateView → onInit → onResume
                              ↓ (user navigates away and back)
                           onResume
                              ↓ (user minimises app)
                           onStop → onResume (when foregrounded)
                              ↓ (screen popped from stack)
                           onDestroy
```

`BasePage` also subscribes to `appEventBus` in `onInit` and unsubscribes in `onDestroy` automatically.

---

## 5. Utilities Reference

### `LiveData<T>` — Reactive state holder

```dart
// lib/src/core/utils/live_data.dart
```

A lifecycle-aware stream wrapper. ViewModel holds one internal instance (`events`) for side-effect events.

```dart
liveData.value = newValue;         // push a new value
liveData.patch((v) => v.count++); // mutate current value in-place
liveData.transform((v) => v * 2); // replace with a derived value
liveData.tick();                   // re-emit the same value (force re-render)
liveData.listen((v) { ... });      // subscribe
```

Attach child `LiveData` nodes to a parent (auto-closed together):

```dart
final child = attach(parent, initialValue, name: 'child');
```

---

### `Debounce` — Prevent rapid repeated calls

```dart
// lib/src/core/utils/debounce.dart
Debounce.run("search-key", Duration(milliseconds: 400), () {
  // fires only after 400 ms of silence
});
Debounce.cancel("search-key");
```

---

### `EventBus` — App-wide broadcast

```dart
// lib/src/core/utils/event_bus.dart
final appEventBus = EventBus(); // singleton in base_application.dart

appEventBus.post(GlobalAction(data));          // fire
appEventBus.on<GlobalAction>().listen((e) {}); // subscribe
```

---

### `BaseMapper<T, R>` — Data ↔ Domain model conversion

```dart
// lib/src/core/base_mapper.dart
abstract class BaseMapper<T, R> {
  R mapperTo(T data);       // T (data model) → R (domain model)
  T mapperFrom(R data);     // R → T  (optional, throws by default)
}
```

---

### `BaseViewHolder<T>` — Typed list-item widget

```dart
// lib/src/core/base_view_holder.dart
class ProductViewHolder extends BaseViewHolder<Product> {
  const ProductViewHolder(Product data, Function(Product) onClick, {super.key})
      : super(data, onClick);

  @override
  Widget createContent(BuildContext context, Product data) {
    return Text(data.name);
  }
}
```

Wraps the content in an `InkWell` with no splash — tap triggers `onItemClicked(data)`.

---

### `DefaultViews` — Standard overlays

```dart
// lib/src/core/default_views.dart
DefaultViews.loading()        // full-screen semi-transparent spinner
DefaultViews.error(message)   // full-screen dark error panel
```

---

### `ErrorViewHelper` — Exception classification

```dart
// lib/src/core/utils/error_view_helper.dart
ErrorViewHelper.handleError(exception, (event) {
  // event is always an ErrorViewEvent with the right ErrorType
});

ErrorViewHelper.isInternetConnectionError(exception); // bool
ErrorViewHelper.httpErrorMessage(exception);          // user-facing string
ErrorViewHelper.hasHttpCode(exception, 401);          // bool
```

`ErrorType` has three values: `no_internet`, `http`, `other`.

---

## 6. UseCase Contracts

```dart
// lib/src/domain/usecase/usecase.dart
```

The domain layer uses a typed sealed hierarchy so the ViewModel never calls repositories directly.

| Base class | Signature |
|---|---|
| `Procedure` | `Future<void> perform()` |
| `Procedure1<P1>` | `Future<void> perform(P1)` |
| `Procedure2<P1, P2>` | `Future<void> perform(P1, P2)` |
| `Functions<R>` | `Future<R> perform()` |
| `Functions1<P1, R>` | `Future<R> perform(P1)` |
| `Functions2<P1, P2, R>` | `Future<R> perform(P1, P2)` |
| …up to `Functions8` | named params variant |

```dart
// Example: send OTP use case
class SendOtpUseCase extends Functions1<String, bool> {
  final AuthRepository _repo;
  SendOtpUseCase(this._repo);

  @override
  Future<bool> perform(String phoneNumber) => _repo.sendOtp(phoneNumber);
}

// In ViewModel
final result = await _sendOtp.perform(phoneNumber);
```

---

## 7. Error Handling Pipeline

```
Exception thrown in ViewModel
        ↓
  setThrowable(e)               ← call this in catch blocks
        ↓
  ErrorViewHelper.handleError() ← classifies the exception
        ↓
  LiveData.events ← ErrorViewEvent(type, message)
        ↓
  BasePage._onReceiveEvents()   ← intercepts the event
        ↓
  Dispatches ErrorViewAction back to Bloc
        ↓
  BlocBuilder triggers _buildErrorWidget()
        ↓
  createErrorView() rendered on screen
  (+ optional snackbar if isShowErrorMessage = true)
```

If you override `onErrors()` in the ViewModel you get notified after the `ErrorViewAction` is dispatched — useful for resetting transient UI state.

---

## 8. Creating a New Screen — Step by Step

Assume you're building `OrderDetailPage`.

**1. State** — `order_detail_state.dart`
```dart
final class OrderDetailState extends ViewState {
  final Order? order;
  const OrderDetailState({this.order});

  @override
  List<Object?> get props => [order];
}
```

**2. Actions** — `order_detail_action.dart`
```dart
class OrderDetailAction extends ViewAction {}

final class OnRefreshPressedAction extends OrderDetailAction {}
final class OnCancelOrderPressedAction extends OrderDetailAction {
  final String orderId;
  OnCancelOrderPressedAction({required this.orderId});
}
```

**3. Events** — `order_detail_event.dart`
```dart
sealed class OrderDetailEvent extends ViewEvent {}

final class OrderCancelledSuccessEvent extends OrderDetailEvent {}
```

**4. ViewModel** — `order_detail_view_model.dart`
```dart
class OrderDetailViewModel
    extends BaseViewModel<OrderDetailState, OrderDetailEvent, OrderDetailAction> {

  OrderDetailViewModel() : super(const OrderDetailState());

  @override
  Future<void> onViewCreate(emitter, uri, pathParams, extra) async {
    on<OnRefreshPressedAction>(_handleRefresh);
    on<OnCancelOrderPressedAction>(_handleCancel);

    final orderId = pathParams['id']!;
    await _loadOrder(orderId, emitter);
  }

  Future<void> _loadOrder(String id, Emitter<OrderDetailState> emit) async {
    loading(true);
    try {
      final order = await _getOrderUseCase.perform(id);
      emit(OrderDetailState(order: order));
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }

  Future<void> _handleRefresh(
      OnRefreshPressedAction action, Emitter<OrderDetailState> emit) async {
    final id = state.order?.id ?? '';
    await _loadOrder(id, emit);
  }

  Future<void> _handleCancel(
      OnCancelOrderPressedAction action, Emitter<OrderDetailState> emit) async {
    loading(true);
    try {
      await _cancelOrderUseCase.perform(action.orderId);
      postEvent(OrderCancelledSuccessEvent(), emit);
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }
}
```

**5. Page** — `order_detail_page.dart`
```dart
class OrderDetailPage
    extends BasePage<OrderDetailViewModel, OrderDetailState,
        OrderDetailEvent, OrderDetailAction> {

  @override
  OrderDetailViewModel viewModelProvider(uri, pathParams, extra) =>
      OrderDetailViewModel();

  @override
  Widget createView(BuildContext context, OrderDetailState state) {
    return Scaffold(
      body: state.order == null
          ? const SizedBox()
          : OrderDetailView(order: state.order!),
    );
  }

  @override
  void handleEvent(BuildContext context, OrderDetailEvent event) {
    switch (event) {
      case OrderCancelledSuccessEvent _:
        context.pop(); // navigate back
    }
  }

  // Navigation helpers
  static const String path = '/orders/:id';
  static const String name = 'OrderDetail';

  static GoRoute route() =>
      Navigation.getRoute(name, path, (state) => OrderDetailPage());

  static Future<Object?> open(BuildContext context, String orderId) =>
      context.push('/orders/$orderId');
}
```

---

## 9. Full Data-Flow Diagram

```
User taps button
      ↓
postAction(context, OnCancelOrderPressedAction(id))
      ↓
context.read<VM>().add(action)           ← Bloc.add()
      ↓
BaseViewModel  on<VA>  handler
      ↓
_handleCancel() runs use case
      ↓
loading(true)  ──────────────────────────────→  LiveData.events
                                                       ↓
                                            _buildLoadingWidget()
                                                       ↓
                                            createLoadingView() appears

use case succeeds
      ↓
loading(false) ──────────────────────────────→  LiveData.events  → overlay gone
      ↓
postEvent(OrderCancelledSuccessEvent(), emit)
      ↓
LiveData.events  →  BasePage._onReceiveEvents()
      ↓
handleEvent(context, OrderCancelledSuccessEvent())
      ↓
context.pop()   ← navigation side-effect executed in Page, not ViewModel

use case fails
      ↓
setThrowable(e)  →  ErrorViewHelper.handleError()
      ↓
LiveData.events  →  ErrorViewEvent(type, message)
      ↓
BasePage._onReceiveEvents()  →  add(ErrorViewAction(...))
      ↓
onErrors() called in ViewModel  +  _buildErrorWidget() rendered
```

---

## 10. Folder Map

```
lib/src/
├── core/                        ← Base classes (read this file's subject)
│   ├── base_page.dart           ← Screen base (StatefulWidget + lifecycle)
│   ├── base_view.dart           ← Sub-view base (StatelessWidget)
│   ├── base_view_model.dart     ← ViewModel / BLoC base
│   ├── base_view_state.dart     ← ViewState base
│   ├── base_view_action.dart    ← ViewAction base + built-ins
│   ├── base_view_event.dart     ← ViewEvent base + built-ins
│   ├── base_view_holder.dart    ← List-item widget base
│   ├── base_widget_lifecycle.dart
│   ├── base_application.dart    ← App-root base (mirrors BasePage)
│   ├── default_views.dart       ← Loading / error overlays
│   ├── fcm_service.dart
│   └── utils/
│       ├── live_data.dart       ← Reactive state holder
│       ├── event_bus.dart       ← Global broadcast channel
│       ├── debounce.dart
│       ├── throttle.dart
│       ├── error_view_helper.dart
│       ├── back_button_interceptor.dart
│       ├── deeplink_handler.dart
│       ├── life_cycle.dart
│       ├── stream_refresh_notifier.dart
│       ├── string_extension.dart
│       └── validators.dart
│
├── data/                        ← Data layer
│   ├── base/
│   │   ├── result.dart          ← Generic API response wrapper Result<T>
│   │   ├── meta.dart
│   │   ├── http_error.dart
│   │   └── pair.dart
│   ├── di/data_locator.dart     ← GetIt registrations for data layer
│   └── storage/
│       ├── remote/              ← Dio + Retrofit API client
│       └── local/               ← SharedPreferences + SQLite/Hive
│
├── domain/                      ← Domain layer
│   ├── usecase/usecase.dart     ← UseCase type hierarchy
│   ├── di/use_case_locator.dart ← GetIt registrations for use cases
│   └── controller/              ← App-level reactive controllers
│
├── presentation/                ← UI layer
│   ├── app/                     ← Root app ViewModel + state
│   ├── resource/                ← Theme, text styles, dimens
│   ├── ui/                      ← Feature screens
│   │   └── <feature>/
│   │       ├── <feature>_page.dart        ← BasePage subclass
│   │       ├── <feature>_view_model.dart  ← BaseViewModel subclass
│   │       ├── <feature>_state.dart       ← ViewState subclass
│   │       ├── <feature>_action.dart      ← ViewAction subclass
│   │       └── <feature>_event.dart       ← ViewEvent subclass
│   └── widgets/                 ← Shared widgets
│
└── app/
    ├── di.dart                  ← Top-level DI setup (GetIt)
    ├── config.dart
    ├── constants.dart
    └── localization.dart
```
