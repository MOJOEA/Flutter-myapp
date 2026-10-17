import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseDbService {
  FirebaseDbService._();

  static final FirebaseDbService instance = FirebaseDbService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อนใช้งาน');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection('users').doc(_uid).collection('test_items');

  Future<void> addItem(String name) async {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError('กรุณากรอกชื่อรายการ');

    await _items.add({
      'name': value,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchItems() =>
      _items.orderBy('createdAt', descending: true).snapshots();

  Future<void> updateItem({
    required String documentId,
    required String name,
  }) async {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError('กรุณากรอกชื่อรายการ');

    final data = <String, dynamic>{
      'name': value,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _items.doc(documentId).update(data);
  }

  Future<void> deleteItem(String documentId) async {
    final docRef = _items.doc(documentId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;
    await docRef.delete();
  }
}
