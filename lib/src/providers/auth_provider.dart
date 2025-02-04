import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';
import '../models/user.dart';
import '../utils/exceptions.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({FirebaseService? firebaseService}) 
      : _firebaseService = firebaseService ?? FirebaseService() {
    // Listen to auth state changes
    _firebaseService.userStream.listen(
      (user) {
        _currentUser = user;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();
      
      await _firebaseService.signInWithEmailAndPassword(email, password);
    } on AuthException catch (e) {
      _error = e.message;
      rethrow;
    } catch (e) {
      _error = 'An unexpected error occurred';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();
      
      await _firebaseService.registerWithEmailAndPassword(email, password);
    } on AuthException catch (e) {
      _error = e.message;
      rethrow;
    } catch (e) {
      _error = 'An unexpected error occurred';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();
      
      await _firebaseService.signOut();
    } on AuthException catch (e) {
      _error = e.message;
      rethrow;
    } catch (e) {
      _error = 'An unexpected error occurred';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 