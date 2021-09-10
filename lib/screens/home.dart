import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_shopping_list/controllers/auth_controller.dart';
import 'package:flutter_shopping_list/controllers/item_list_controllers.dart';
import 'package:flutter_shopping_list/models/item_model.dart';
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
        body: const ItemList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => AddItemDialog.show(ctx, Item.empty()),
          child: const Icon(Icons.add),
        ));
  }
}

class AddItemDialog extends HookConsumerWidget {
  static show(BuildContext ctx, Item item) {
    showDialog(
        context: ctx,
        builder: (_) => AddItemDialog(
              item: item,
            ));
  }

  final Item item;

  AddItemDialog({Key? key, required this.item}) : super(key: key);

  bool get isUpdating => item.id != null;

  Widget build(BuildContext ctx, WidgetRef ref) {
    final textController = useTextEditingController(text: item.name);
    return Dialog(
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            TextField(
              autofocus: true,
              controller: textController,
              decoration: InputDecoration(hintText: 'Enter Item Name here'),
            ),
            SizedBox(
              height: 12,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text(isUpdating ? "Update" : "Create"),
                onPressed: () {
                  isUpdating
                      ? ref
                          .read(itemListControllerProvider.notifier)
                          .updateItem(
                              updatedItem: item.copyWith(
                                  name: textController.text.trim(),
                                  obtained: item.obtained))
                      : ref
                          .read(itemListControllerProvider.notifier)
                          .addItem(name: textController.text.trim());
                  Navigator.of(ctx).pop();
                },
              ),
            ),
          ])),
    );
  }
}

final currentItemProvider = Provider<Item>((_) => throw UnimplementedError());

class ItemList extends HookConsumerWidget {
  const ItemList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemList = ref.watch(itemListControllerProvider);
    return itemList.when(
        data: (items) => items.isEmpty
            ? Center(
                child: Text(
                "Tap + to add an item",
                style: TextStyle(fontSize: 20),
              ))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext ctx, int index) {
                  final item = items[index];
                  return ProviderScope(
                      child: const ItemTile(),
                      overrides: [currentItemProvider.overrideWithValue(item)]);
                }),
        error: (err, _) => ItemListError(
              message: err is CustomException
                  ? err.message!
                  : 'Something Went Wrong',
            ),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}

class ItemListError extends ConsumerWidget {
  final String message;

  const ItemListError({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: const Text('Retry'),
            onPressed: () {
              ref
                  .read(itemListControllerProvider.notifier)
                  .retrieveItems(isRefreshing: true);
            },
          )
        ],
      ),
    );
  }
}

class ItemTile extends HookConsumerWidget {
  const ItemTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(currentItemProvider);
    return ListTile(
        key: ValueKey(item.id),
        title: Text(item.name),
        trailing: Checkbox(
          value: item.obtained,
          onChanged: (_) {
            ref.read(itemListControllerProvider.notifier).updateItem(
                updatedItem: item.copyWith(obtained: !item.obtained));
          },
        ),
        onTap: () => AddItemDialog.show(context, item),
        onLongPress: () => ref
            .read(itemListControllerProvider.notifier)
            .deleteItem(itemId: item.id!));
  }
}
