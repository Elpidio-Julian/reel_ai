import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../utils/exceptions.dart';

class FirebaseService {
  final firebase_auth.FirebaseAuth _auth;
  final UserRepository _userRepository;

  FirebaseService({
    firebase_auth.FirebaseAuth? auth,
    UserRepository? userRepository,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _userRepository = userRepository ?? UserRepository();

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

  // Get user stream that combines Firebase Auth and Firestore data
  Stream<User?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        // Get additional user data from Firestore
        final userData = await _userRepository.getUserById(firebaseUser.uid);
        return userData ?? User.fromFirebaseUser(firebaseUser);
      } catch (e) {
        // If we can't get Firestore data, return basic user info
        return User.fromFirebaseUser(firebaseUser);
      }
    });
  }
} 