/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Unicode aware text helpers shared by validation, cleansing, matching
/// and profiling.
module uim.platform.data_quality.domain.services.text;

import std.uni : isWhite, isAlpha, uniToLower = toLower, uniToUpper = toUpper;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// Strict number parsing ("12", "-3.5", "1e3"); false for "", "abc", "nan".
bool parseNumber(string text, out double value) {
  auto t = text.strip;
  if (t.length == 0)
    return false;
  try {
    value = t.to!double;
    return value == value && value != double.infinity && value != -double.infinity;
  } catch (Exception)
    return false;
}

/// Trim and collapse inner runs of white space to one blank.
string collapseWhitespace(string s) {
  string result;
  bool space;
  foreach (dchar c; s.strip) {
    if (isWhite(c)) {
      space = true;
      continue;
    }
    if (space)
      result ~= ' ';
    space = false;
    result ~= c;
  }
  return result;
}

/// "hELLO wORLD-o'neil" → "Hello World-O'Neil"
string titleCase(string s) {
  string result;
  bool start = true;
  foreach (dchar c; s) {
    if (isWhite(c) || c == '-' || c == '\'' || c == '/' || c == '(' || c == '.') {
      result ~= c;
      start = true;
    } else if (isAlpha(c)) {
      result ~= start ? uniToUpper(c) : uniToLower(c);
      start = false;
    } else {
      result ~= c;
      start = false;
    }
  }
  return result;
}

/// Latin diacritics → ASCII ("Müller" → "Muller", "Straße" → "Strasse").
string removeDiacritics(string s) {
  string result;
  foreach (dchar c; s)
    result ~= foldDiacritic(c);
  return result;
}

private string foldDiacritic(dchar c) {
  switch (c) {
  case 'à', 'á', 'â', 'ã', 'ä', 'å', 'ā', 'ą', 'ă':
    return "a";
  case 'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Ā', 'Ą', 'Ă':
    return "A";
  case 'æ':
    return "ae";
  case 'Æ':
    return "AE";
  case 'ç', 'ć', 'č':
    return "c";
  case 'Ç', 'Ć', 'Č':
    return "C";
  case 'ď', 'đ':
    return "d";
  case 'Ď', 'Đ':
    return "D";
  case 'è', 'é', 'ê', 'ë', 'ē', 'ę', 'ě':
    return "e";
  case 'È', 'É', 'Ê', 'Ë', 'Ē', 'Ę', 'Ě':
    return "E";
  case 'ğ':
    return "g";
  case 'Ğ':
    return "G";
  case 'ì', 'í', 'î', 'ï', 'ī', 'ı':
    return "i";
  case 'Ì', 'Í', 'Î', 'Ï', 'Ī', 'İ':
    return "I";
  case 'ł':
    return "l";
  case 'Ł':
    return "L";
  case 'ñ', 'ń', 'ň':
    return "n";
  case 'Ñ', 'Ń', 'Ň':
    return "N";
  case 'ò', 'ó', 'ô', 'õ', 'ö', 'ø', 'ō', 'ő':
    return "o";
  case 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'Ø', 'Ō', 'Ő':
    return "O";
  case 'œ':
    return "oe";
  case 'Œ':
    return "OE";
  case 'ř':
    return "r";
  case 'Ř':
    return "R";
  case 'ś', 'š', 'ş':
    return "s";
  case 'Ś', 'Š', 'Ş':
    return "S";
  case 'ß':
    return "ss";
  case 'ť', 'ţ':
    return "t";
  case 'Ť', 'Ţ':
    return "T";
  case 'ù', 'ú', 'û', 'ü', 'ū', 'ů', 'ű':
    return "u";
  case 'Ù', 'Ú', 'Û', 'Ü', 'Ū', 'Ů', 'Ű':
    return "U";
  case 'ý', 'ÿ':
    return "y";
  case 'Ý', 'Ÿ':
    return "Y";
  case 'ź', 'ż', 'ž':
    return "z";
  case 'Ź', 'Ż', 'Ž':
    return "Z";
  default:
    return [c].to!string;
  }
}

/// Lower case, without diacritics, punctuation and duplicate blanks — the
/// comparison form used by duplicate detection.
string normalizeForMatch(string s) {
  string folded;
  foreach (dchar c; removeDiacritics(s)) {
    if (isAlpha(c) || (c >= '0' && c <= '9'))
      folded ~= uniToLower(c);
    else
      folded ~= ' ';
  }
  return collapseWhitespace(folded);
}

/// Compare two values: numerically if both are numbers, otherwise as text.
/// op: eq ne lt le gt ge (or the symbols == != < <= > >=).
bool compareValues(string a, string op, string b, bool caseSensitive = true) {
  double x, y;
  int order;
  if (parseNumber(a, x) && parseNumber(b, y))
    order = x < y ? -1 : x > y ? 1 : 0;
  else {
    import std.uni : icmp;
    import std.algorithm.comparison : cmp;

    order = caseSensitive ? cmp(a, b) : icmp(a, b);
    order = order < 0 ? -1 : order > 0 ? 1 : 0;
  }
  switch (op) {
  case "eq", "==", "=":
    return order == 0;
  case "ne", "!=", "<>":
    return order != 0;
  case "lt", "<":
    return order < 0;
  case "le", "<=":
    return order <= 0;
  case "gt", ">":
    return order > 0;
  case "ge", ">=":
    return order >= 0;
  default:
    throw DataQualityException.invalid("Unknown comparison operator '" ~ op ~ "'");
  }
}

/// Number of unicode characters.
size_t charLength(string s) {
  size_t n;
  foreach (dchar _; s)
    n++;
  return n;
}

/// Shorten for messages and change logs.
string clip(string s, size_t max = 40) {
  if (charLength(s) <= max)
    return s;
  string result;
  size_t n;
  foreach (dchar c; s) {
    if (n++ >= max)
      break;
    result ~= c;
  }
  return result ~ "…";
}

///
unittest {
  double v;
  assert(parseNumber(" 12.5 ", v) && v == 12.5 && !parseNumber("abc", v) && !parseNumber("", v) && !parseNumber("nan", v));
  assert(collapseWhitespace("  a \t b  ") == "a b");
  assert(titleCase("hELLO wORLD-o'neil") == "Hello World-O'Neil");
  assert(titleCase("münchen") == "München");
  assert(removeDiacritics("Müller Straße") == "Muller Strasse");
  assert(normalizeForMatch("  Jürgen-Müller, GmbH ") == "jurgen muller gmbh");
  assert(compareValues("10", "gt", "9") && !compareValues("10", "gt", "9x"));
  assert(compareValues("abc", "eq", "ABC", false) && !compareValues("abc", "eq", "ABC"));
  assert(charLength("äöü") == 3 && clip("abcdef", 3) == "abc…");
}
