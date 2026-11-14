/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Compile-time reflection codec between plain D structs and JSON.
///
/// Used by the persistence layer (records, raw std-time numbers) and by the
/// presentation layer (payloads, ISO timestamps). Domain structs stay free of
/// serialization code.
///
/// Field conventions:
///   * a trailing "_" is dropped from the JSON key (`version_` → "version")
///   * `long` fields whose name ends in "At" are timestamps
///   * strongly typed ids (structs with a `string value` and `isNull`) are strings
///   * enums are written by name (see helpers.enums)
///   * arrays of `{key, value}` structs also accept an object map or "k=v,k2=v2"
///   * arrays of structs also accept a JSON string (CLI / form input)
///
/// `decode` starts from a base value and only overwrites the fields present in
/// the JSON — this gives PATCH semantics for free.
module uim.platform.connectivity.helpers.codec;

import std.traits : FieldNameTuple, Unqual, isIntegral, isFloatingPoint, isSomeString;
import std.meta : AliasSeq;
import std.string : endsWith, split, strip, indexOf, toUpper;
import std.array : array, appender;
import std.ascii : isUpper;
import vibe.data.json : Json, parseJsonString;
import uim.platform.connectivity.helpers.enums;
import uim.platform.connectivity.helpers.json;
import uim.platform.connectivity.helpers.time;

@safe:

/// A strongly typed id (IdTemplate).
enum bool isIdType(T) = is(T == struct) && is(typeof(T.init.value) == string)
  && __traits(hasMember, T, "isNull");

/// A `{ string key; string value; }` pair.
enum bool isKeyValue(T) = is(T == struct) && FieldNameTuple!T.length == 2
  && FieldNameTuple!T[0] == "key" && FieldNameTuple!T[1] == "value";

/// JSON key of a D field name.
string jsonKey(string fieldName) pure nothrow {
  return fieldName.length > 1 && fieldName[$ - 1] == '_' ? fieldName[0 .. $ - 1] : fieldName;
}

/// True for timestamp fields ("createdAt", "expiresAt").
bool isTimeField(string fieldName) pure nothrow {
  return fieldName.length > 2 && fieldName.endsWith("At");
}

// ─────────────────────────────────────────────────────────────────────────────
// encode
// ─────────────────────────────────────────────────────────────────────────────

/// Encode a struct as a JSON object. `isoTimes` writes timestamps as ISO strings.
Json encode(T)(const T value, bool isoTimes = false) if (is(T == struct)) {
  auto j = Json.emptyObject;
  static foreach (i, name; FieldNameTuple!T)
    j[jsonKey(name)] = encodeValue(value.tupleof[i], isoTimes, isTimeField(name));
  return j;
}

private Json encodeValue(T)(const T v, bool isoTimes, bool timeField) {
  alias U = Unqual!T;
  static if (is(U == enum))
    return Json(enumText(cast(U) v));
  else static if (isSomeString!U)
    return Json(v.idup);
  else static if (is(U == bool))
    return Json(v);
  else static if (isIntegral!U) {
    if (timeField && isoTimes)
      return isoTime(cast(long) v);
    return Json(cast(long) v);
  } else static if (isFloatingPoint!U)
    return Json(cast(double) v);
  else static if (isIdType!U)
    return Json(v.value);
  else static if (is(U == E[], E)) {
    auto arr = Json.emptyArray;
    foreach (e; v)
      arr ~= encodeValue(e, isoTimes, false);
    return arr;
  } else static if (is(U == struct))
    return encode(v, isoTimes);
  else
    static assert(0, "codec: unsupported field type " ~ U.stringof);
}

// ─────────────────────────────────────────────────────────────────────────────
// decode
// ─────────────────────────────────────────────────────────────────────────────

/// Decode a JSON object into T, starting from `base`. Fields missing in the
/// JSON keep the base value. Timestamps accept ISO strings and numbers.
T decode(T)(Json json, T base = T.init) if (is(T == struct)) {
  T result = base;
  if (json.type != Json.Type.object)
    return result;
  static foreach (i, name; FieldNameTuple!T) {
    {
      auto v = member(json, jsonKey(name));
      if (v.type != Json.Type.undefined)
        decodeInto(result.tupleof[i], v, isTimeField(name));
    }
  }
  return result;
}

private void decodeInto(T)(ref T target, Json v, bool timeField) {
  static if (is(T == enum)) {
    target = parseEnum!T(jsonText(v), target);
  } else static if (is(T == string)) {
    target = jsonText(v);
  } else static if (is(T == bool)) {
    target = jsonBool(v, target);
  } else static if (isIntegral!T) {
    if (timeField && v.type == Json.Type.string)
      target = cast(T) parseIsoTime(v.get!string);
    else if (v.type == Json.Type.null_)
      target = 0;
    else
      target = cast(T) jsonLong(v, target);
  } else static if (isFloatingPoint!T) {
    import std.conv : to;

    auto s = jsonText(v);
    if (s.length)
      target = s.to!T;
  } else static if (isIdType!T) {
    target = T(jsonText(v));
  } else static if (is(T == E[], E)) {
    static if (is(E == string)) {
      target = jsonStrings(v);
    } else static if (is(E == enum)) {
      E[] items;
      foreach (s; jsonStrings(v))
        if (isEnumText!E(s))
          items ~= parseEnum!E(s, E.init);
      target = items;
    } else static if (isKeyValue!E) {
      target = decodeKeyValues!E(v);
    } else static if (is(E == struct)) {
      auto arr = v;
      if (v.type == Json.Type.string) {
        auto text = v.get!string.strip;
        arr = text.length == 0 ? Json.emptyArray : parseJsonString(text);
      }
      E[] items;
      if (arr.type == Json.Type.array)
        foreach (item; arr.get!(Json[]))
          items ~= decode!E(item);
      else if (arr.type == Json.Type.object)
        items ~= decode!E(arr);
      target = items;
    } else
      static assert(0, "codec: unsupported array type " ~ T.stringof);
  } else static if (is(T == struct)) {
    target = decode!T(v, target);
  } else
    static assert(0, "codec: unsupported field type " ~ T.stringof);
}

/// Key/value pairs from [{key,value}], {"k":"v"} or "k=v,k2=v2".
E[] decodeKeyValues(E)(Json v) if (isKeyValue!E) {
  E[] result;
  if (v.type == Json.Type.array) {
    foreach (item; v.get!(Json[]))
      if (item.type == Json.Type.object && fieldString(item, "key").length > 0)
        result ~= E(fieldString(item, "key"), fieldString(item, "value"));
  } else if (v.type == Json.Type.object) {
    foreach (k, val; v.get!(Json[string]))
      result ~= E(k, jsonText(val));
  } else if (v.type == Json.Type.string) {
    auto text = v.get!string.strip;
    if (text.length > 0 && (text[0] == '[' || text[0] == '{'))
      return decodeKeyValues!E(parseJsonString(text));
    foreach (part; text.split(",")) {
      auto p = part.strip;
      if (p.length == 0)
        continue;
      auto eq = p.indexOf('=');
      result ~= eq < 0 ? E(p, "") : E(p[0 .. eq].strip, p[eq + 1 .. $].strip);
    }
  }
  return result;
}

/// Copy every field of `source` into the same-named, same-typed field of
/// `target`, except the D field names listed in `except`.
/// (Specs → entities in the interactors.)
void assignMatching(T, S)(ref T target, S source, const string[] except = null)
    if (is(T == struct) && is(S == struct)) {
  import std.algorithm : canFind;

  static foreach (name; FieldNameTuple!S) {
    static if (__traits(hasMember, T, name)
        && is(typeof(__traits(getMember, target, name)) == typeof(__traits(getMember, source, name)))) {
      if (!except.canFind(name))
        __traits(getMember, target, name) = __traits(getMember, source, name);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// description (for OData $metadata, tables and forms)
// ─────────────────────────────────────────────────────────────────────────────

/// Shape of a field, independent of any protocol.
enum ValueKind {
  text,
  integer,
  boolean,
  dateTime,
  enumeration,
  textList,
  enumList,
  records, /// array of structs, see recordType
}

struct FieldInfo {
  string name; /// JSON key
  ValueKind kind;
  string label;
  string recordType; /// struct name for ValueKind.records
  string[] options; /// enum texts for enumeration / enumList
}

struct RecordTypeInfo {
  string name;
  FieldInfo[] fields;
}

/// "sinkServicePort" → "Sink Service Port", "oidcClientId" → "OIDC Client ID".
string fieldLabel(string name) {
  auto words = appender!(string[]);
  size_t start;
  foreach (i; 1 .. name.length)
    if (isUpper(name[i]) && !isUpper(name[i - 1])) {
      words.put(name[start .. i]);
      start = i;
    }
  words.put(name[start .. $]);
  string[] parts;
  foreach (w; words.data) {
    switch (w) {
    case "id", "Id":
      parts ~= "ID";
      break;
    case "url", "Url", "oidc", "Oidc", "cpu", "Cpu", "cors", "Cors", "api", "Api", "json", "Json", "tls", "Tls":
      parts ~= w.toUpper;
      break;
    default:
      parts ~= (w[0 .. 1].toUpper ~ w[1 .. $]);
    }
  }
  import std.array : join;

  return parts.join(" ");
}

/// Describe the fields of a struct.
FieldInfo[] describe(T)() if (is(T == struct)) {
  FieldInfo[] fields;
  static foreach (i, name; FieldNameTuple!T) {
    {
      alias F = Unqual!(typeof(T.tupleof[i]));
      FieldInfo f;
      f.name = jsonKey(name);
      f.label = fieldLabel(f.name);
      static if (is(F == enum)) {
        f.kind = ValueKind.enumeration;
        f.options = enumTexts!F;
      } else static if (is(F == string) || isIdType!F)
        f.kind = ValueKind.text;
      else static if (is(F == bool))
        f.kind = ValueKind.boolean;
      else static if (isIntegral!F)
        f.kind = isTimeField(name) ? ValueKind.dateTime : ValueKind.integer;
      else static if (is(F == E[], E)) {
        static if (is(E == string))
          f.kind = ValueKind.textList;
        else static if (is(E == enum)) {
          f.kind = ValueKind.enumList;
          f.options = enumTexts!E;
        } else static if (is(E == struct)) {
          f.kind = ValueKind.records;
          f.recordType = E.stringof;
        } else
          static assert(0, "codec: unsupported array type " ~ F.stringof);
      } else
        static assert(0, "codec: cannot describe " ~ F.stringof);
      fields ~= f;
    }
  }
  return fields;
}

/// The struct types used in record (array of struct) fields of T.
RecordTypeInfo[] recordTypesOf(T)() if (is(T == struct)) {
  RecordTypeInfo[] types;
  static foreach (i, name; FieldNameTuple!T) {
    {
      alias F = Unqual!(typeof(T.tupleof[i]));
      static if (is(F == E[], E) && is(E == struct))
        types ~= RecordTypeInfo(E.stringof, describe!E());
    }
  }
  return types;
}

///
unittest {
  static struct ThingId {
    string value;
    bool isNull() const {
      return value.length == 0;
    }
  }

  static struct Pair {
    string key;
    string value;
  }

  enum Mode { auto_, fixed }

  static struct Thing {
    ThingId id;
    string name;
    string version_;
    Mode mode;
    int replicas = 1;
    bool enabled;
    long createdAt;
    string[] tags;
    Pair[] labels;
  }

  Thing t;
  t.id = ThingId("t1");
  t.name = "fn";
  t.version_ = "1.0";
  t.mode = Mode.fixed;
  t.replicas = 3;
  t.createdAt = parseIsoTime("2026-11-10T10:00:00Z");
  t.tags = ["a", "b"];
  t.labels = [Pair("app", "x")];

  auto j = encode(t, true);
  assert(j["version"].get!string == "1.0");
  assert(j["mode"].get!string == "fixed");
  assert(j["createdAt"].get!string == "2026-11-10T10:00:00Z");
  assert(j["labels"][0]["key"].get!string == "app");

  auto back = decode!Thing(j);
  assert(back == t);

  // raw record round trip
  assert(decode!Thing(encode(t)) == t);

  // PATCH semantics + lenient input
  auto patch = parseJsonString(`{"replicas": "5", "mode": "AUTO", "tags": "x, y", "labels": "a=1,b=2", "enabled": "on"}`);
  auto p = decode!Thing(patch, t);
  assert(p.name == "fn" && p.replicas == 5 && p.mode == Mode.auto_ && p.enabled);
  assert(p.tags == ["x", "y"] && p.labels == [Pair("a", "1"), Pair("b", "2")]);
  assert(decode!Thing(parseJsonString(`{"labels": {"k": "v"}}`)).labels == [Pair("k", "v")]);

  auto info = describe!Thing();
  assert(info[0].name == "id" && info[0].label == "ID");
  assert(info[3].kind == ValueKind.enumeration && info[3].options == ["auto", "fixed"]);
  assert(info[6].kind == ValueKind.dateTime);
  assert(info[8].kind == ValueKind.records && info[8].recordType == "Pair");
  assert(recordTypesOf!Thing()[0].name == "Pair");
  assert(fieldLabel("oidcClientId") == "OIDC Client ID");
  assert(fieldLabel("sinkServicePort") == "Sink Service Port");
}
