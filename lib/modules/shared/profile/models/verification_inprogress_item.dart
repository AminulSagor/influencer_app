import '../enums/verification_state.dart';

class VerificationInprogressItem {
  final String title;
  final VerificationState state;

  const VerificationInprogressItem({required this.title, required this.state});
}
