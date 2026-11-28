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
module uim.platform.ai_launchpad.persistence.mappers.entities;

import std.traits : FieldNameTuple;
import uim.platform.ai_launchpad;

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
  c.id = ConnectionId("aicore");
  c.tenantId = TenantId("t");
  c.workspaceId = WorkspaceId("ml");
  c.connectionType = ConnectionType.custom;
  c.lastValidatedAt = 42;
  auto doc = entityToRecord(c);
  assert(doc["connectionType"].get!string == "custom" && doc["workspaceId"].get!string == "ml", doc.toString);
  auto back = recordToEntity!(Connection, ConnectionId)(doc);
  assert(back.id == c.id && back.tenantId == c.tenantId && back.lastValidatedAt == 42 && back.workspaceId == c.workspaceId);
  Model m;
  m.version_ = "2";
  m.sizeMiB = 1.5;
  m.labels = ["a=b"];
  auto md = entityToRecord(m);
  assert(md["version"].get!string == "2" && md["sizeMiB"].get!double == 1.5);
  assert(recordToEntity!(Model, ModelId)(md).labels == ["a=b"]);
  // tolerant reading: unknown enum values and missing members keep the defaults
  auto bad = Json(["id": Json("x"), "status": Json("exploded"), "minReplicas": Json(3)]);
  auto d = recordToEntity!(Deployment, DeploymentId)(bad);
  assert(d.status == DeploymentStatus.pending && d.minReplicas == 3 && d.maxReplicas == 1);
}
