/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Column definitions of remote tables and views, written as
/// "NAME:TYPE" or "NAME:TYPE(length)" / "NAME:DECIMAL(15,2)", optionally
/// followed by " key" (e.g. "ORDER_ID:NVARCHAR(10) key").
module uim.platform.datasphere.domain.services.columns;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// SQL types the service understands (HANA names) with an estimated width in bytes.
enum long[string] columnTypeWidths = [
    "NVARCHAR": 2, "VARCHAR": 1, "CHAR": 1, "NCHAR": 2, "INTEGER": 4, "BIGINT": 8, "SMALLINT": 2, "TINYINT": 1,
    "DECIMAL": 16, "DOUBLE": 8, "REAL": 4, "DATE": 4, "TIME": 4, "TIMESTAMP": 8, "BOOLEAN": 1, "VARBINARY": 1, "CLOB": 64,
    "NCLOB": 128, "BLOB": 64
  ];

/// Types usable as measures of analytical datasets and facts.
enum string[] numericColumnTypes = ["DECIMAL", "DOUBLE", "REAL", "INTEGER", "BIGINT", "SMALLINT", "TINYINT"];

struct ColumnDef {
  string name;
  string type;
  int length; /// 0 = default
  int scale;
  bool key;

  /// Estimated bytes per value.
  long widthBytes() const {
    auto w = columnTypeWidths.get(type, 8);
    if ((type.endsWith("CHAR") || type == "VARBINARY") && length > 0)
      return w * length;
    if (type.endsWith("CHAR"))
      return w * 32;
    return w;
  }

  string toText() const {
    auto t = name ~ ":" ~ type;
    if (length > 0)
      t ~= "(" ~ length.to!string ~ (scale > 0 ? "," ~ scale.to!string : "") ~ ")";
    return key ? t ~ " key" : t;
  }
}

/// Parse one definition; throws invalid.
ColumnDef parseColumn(string text) {
  auto t = text.strip;
  ColumnDef c;
  auto lower = t.toLower;
  if (lower.endsWith(" key")) {
    c.key = true;
    t = t[0 .. $ - 4].strip;
  }
  auto colon = t.indexOf(':');
  if (colon <= 0)
    throw DspException.invalid("Column '" ~ text ~ "' must have the form NAME:TYPE");
  c.name = t[0 .. colon].strip;
  auto type = t[colon + 1 .. $].strip.toUpper;
  auto open = type.indexOf('(');
  if (open >= 0) {
    if (!type.endsWith(")"))
      throw DspException.invalid("Column '" ~ text ~ "': missing ')'");
    auto args = type[open + 1 .. $ - 1].split(",");
    type = type[0 .. open].strip;
    try {
      c.length = args[0].strip.to!int;
      if (args.length > 1)
        c.scale = args[1].strip.to!int;
    } catch (Exception)
      throw DspException.invalid("Column '" ~ text ~ "': length and scale must be numbers");
    requireRange(c.length, 1, 5000, "Length of column '" ~ c.name ~ "'");
    requireRange(c.scale, 0, c.length, "Scale of column '" ~ c.name ~ "'");
  }
  c.type = type;
  if (!isValidId(c.name))
    throw DspException.invalid("Column name '" ~ c.name ~ "' is invalid");
  if (c.type !in columnTypeWidths)
    throw DspException.invalid("Column '" ~ c.name ~ "': unknown type '" ~ c.type ~ "' (allowed: "
        ~ columnTypeWidths.keys.sort.join(", ") ~ ")");
  return c;
}

/// Parse all definitions; names must be unique.
ColumnDef[] parseColumns(const string[] texts) {
  ColumnDef[] columns;
  bool[string] seen;
  foreach (t; texts) {
    if (t.strip.length == 0)
      continue;
    auto c = parseColumn(t);
    if (c.name.toUpper in seen)
      throw DspException.invalid("Column '" ~ c.name ~ "' is defined twice");
    seen[c.name.toUpper] = true;
    columns ~= c;
  }
  return columns;
}

/// Estimated bytes of one row (at least 16 for an empty definition).
long estimateRowBytes(const string[] texts) {
  long total;
  try
    foreach (c; parseColumns(texts))
      total += c.widthBytes;
  catch (DatasphereException)
    return 64;
  return total > 0 ? total : 16;
}

///
unittest {
  auto c = parseColumn("ORDER_ID:nvarchar(10) key");
  assert(c.name == "ORDER_ID" && c.type == "NVARCHAR" && c.length == 10 && c.key && c.widthBytes == 20);
  assert(c.toText == "ORDER_ID:NVARCHAR(10) key");
  auto d = parseColumn("NET:DECIMAL(15,2)");
  assert(d.length == 15 && d.scale == 2 && !d.key);
  assert(failsWith(DspErrorKind.invalid, () { parseColumn("NET"); }));
  assert(failsWith(DspErrorKind.invalid, () { parseColumn("NET:MONEY"); }));
  assert(failsWith(DspErrorKind.invalid, () { parseColumns(["A:INTEGER", "a:BIGINT"]); }));
  assert(estimateRowBytes(["A:INTEGER", "B:BIGINT"]) == 12 && estimateRowBytes([]) == 16);
}
