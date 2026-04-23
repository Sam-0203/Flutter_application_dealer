class ErrorMessageHelper {
  static String userMessage(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    var message = error.toString().trim();

    if (message.isEmpty || message.toLowerCase() == 'null') {
      return fallback;
    }

    message = message.replaceFirst(
      RegExp(r'^[A-Za-z0-9_<> ]*(Exception|Error):\s*'),
      '',
    );

    return message.isEmpty ? fallback : message;
  }
}
