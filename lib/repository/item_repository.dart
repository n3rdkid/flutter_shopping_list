import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_shopping_list/general_providers.dart';
import 'package:flutter_shopping_list/models/item_model.dart';
import 'package:flutter_shopping_list/repository/custom_exception.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_shopping_list/extensions/firebase_firestore_extensions.dart';

final itemRepositoryProvider =
    Provider<ItemRepository>((ref) => ItemRepository(ref.read));

abstract class BaseItemRepository {
  Future<List<Item>> retrieveItems({required String userId});
  Future<String> createItem({required String userId, required Item item});
  Future<void> updateItem({required String userId, required Item item});
  Future<void> deleteItem({required String userId, required String itemId});
}

class ItemRepository implements BaseItemRepository {
  final Reader _read;
  const ItemRepository(this._read);
  @override
  Future<String> createItem(
      {required String userId, required Item item}) async {
    try {
      final docRef = await _read(firebaseFirestoreProvider)
          .userListRef(userId)
          .add(item.toDocument());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> deleteItem(
      {required String userId, required String itemId}) async {
    try {
      final docRef = await _read(firebaseFirestoreProvider)
          .userListRef(userId)
          .doc(itemId)
          .delete();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<Item>> retrieveItems({required String userId}) async {
    try {
      final snap =
          await _read(firebaseFirestoreProvider).userListRef(userId).get();
      return snap.docs.map((doc) => Item.fromDocument(doc)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> updateItem({required String userId, required Item item}) async {
    try {
      final docRef = await _read(firebaseFirestoreProvider)
          .userListRef(userId)
          .doc(item.id)
          .update((item.toDocument()));
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
