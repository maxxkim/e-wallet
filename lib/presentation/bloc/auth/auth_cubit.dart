import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part '../../../domain/state/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthCubit(this._firebaseAuth) : super(AuthInitial());

  Future<void> loginWithPhone(String phoneNumber) async {
    try {
      emit(AuthLoading());
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthFailure(e.message));
        },
        codeSent: (String verificationId, int? resendToken) {
// Сохраняем verificationId
          emit(AuthCodeSent(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> verifyCode(String smsCode) async {
  /*
    if (_verificationId == null) {
      print('bad');
      emit(AuthFailure("Verification ID is missing."));
      return;
    }

    try {
      emit(AuthLoading());
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      await _firebaseAuth.signInWithCredential(credential);
      print('good');
      emit(AuthSuccess());
    } catch (e) {
      print('fail ${e.toString()}');
      emit(AuthFailure(e.toString()));
    }
 */
  }
}





