import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

part 'auth_state.g.dart';

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  late final FirebaseService _firebaseService;

  @override
  Stream<User?> build() {
    _firebaseService = FirebaseService();
    
    // Initialize with current user if exists
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      state = AsyncData(User.fromFirebaseUser(currentUser));
    }
    
    // Listen to auth state changes
    return _firebaseService.userStream;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      _firebaseService.signInWithEmailAndPassword(email, password)
    );
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      _firebaseService.registerWithEmailAndPassword(email, password)
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _firebaseService.signOut();
      return null;
    });
  }

  Future<void> refreshUser() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      final freshUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (freshUser != null) {
        state = AsyncData(User.fromFirebaseUser(freshUser));
      }
    }
  }
} 