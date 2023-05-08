# Flutter State Management

This project is an extension of the [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab) tutorial provided by the Flutter team, which generates **random words** that can be favored. This project aims to show how to manage the state of a Flutter app using state management techniques such as `Vanilla Provider` and `BloC`.

<img src="https://github.com/ripplearc/ripplearc.github.io/blob/main/images/Flutter/state-management/generator-screenshots.png" alt="Drawing" style="width: 400px;"/>


## Provider
The vanilla Provider approach involves using the [Provider package](https://pub.dev/packages/provider) to manage the application's state. In this project, we show how to use ChangeNotifier and Consumer to update the app's state. 

```
git checkout tags/appstate
```

## BloC
The [BloC](https://pub.dev/packages/flutter_bloc) (Business Logic Component) approach involves separating the business logic of the app from the UI. In this project, we show how to use BloC to manage the app's state. We use `flutter_bloc` **8.0+** version, which optimizes the event handler convention. The `BloC` state management is on the `main` branch. 

## Unit Tests
We use [bloc_test](https://pub.dev/packages/bloc_test) to write unit tests for `BloC`. 
To run test coverage, try the following:

```
flutter test --coverage; genhtml coverage/lcov.info -o coverage/html; open coverage/html/index.html
```

## Widget and Integration Tests
Widget and Integration tests are another essential part of app development. In this project, we show how to write Widget and Integration tests for the `BloC` approach.

