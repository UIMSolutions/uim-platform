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
///   double                        as is
///   name_ (D keywords)            "name"
///
/// Reading is tolerant: missing or unknown values keep their defaults.
module uim.platform.datasphere.persistence.mappers.entities;

import std.traits : FieldNameTuple;
import uim.platform.datasphere;

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
  Connection c;
  c.id = ConnectionId("S4");
  c.tenantId = TenantId("t");
  c.spaceId = SpaceId("SALES");
  c.connectionType = ConnectionType.s4hana;
  c.port = 443;
  c.properties = ["encrypt=true"];
  auto doc = entityToRecord(c);
  assert(doc["connectionType"].get!string == "s4hana" && doc["spaceId"].get!string == "SALES", doc.toString);
  auto back = recordToEntity!(Connection, ConnectionId)(doc);
  assert(back.id == c.id && back.tenantId == c.tenantId && back.port == 443 && back.properties == ["encrypt=true"]);
  TaskChain chain;
  chain.failurePolicy = FailurePolicy.continue_;
  assert(entityToRecord(chain)["failurePolicy"].get!string == "continue");
  // tolerant reading: unknown enum values and missing members keep the defaults
  auto bad = Json(["id": Json("x"), "status": Json("exploded"), "attempts": Json(3)]);
  auto r = recordToEntity!(TaskRun, TaskRunId)(bad);
  assert(r.status == RunStatus.running && r.attempts == 3 && r.trigger == RunTrigger.manual);
}
