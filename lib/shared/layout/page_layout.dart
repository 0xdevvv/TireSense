abstract final class PageLayout {
  static const maxWidth = 560.0;
  static const margin = 16.0;
  static const listTop = 8.0;
  static const listBottom = 24.0;
  static const cardGap = 12.0;
  static const buttonTop = 8.0;

  static double horizontalInset(double width) {
    final centered = (width - maxWidth) / 2;
    if (centered > margin) {
      return centered;
    }
    return margin;
  }
}
