/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tabular projections of resource payloads, shared by the text based
/// presentation adapters (CLI tables and GtkD list views).
module uim.platform.object_store.presentation.tabular;

import uim.platform.object_store;
import uim.platform.object_store.presentation.resources;

mixin(ShowModule!());

@safe:

/// A table: column headers + string cells.
struct Table {
  string[] headers;
  string[][] rows;

  size_t length() const {
    return rows.length;
  }

  /// Render as aligned plain text (columns capped at maxWidth characters).
  string render(size_t maxWidth = 48) const {
    import std.array : appender;
    import std.utf : count;

    auto widths = headers.map!(h => h.count).array;
    foreach (r; rows)
      foreach (i, c; r)
        if (i < widths.length)
          widths[i] = max(widths[i], min(c.count, maxWidth));

    string cell(string s, size_t w) {
      auto n = s.count;
      if (n > w) {
        import std.range : take;
        import std.conv : text;

        return s.take(w - 1).text ~ "…";
      }
      return s ~ ' '.repeat(w - n).array.idup;
    }

    auto buf = appender!string;
    void line(const string[] cells) {
      foreach (i, w; widths)
        buf.put((i ? "  " : "") ~ cell(i < cells.length ? cells[i] : "", w));
      buf.put("\n");
    }

    line(headers);
    line(widths.map!(w => '-'.repeat(w).array.idup).array);
    foreach (r; rows)
      line(r);
    return buf.data;
  }
}

/// Display text of a payload value: lists are comma separated, key/value
/// records as k=v, storage class usage as "class: n", records by their name,
/// timestamps without "T"/"Z".
string cellText(Json v) {
  switch (v.type) {
  case Json.Type.array:
    string[] parts;
    foreach (item; v.get!(Json[])) {
      if (item.type == Json.Type.object) {
        if ("key" in item)
          parts ~= fieldString(item, "key") ~ "=" ~ fieldString(item, "value");
        else if ("storageClass" in item)
          parts ~= fieldString(item, "storageClass") ~ ": " ~ fieldString(item, "objects");
        else if ("name" in item)
          parts ~= fieldString(item, "name");
        else if ("path" in item)
          parts ~= fieldString(item, "path");
        else
          parts ~= item.toString;
      } else
        parts ~= jsonText(item);
    }
    return parts.join(", ");
  case Json.Type.bool_:
    return v.get!bool ? "yes" : "no";
  case Json.Type.string:
    auto s = v.get!string;
    // ISO timestamps
    if (s.length == 20 && s[4] == '-' && s[10] == 'T' && s[$ - 1] == 'Z')
      return s[0 .. 10] ~ " " ~ s[11 .. 19];
    return s.replace("\n", " ");
  case Json.Type.null_, Json.Type.undefined:
    return "";
  default:
    return jsonText(v);
  }
}

/// 1536 → "1.5 KiB"; 0 → "0 B".
string formatBytes(long bytes) {
  if (bytes < 1024)
    return bytes.to!string ~ " B";
  immutable units = ["KiB", "MiB", "GiB", "TiB", "PiB"];
  double value = bytes;
  size_t unit;
  do {
    value /= 1024;
  }
  while (value >= 1024 && ++unit < units.length - 1);
  return format("%.1f %s", value, units[unit]);
}

/// True for payload fields that hold byte counts.
bool isByteField(string field) pure {
  return field == "size" || field.endsWith("Bytes") || field == "bytes" || field == "maxObjectSize";
}

/// Project payload rows onto the columns of a resource.
Table tableOf(const ResourceColumn[] columns, const Json[] rows) {
  Table t;
  foreach (c; columns)
    t.headers ~= c.header;
  foreach (row; rows) {
    string[] cells;
    foreach (c; columns) {
      auto v = member(row, c.field);
      cells ~= isByteField(c.field) && (v.type == Json.Type.int_ || v.type == Json.Type.string)
        && jsonText(v).length > 0 && jsonText(v).all!(ch => ch >= '0' && ch <= '9')
        ? (c.field == "quotaBytes" && jsonText(v) == "0" ? "unlimited" : formatBytes(jsonText(v).to!long))
        : cellText(v);
    }
    t.rows ~= cells;
  }
  return t;
}

/// A two column (field, value) table of one payload.
Table detailTable(Json payload) {
  Table t;
  t.headers = ["Field", "Value"];
  if (payload.type == Json.Type.object)
    foreach (k, v; payload.get!(Json[string]))
      t.rows ~= [k, cellText(v)];
  t.rows.sort!((a, b) => a[0] < b[0]);
  return t;
}

///
unittest {
  mixin(ShowTest!("tableOf"));

  auto row = parseJsonString(`{"name": "fn", "labels": [{"key": "a", "value": "1"}], "tags": ["x", "y"],
    "createdAt": "2026-11-10T10:00:00Z", "on": true}`);
  auto t = tableOf([ResourceColumn("Name", "name"), ResourceColumn("Labels", "labels"),
      ResourceColumn("Tags", "tags"), ResourceColumn("Created", "createdAt"), ResourceColumn("On", "on")], [row]);
  assert(t.rows[0] == ["fn", "a=1", "x, y", "2026-11-10 10:00:00", "yes"]);
  assert(t.render.canFind("Labels"));
  assert(detailTable(row).length == 5);
  assert(cellText(parseJsonString(`[{"storageClass": "coldline", "objects": 3}]`)) == "coldline: 3");
  assert(formatBytes(512) == "512 B" && formatBytes(1536) == "1.5 KiB" && formatBytes(5L << 30) == "5.0 GiB");
  auto sizes = tableOf([ResourceColumn("Size", "size"), ResourceColumn("Quota", "quotaBytes")],
    [parseJsonString(`{"size": 2048, "quotaBytes": 0}`)]);
  assert(sizes.rows[0] == ["2.0 KiB", "unlimited"]);
}
