import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../utils/exceptions.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'users';

  UserRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create or update user
  Future<void> saveUser(User user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw UserException('Failed to save user data: ${e.toString()}');
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (!doc.exists) return null;
      return User.fromMap(doc.data()!);
    } catch (e) {
      throw UserException('Failed to fetch user data: ${e.toString()}');
    }
  }

  // Update user fields
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw UserException('Failed to update user data: ${e.toString()}');
    }
  }

  // Update user from model
  Future<void> updateUserFromModel(User user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw UserException('Failed to update user data: ${e.toString()}');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw UserException('Failed to delete user data: ${e.toString()}');
    }
  }

  // Stream user changes
  Stream<User?> getUserStream(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromMap(doc.data()!) : null);
  }
} 