bool isLuminolPixel(double h, double s, double v) {
  bool hueMatch = (h >= 200 && h <= 260);
  bool satMatch = s >= 0.25;
  bool brightMatch = v >= 0.4;

  return hueMatch && satMatch && brightMatch;
}
