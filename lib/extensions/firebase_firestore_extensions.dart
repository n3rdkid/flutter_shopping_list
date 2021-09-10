import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

extension FirebaseFirestoreX on FirebaseFirestore {
  CollectionReference userListRef(String userId) =>
      collection("lists").doc(userId).collection("userList");
}
