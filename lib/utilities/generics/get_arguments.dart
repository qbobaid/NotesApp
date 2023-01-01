import 'package:flutter/material.dart';

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);
    if(modalRoute != null) {
      var args = modalRoute.settings.arguments;
      if(args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}