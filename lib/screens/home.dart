import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_shopping_list/controllers/auth_controller.dart';
import 'package:flutter_shopping_list/repository/custom_exception.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends HookConsumerWidget {
  Widget build(BuildContext ctx, WidgetRef ref) {
    final authControllerState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping List"),
        leading: authControllerState != null
            ? IconButton(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout))
            : null,
      ),
    );
  }
}
