// create  a BlocObserver to override onChange
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    if (kDebugMode) {
      print('${bloc.runtimeType} $change 😀😀😀');
    }
    super.onChange(bloc, change);
  }
}
