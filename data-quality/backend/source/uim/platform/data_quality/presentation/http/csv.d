/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// CSV import (RFC 4180 quoting; ',', ';' or tab separated — detected from
/// the header line). The header names the fields; an "id" column becomes
/// the record id.
module uim.platform.data_quality.presentation.http.csv;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

InlineRecord[] parseCsvRecords(string text, string idColumn = "id") {
  auto rows = parseCsv(text);
  if (rows.length == 0)
    return null;
  auto header = rows[0].map!(h => h.strip).array;
  if (header.length > maxFieldsPerRecord)
    throw DataQualityException.invalid(format("CSV has more than %d columns", maxFieldsPerRecord));
  foreach (h; header)
    if (h != idColumn)
      requireFieldName(h, "CSV column");
  InlineRecord[] records;
  foreach (n, row; rows[1 .. $]) {
    if (row.length == 1 && row[0].strip.length == 0)
      continue; // blank line
    if (row.length > header.length)
      throw DataQualityException.invalid(format("CSV line %d has %d values, the header %d", n + 2, row.length, header.length));
    InlineRecord r;
    foreach (i, value; row) {
      if (header[i] == idColumn)
        r.id = value.strip;
      else
        r.fields ~= FieldValue(header[i], value);
    }
    records ~= r;
  }
  return records;
}

/// Rows of cells.
string[][] parseCsv(string text) {
  auto t = text.startsWith("﻿") ? text[3 .. $] : text;
  auto firstLine = t.indexOf('\n') >= 0 ? t[0 .. t.indexOf('\n')] : t;
  char sep = ',';
  size_t best;
  foreach (char c; [',', ';', '\t'])
    if (firstLine.count(c) > best) {
      best = firstLine.count(c);
      sep = c;
    }

  string[][] rows;
  string[] row;
  string cell;
  bool quoted, atStart = true;
  for (size_t i = 0; i < t.length; i++) {
    auto c = t[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < t.length && t[i + 1] == '"') {
          cell ~= '"';
          i++;
        } else
          quoted = false;
      } else
        cell ~= c;
      continue;
    }
    if (c == '"' && atStart) {
      quoted = true;
      atStart = false;
    } else if (c == sep) {
      row ~= cell;
      cell = "";
      atStart = true;
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < t.length && t[i + 1] == '\n')
        i++;
      row ~= cell;
      rows ~= row;
      row = null;
      cell = "";
      atStart = true;
    } else {
      cell ~= c;
      atStart = false;
    }
  }
  if (cell.length || row.length)
    rows ~= row ~ cell;
  return rows;
}

///
unittest {
  auto r = parseCsvRecords("id;name;city\nc1;\"Müller; Jürgen\";Berlin\r\n\nc2;\"Say \"\"hi\"\"\";\n");
  assert(r.length == 2 && r[0].id == "c1" && fieldOf(r[0].fields, "name") == "Müller; Jürgen");
  assert(fieldOf(r[1].fields, "name") == `Say "hi"` && fieldOf(r[1].fields, "city") == "");
  assert(parseCsvRecords("a,b\n1,2")[0].fields == [FieldValue("a", "1"), FieldValue("b", "2")]);
  assert(failsWith(DqErrorKind.invalid, () { parseCsvRecords("a b\n1"); }));
  assert(failsWith(DqErrorKind.invalid, () { parseCsvRecords("a\n1,2"); }));
}
