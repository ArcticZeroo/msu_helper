class NumberUtil {
  static int doubleToBits(double value) {
    const pow52 = 4503599627370496.0;  // 2^52
    const pow1022 = 4.49423283715579e+307; // 2^1022
    if (value.isNaN) {
      return 0x7FF8000000000000;
    }
    int signbit = 0;
    if (value.isNegative) {
      signbit = 0x8000000000000000;
      value = -value;
    }
    if (value.isInfinite) {
      return signbit | 0x7FF0000000000000;
    } else if (value < 2.2250738585072014e-308) {
      // Denormal or zero.
      // Multiply by 2^(1022+52) to get the bits into the correct position.
      int bits = (value * pow1022 * pow52).toInt();
      return signbit | bits;
    } else {
      // Slow linear search to move bits into correct position for mantissa.
      // Use binary search or something even smarter for speed.
      int exponent = 52;
      while (value < pow52) {
        value *= 2;
        exponent -= 1;
      }
      while (value >= pow52 * 2) {
        value /= 2;
        exponent += 1;
      }
      int mantissaBits = (value - pow52).toInt();
      int exponentBits = (exponent + 1023);
      return signbit | (exponentBits << 52) | mantissaBits;
    }
  }
}