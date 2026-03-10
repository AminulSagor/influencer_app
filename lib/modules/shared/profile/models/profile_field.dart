class ProfileField {
  final String label;
  final String hintText;
  final String value;
  final bool isRequired;
  final bool isReadOnly;

  const ProfileField({
    required this.label,
    required this.value,
    this.isRequired = false,
    this.isReadOnly = false,
    required this.hintText,
  });
}
