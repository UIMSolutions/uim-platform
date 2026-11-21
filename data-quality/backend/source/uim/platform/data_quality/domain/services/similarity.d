/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// String similarity measures (on unicode characters).
module uim.platform.data_quality.domain.services.similarity;

import std.uni : isAlpha, uniToUpper = toUpper;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// Jaro-Winkler similarity in [0, 1] (prefix scale 0.1, up to 4 characters).
double jaroWinkler(string s1, string s2) @trusted {
  import std.conv : to;

  auto a = s1.to!dstring;
  auto b = s2.to!dstring;
  if (a.length == 0 && b.length == 0)
    return 1.0;
  if (a.length == 0 || b.length == 0)
    return 0.0;
  if (a == b)
    return 1.0;

  auto longer = a.length > b.length ? a.length : b.length;
  auto window = longer / 2 > 0 ? longer / 2 - 1 : 0;
  auto matchedA = new bool[a.length];
  auto matchedB = new bool[b.length];
  size_t matches;
  foreach (i; 0 .. a.length) {
    auto from = i > window ? i - window : 0;
    auto to_ = i + window + 1 < b.length ? i + window + 1 : b.length;
    foreach (j; from .. to_) {
      if (matchedB[j] || a[i] != b[j])
        continue;
      matchedA[i] = matchedB[j] = true;
      matches++;
      break;
    }
  }
  if (matches == 0)
    return 0.0;

  size_t k, halfTranspositions;
  foreach (i; 0 .. a.length) {
    if (!matchedA[i])
      continue;
    while (!matchedB[k])
      k++;
    if (a[i] != b[k])
      halfTranspositions++;
    k++;
  }
  double m = matches;
  double t = halfTranspositions / 2.0;
  double jaro = (m / a.length + m / b.length + (m - t) / m) / 3.0;

  size_t prefix;
  foreach (i; 0 .. (a.length < b.length ? a.length : b.length)) {
    if (prefix == 4 || a[i] != b[i])
      break;
    prefix++;
  }
  return jaro + prefix * 0.1 * (1.0 - jaro);
}

/// American Soundex ("Robert" → "R163"); "" for text without letters.
string soundex(string s) {
  char[] code;
  char last;
  foreach (dchar raw; removeDiacritics(s)) {
    if (!isAlpha(raw) || raw > 0x7F)
      continue;
    auto c = cast(char) uniToUpper(raw);
    auto digit = soundexDigit(c);
    if (code.length == 0) {
      code ~= c;
      last = digit;
      continue;
    }
    if (c == 'H' || c == 'W') // do not separate equal codes
      continue;
    if (digit != '0' && digit != last)
      code ~= digit;
    last = digit;
    if (code.length == 4)
      break;
  }
  if (code.length == 0)
    return "";
  while (code.length < 4)
    code ~= '0';
  return code.idup;
}

private char soundexDigit(char c) pure {
  switch (c) {
  case 'B', 'F', 'P', 'V':
    return '1';
  case 'C', 'G', 'J', 'K', 'Q', 'S', 'X', 'Z':
    return '2';
  case 'D', 'T':
    return '3';
  case 'L':
    return '4';
  case 'M', 'N':
    return '5';
  case 'R':
    return '6';
  default:
    return '0';
  }
}

/// Soundex of every word, joined by blanks ("Anna Meyer" → "A500 M600").
string soundexWords(string s) {
  string[] codes;
  foreach (w; normalizeForMatch(s).split(" "))
    if (w.length)
      codes ~= soundex(w);
  return codes.join(" ");
}

///
unittest {
  import std.math : isClose;

  assert(jaroWinkler("MARTHA", "MARHTA").isClose(0.9611, 1e-3));
  assert(jaroWinkler("DIXON", "DICKSONX").isClose(0.8133, 1e-3));
  assert(jaroWinkler("", "") == 1 && jaroWinkler("a", "") == 0 && jaroWinkler("abc", "abc") == 1);
  assert(jaroWinkler("Müller", "Muller") > 0.8);
  assert(soundex("Robert") == "R163" && soundex("Rupert") == "R163" && soundex("Ashcraft") == "A261");
  assert(soundex("Tymczak") == "T522" && soundex("Pfister") == "P236" && soundex("123") == "");
  assert(soundexWords("Anna Meyer") == soundexWords("Ana Maier"));
}
