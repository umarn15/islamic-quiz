import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamicquiz/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    await user.updateDisplayName(displayName);

    final userModel = UserModel(
      uid: user.uid,
      email: email,
      displayName: displayName,
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

    return userModel;
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return await getUserData(credential.user!.uid);
  }

  /// Get user data from Firestore
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      // Create user document if it doesn't exist (edge case)
      final user = _auth.currentUser!;
      final userModel = UserModel(
        uid: uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
      await _firestore.collection('users').doc(uid).set(userModel.toMap());
      return userModel;
    }

    return UserModel.fromMap(doc.data()!, uid);
  }

  /// Update user points and level
  Future<UserModel> updatePoints(String uid, int pointsToAdd) async {
    final userDoc = _firestore.collection('users').doc(uid);
    
    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final currentData = snapshot.data() ?? {};
      
      final currentPoints = currentData['points'] ?? 0;
      final newPoints = currentPoints + pointsToAdd;
      final newLevel = UserModel.calculateLevel(newPoints);
      final quizzesCompleted = (currentData['quizzesCompleted'] ?? 0) + 1;

      transaction.update(userDoc, {
        'points': newPoints,
        'level': newLevel,
        'quizzesCompleted': quizzesCompleted,
      });

      return UserModel.fromMap({
        ...currentData,
        'points': newPoints,
        'level': newLevel,
        'quizzesCompleted': quizzesCompleted,
      }, uid);
    });
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
