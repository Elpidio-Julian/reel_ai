import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../utils/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class FirebaseService {
  final firebase_auth.FirebaseAuth _auth;
  final UserRepository _userRepository;

  FirebaseService({
    firebase_auth.FirebaseAuth? auth,
    UserRepository? userRepository,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _userRepository = userRepository ?? UserRepository() {
    // Configure persistence for web platform
    if (kIsWeb) {
      _auth.setPersistence(firebase_auth.Persistence.LOCAL);
      _auth.setSettings(appVerificationDisabledForTesting: true);
    }
  }

  // Get current user
  User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return User.fromFirebaseUser(firebaseUser);
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        final user = User.fromFirebaseUser(result.user!);
        // Fetch additional user data from Firestore
        final userData = await _userRepository.getUserById(user.id);
        return userData ?? user;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException('An unexpected error occurred during sign in');
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        final user = User.fromFirebaseUser(result.user!);
        // Store user data in Firestore
        await _userRepository.saveUser(user);
        return user;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException('An unexpected error occurred during registration');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out');
    }
  }

  // Get user stream
  Stream<User?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      // Force refresh the user data
      await firebaseUser.reload();
      final freshUser = _auth.currentUser;
      if (freshUser == null) return null;

      // Get updated user data from Firestore
      final userData = await _userRepository.getUserById(freshUser.uid);
      return userData ?? User.fromFirebaseUser(freshUser);
    });
  }

  // Update user profile
  Future<User> updateProfile({
    String? displayName,
    File? photoFile,
  }) async {
    try {
      final currentFirebaseUser = _auth.currentUser;
      if (currentFirebaseUser == null) {
        throw AuthException('No user is currently signed in');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await currentFirebaseUser.updateDisplayName(displayName);
      }

      // Update photo if provided
      String? photoUrl;
      if (photoFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_photos')
            .child('${currentFirebaseUser.uid}.jpg');
        
        await storageRef.putFile(photoFile);
        photoUrl = await storageRef.getDownloadURL();
        await currentFirebaseUser.updatePhotoURL(photoUrl);
      }

      // Force refresh the user data
      await currentFirebaseUser.reload();
      final updatedFirebaseUser = _auth.currentUser;
      if (updatedFirebaseUser == null) {
        throw AuthException('User not found after update');
      }

      final updatedUser = User.fromFirebaseUser(updatedFirebaseUser);
      
      // Update Firestore
      await _userRepository.updateUser(updatedUser.id, updatedUser.toMap());
      
      // Notify auth state changes
      _auth.currentUser?.reload();
      
      return updatedUser;
    } catch (e) {
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  String getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'operation-not-allowed':
        return 'This sign in method is not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'A network error occurred. Please check your connection.';
      default:
        return 'An unexpected authentication error occurred.';
    }
  }
} 