bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}
bool isValidContact(String contact) {
  final RegExp contactRegex = RegExp(r'^[0-9]{10}$');
  return contactRegex.hasMatch(contact);
}
