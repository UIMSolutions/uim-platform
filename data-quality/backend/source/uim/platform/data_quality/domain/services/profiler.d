/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: column profiling — completeness, uniqueness, type
/// detection, numeric/lexical range, lengths, top values and value
/// patterns ("A" upper case letter, "a" lower case letter, "9" digit).
module uim.platform.data_quality.domain.services.profiler;

import std.uni : isUpper, isLower, isAlpha;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum size_t maxPatternLength = 24;

class DataProfiler {
  /// One ColumnStats per field, in order of first appearance.
  ColumnStats[] profile(const FieldValue[][] records, size_t topN = 5) @trusted {
    string[] order;
    bool[string] seen;
    foreach (fields; records)
      foreach (f; fields)
        if (f.name !in seen) {
          seen[f.name] = true;
          order ~= f.name;
        }
    ColumnStats[] result;
    foreach (name; order)
      result ~= column(name, records, topN);
    return result;
  }

  protected ColumnStats column(string name, const FieldValue[][] records, size_t topN) @trusted {
    ColumnStats s;
    s.fieldName = name;
    s.totalValues = records.length;

    size_t[string] counts;
    size_t[string] patterns;
    size_t[ProfiledType] types;
    string[] firstSeen; // value order for stable top lists
    string[] patternOrder;
    long filled, totalLength;
    long minLen = long.max, maxLen;
    double sum = 0, lo = double.infinity, hi = -double.infinity;
    long numbers;
    string lexMin, lexMax;

    foreach (fields; records) {
      auto v = fieldOf(fields, name).strip;
      if (v.length == 0) {
        s.missingCount++;
        continue;
      }
      filled++;
      if (v !in counts)
        firstSeen ~= v;
      counts[v]++;
      auto p = patternOf(v);
      if (p !in patterns)
        patternOrder ~= p;
      patterns[p]++;
      types[classify(v)]++;

      auto len = cast(long) charLength(v);
      totalLength += len;
      minLen = len < minLen ? len : minLen;
      maxLen = len > maxLen ? len : maxLen;
      double d;
      if (parseNumber(v, d)) {
        numbers++;
        sum += d;
        lo = d < lo ? d : lo;
        hi = d > hi ? d : hi;
      }
      if (lexMin.length == 0 || v < lexMin)
        lexMin = v;
      if (v > lexMax)
        lexMax = v;
    }

    s.distinctCount = counts.length;
    s.duplicateCount = filled - cast(long) counts.length;
    s.completeness = percentage(filled, records.length);
    s.uniqueness = filled == 0 ? 100 : percentage(counts.length, filled);
    s.detectedType = dominantType(types, filled);
    if (filled > 0) {
      s.minLength = minLen;
      s.maxLength = maxLen;
      s.avgLength = roundTo2(cast(double) totalLength / filled);
      s.numeric = (s.detectedType == ProfiledType.integer || s.detectedType == ProfiledType.decimal) && numbers == filled;
      if (s.numeric) {
        s.minValue = numberText(lo);
        s.maxValue = numberText(hi);
        s.mean = roundTo2(sum / numbers);
      } else {
        s.minValue = clip(lexMin, 80);
        s.maxValue = clip(lexMax, 80);
      }
    }
    s.topValues = top(counts, firstSeen, topN);
    s.patterns = top(patterns, patternOrder, topN);
    return s;
  }

  /// Shape of a value: letters → A / a, digits → 9, others kept.
  static string patternOf(string value) {
    string p;
    size_t n;
    foreach (dchar c; value) {
      if (n++ == maxPatternLength)
        return p ~ "…";
      if (c >= '0' && c <= '9')
        p ~= '9';
      else if (isAlpha(c))
        p ~= isUpper(c) ? 'A' : 'a';
      else
        p ~= c;
    }
    return p;
  }

  static ProfiledType classify(string v) @trusted {
    import std.uni : toLower;

    double d;
    auto lower = v.toLower;
    if (lower == "true" || lower == "false" || lower == "yes" || lower == "no")
      return ProfiledType.boolean;
    if (isIntegerText(v))
      return ProfiledType.integer;
    if (parseNumber(v, d) && !isPhoneText(v))
      return ProfiledType.decimal;
    if (isDateText(v))
      return ProfiledType.date;
    if (isEmailText(v))
      return ProfiledType.email;
    if (isPhoneText(v))
      return ProfiledType.phone;
    return ProfiledType.text;
  }

  protected static ProfiledType dominantType(size_t[ProfiledType] types, long filled) @trusted {
    if (filled == 0)
      return ProfiledType.empty;
    // integers mixed with decimals are decimals
    auto numeric = types.get(ProfiledType.integer, 0) + types.get(ProfiledType.decimal, 0);
    if (types.get(ProfiledType.decimal, 0) > 0 && numeric * 10 >= filled * 9)
      return ProfiledType.decimal;
    ProfiledType best = ProfiledType.text;
    size_t bestCount;
    foreach (t, n; types)
      if (n > bestCount || (n == bestCount && t < best)) {
        best = t;
        bestCount = n;
      }
    return bestCount * 10 >= filled * 8 ? best : ProfiledType.mixed;
  }

  protected static string[] top(size_t[string] counts, string[] order, size_t n) @trusted {
    auto keys = order.dup;
    keys.sort!((a, b) => counts[a] > counts[b], SwapStrategy.stable);
    string[] result;
    foreach (k; keys[0 .. (n < keys.length ? n : keys.length)])
      result ~= clip(k, 60) ~ " (" ~ counts[k].to!string ~ ")";
    return result;
  }

  protected static bool isIntegerText(string v) pure {
    auto s = v.length && (v[0] == '-' || v[0] == '+') ? v[1 .. $] : v;
    if (s.length == 0 || s.length > 18)
      return false;
    foreach (c; s)
      if (c < '0' || c > '9')
        return false;
    return !(s.length > 1 && s[0] == '0'); // "0049…" is no number (phone, postal code)
  }

  protected static bool isDateText(string v) pure {
    static bool shape(string v, string s) {
      if (v.length != s.length)
        return false;
      foreach (i, c; s)
        if (c == '9' ? !(v[i] >= '0' && v[i] <= '9') : v[i] != c)
          return false;
      return true;
    }

    auto day = v.length >= 10 ? v[0 .. 10] : v;
    auto rest = v.length > 10 ? v[10 .. $] : "";
    if (rest.length && rest[0] != 'T' && rest[0] != ' ')
      return false;
    return shape(day, "9999-99-99") || shape(day, "99.99.9999") || shape(day, "99/99/9999");
  }

  protected static bool isEmailText(string v) pure {
    auto at = v.indexOf('@');
    return at > 0 && at == v.lastIndexOf('@') && v.indexOf('.', at) > at + 1 && v[$ - 1] != '.' && v.indexOf(' ') < 0;
  }

  protected static bool isPhoneText(string v) pure {
    size_t digits;
    bool separators;
    foreach (i, c; v) {
      if (c >= '0' && c <= '9')
        digits++;
      else if (c == ' ' || c == '-' || c == '(' || c == ')' || c == '/' || (c == '+' && i == 0))
        separators = true;
      else
        return false;
    }
    return digits >= 6 && digits <= 15 && (separators || (v.length && v[0] == '0'));
  }

  protected static double roundTo2(double v) {
    import std.math : round;

    return round(v * 100.0) / 100.0;
  }

  protected static string numberText(double d) {
    return d == cast(long) d && d < 1e15 && d > -1e15 ? (cast(long) d).to!string : format("%.4g", d);
  }
}

///
unittest {
  auto p = new DataProfiler;
  auto stats = p.profile([
    [FieldValue("id", "1"), FieldValue("email", "a@x.de"), FieldValue("amount", "10.5"), FieldValue("since", "2026-01-01")],
    [FieldValue("id", "2"), FieldValue("email", "b@x.de"), FieldValue("amount", "3")],
    [FieldValue("id", "3"), FieldValue("email", "a@x.de"), FieldValue("amount", "7"), FieldValue("phone", "+49 30 1234567")],
    [FieldValue("id", "4"), FieldValue("email", "")]
  ]);
  assert(stats.length == 5 && stats[0].fieldName == "id" && stats[4].fieldName == "phone");
  auto id = stats[0];
  assert(id.detectedType == ProfiledType.integer && id.numeric && id.minValue == "1" && id.maxValue == "4" && id.mean == 2.5);
  assert(id.completeness == 100 && id.uniqueness == 100);
  auto email = stats[1];
  assert(email.detectedType == ProfiledType.email && email.missingCount == 1 && email.completeness == 75);
  assert(email.distinctCount == 2 && email.duplicateCount == 1 && email.topValues[0] == "a@x.de (2)");
  assert(email.patterns[0] == "a@a.aa (3)");
  assert(stats[2].detectedType == ProfiledType.decimal && stats[2].maxValue == "10.5");
  assert(stats[3].detectedType == ProfiledType.date && stats[4].detectedType == ProfiledType.phone);
  assert(DataProfiler.classify("0049301234") == ProfiledType.phone && DataProfiler.classify("Yes") == ProfiledType.boolean);
  assert(DataProfiler.patternOf("AB-12cd") == "AA-99aa");
}
