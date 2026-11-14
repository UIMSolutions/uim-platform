/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Kubernetes resource quantities ("500m", "1", "128Mi", "2Gi").
module uim.platform.kyma.domain.types.quantity;

import std.conv : to;
import std.string : strip, endsWith;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Result value for an empty quantity.
enum long quantityUnset = -1;
/// Result value for an invalid quantity.
enum long quantityInvalid = -2;

private bool parseNumber(string s, out double value) {
  if (s.length == 0)
    return false;
  foreach (c; s)
    if (!(c >= '0' && c <= '9') && c != '.')
      return false;
  try {
    value = s.to!double;
    return value >= 0;
  } catch (Exception) {
    return false;
  }
}

/// CPU quantity in millicores: "500m" → 500, "1" → 1000, "0.25" → 250.
long parseCpuMillis(string quantity) {
  auto q = quantity.strip;
  if (q.length == 0)
    return quantityUnset;
  double v;
  if (q.endsWith("m"))
    return parseNumber(q[0 .. $ - 1], v) ? cast(long) v : quantityInvalid;
  return parseNumber(q, v) ? cast(long)(v * 1000) : quantityInvalid;
}

/// Memory quantity in bytes: "128Mi", "1Gi", "500M", "1024".
long parseMemoryBytes(string quantity) {
  auto q = quantity.strip;
  if (q.length == 0)
    return quantityUnset;
  static immutable string[] suffixes = ["Ki", "Mi", "Gi", "Ti", "K", "M", "G", "T"];
  static immutable double[] factors = [
    1024.0, 1024.0 ^^ 2, 1024.0 ^^ 3, 1024.0 ^^ 4, 1e3, 1e6, 1e9, 1e12
  ];
  double v;
  foreach (i, s; suffixes)
    if (q.endsWith(s))
      return parseNumber(q[0 .. $ - s.length], v) ? cast(long)(v * factors[i]) : quantityInvalid;
  return parseNumber(q, v) ? cast(long) v : quantityInvalid;
}

///
unittest {
  assert(parseCpuMillis("500m") == 500);
  assert(parseCpuMillis("1") == 1000);
  assert(parseCpuMillis("0.25") == 250);
  assert(parseCpuMillis("") == quantityUnset);
  assert(parseCpuMillis("abc") == quantityInvalid);
  assert(parseMemoryBytes("128Mi") == 128 * 1024 * 1024);
  assert(parseMemoryBytes("1G") == 1_000_000_000);
  assert(parseMemoryBytes("1x") == quantityInvalid);
}
