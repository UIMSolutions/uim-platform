/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity ↔ record mapping, derived from the entity declarations at
/// compile time (a new attribute is persisted without further code):
///
///   string, bool, int, long       as is
///   string enums                  their value
///   typed ids (…Id)               their value
///   string[]                      array of strings
///   name_ (D keywords)            "name"
///
/// Reading is tolerant: missing or unknown values keep their defaults.
module uim.platform.document_ai.persistence.mappers.entities;

import std.traits : FieldNameTuple;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

private enum string[] auditAttributes = ["tenantId", "id", "createdBy", "createdAt", "updatedBy", "updatedAt"];

/// Record key of an attribute ("scope_" → "scope").
string recordKey(string attribute) pure {
  return attribute.length > 1 && attribute[$ - 1] == '_' ? attribute[0 .. $ - 1] : attribute;
}

private enum bool persisted(string name) = !auditAttributes.canFind(name);

private enum bool isTypedId(M) = is(M == struct) && __traits(hasMember, M, "value");

Json entityToRecord(E)(const E e) @trusted {
  auto d = auditRecord(e);
  static foreach (name; FieldNameTuple!E) {
    static if (persisted!name) {
      {
        alias M = typeof(__traits(getMember, E, name));
        enum key = recordKey(name);
        auto v = __traits(getMember, e, name);
        static if (is(M == enum))
          d[key] = cast(string) v;
        else static if (is(M == string) || is(M == bool) || is(M == int) || is(M == long) || is(M == double))
          d[key] = v;
        else static if (is(M == string[]))
          d[key] = textsRecord(v);
        else static if (isTypedId!M)
          d[key] = v.value;
        else
          static assert(false, "cannot persist " ~ E.stringof ~ "." ~ name ~ " of type " ~ M.stringof);
      }
    }
  }
  return d;
}

E recordToEntity(E, TId)(Json d) @trusted {
  E e;
  readAudit!(E, TId)(e, d);
  static foreach (name; FieldNameTuple!E) {
    static if (persisted!name) {
      {
        alias M = typeof(__traits(getMember, E, name));
        enum key = recordKey(name);
        auto fallback = __traits(getMember, E.init, name);
        static if (is(M == enum))
          __traits(getMember, e, name) = domainEnumOr!M(textField(d, key), fallback);
        else static if (is(M == string))
          __traits(getMember, e, name) = key in d ? textField(d, key) : fallback;
        else static if (is(M == bool))
          __traits(getMember, e, name) = boolField(d, key, fallback);
        else static if (is(M == int))
          __traits(getMember, e, name) = cast(int) longField(d, key, fallback);
        else static if (is(M == long))
          __traits(getMember, e, name) = longField(d, key, fallback);
        else static if (is(M == double))
          __traits(getMember, e, name) = doubleField(d, key, fallback);
        else static if (is(M == string[]))
          __traits(getMember, e, name) = textsField(d, key);
        else static if (isTypedId!M)
          __traits(getMember, e, name) = M(textField(d, key));
        else
          static assert(false, "cannot read " ~ E.stringof ~ "." ~ name ~ " of type " ~ M.stringof);
      }
    }
  }
  return e;
}

///
unittest {
  AiDocument d;
  d.id = DocumentId("d");
  d.tenantId = TenantId("t");
  d.fileName = "a.pdf";
  d.status = DocumentStatus.done;
  d.schemaId = SchemaId("inv");
  d.labels = ["a=1", "b=2"];
  d.overallConfidence = 0.875;
  d.fileSize = 5_000_000_000;
  auto doc = entityToRecord(d);
  assert(doc["status"].get!string == "done" && doc["schemaId"].get!string == "inv", doc.toString);
  auto back = recordToEntity!(AiDocument, DocumentId)(doc);
  assert(back.id == d.id && back.tenantId == d.tenantId && back.labels == d.labels && back.overallConfidence == 0.875);
  assert(back.fileSize == 5_000_000_000 && back.status == DocumentStatus.done);
  Schema s;
  s.version_ = 3;
  s.status = SchemaStatus.deprecated_;
  auto sd = entityToRecord(s);
  assert(sd["version"].get!long == 3 && "version_" !in sd && sd["status"].get!string == "deprecated");
  // tolerant reading: unknown enum values and missing members keep the defaults
  auto bad = Json(["id": Json("x"), "status": Json("vaporized"), "overallConfidence": Json(1)]);
  auto b = recordToEntity!(AiDocument, DocumentId)(bad);
  assert(b.status == DocumentStatus.pending && b.language == "en" && b.pageCount == 1 && b.overallConfidence == 1.0);
}
