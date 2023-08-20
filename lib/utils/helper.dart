String shortenString(String text) {
  const int maxLength = 40;

  if (text.length <= maxLength) {
    return text;
  } else {
    return text.substring(0, maxLength) + '...';
  }
}

String formatFirebaseError(error) {
  String errorMessage = error.toString();

  // Find the position of the opening bracket
  int startIndex = errorMessage.indexOf("[");

  // Find the position of the closing bracket
  int endIndex = errorMessage.indexOf("]");

  // Extract the error code substring
  String errorCode = errorMessage.substring(startIndex + 1, endIndex);

  // Find the position of the first space after the closing bracket
  int spaceIndex = errorMessage.indexOf(" ", endIndex);

  // Extract the error message substring
  String extractedErrorMessage = errorMessage.substring(spaceIndex + 1);

  return extractedErrorMessage;
}
