List<double> rgbToHsv(int r, int g, int b) {
  double rf = r / 255.0;
  double gf = g / 255.0;
  double bf = b / 255.0;
  double maxc = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
  double minc = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
  double delta = maxc - minc;
  double h = 0;

  if (delta != 0) {
    if (maxc == rf) {
      h = 60 * (((gf - bf) / delta) % 6);
    } else if (maxc == gf) {
      h = 60 * (((bf - rf) / delta) + 2);
    } else {
      h = 60 * (((rf - gf) / delta) + 4);
    }
  }

  double s = maxc == 0 ? 0 : delta / maxc;
  double v = maxc;

  if (h < 0) h += 360;

  return [h, s, v];
}