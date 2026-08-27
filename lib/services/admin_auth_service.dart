import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camilo_verde/services/firebase_backend.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  Future<bool> isActiveAdmin([String? uid]) async {
    final document = await FirebaseBackend.firestore
        .collection('admins')
        .doc(uid ?? currentUser?.uid)
        .get();
    final data = document.data();
    return data?['active'] == true;
  }

  Future<bool> isSuperAdmin([String? uid]) async {
    final document = await FirebaseBackend.firestore
        .collection('admins')
        .doc(uid ?? currentUser?.uid)
        .get();
    return document.data()?['role'] == 'superadmin';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> users() =>
      FirebaseBackend.firestore.collection('admins').snapshots();

  Future<void> updateUser(String uid, {required bool active}) =>
      FirebaseBackend.firestore.collection('admins').doc(uid).update({
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
