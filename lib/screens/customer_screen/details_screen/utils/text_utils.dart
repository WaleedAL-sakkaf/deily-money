/// Process mixed text (Arabic + English) for proper display
/// Adds LRM (Left-to-Right Mark) before English characters when mixed with Arabic
String processMixedText(String text) {
  // Check for Arabic characters in the text
  bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  // Check for English characters in the text
  bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);

  // If the text contains both Arabic and English characters
  if (hasArabic && hasEnglish) {
    // Add LRM (Left-to-Right Mark) before English characters
    String processedText = text;
    // Add LRM before each group of English characters
    processedText = processedText.replaceAllMapped(
        RegExp(r'[a-zA-Z]+'), (match) => '\u200E${match.group(0)}\u200E');
    return processedText;
  }

  return text;
}
