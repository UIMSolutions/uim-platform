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
module uim.platform.integration_automation.persistence.mappers.entities;

import std.traits : FieldNameTuple;
import uim.platform.integration_automation;

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
        else static if (is(M == string) || is(M == bool) || is(M == int) || is(M == long))
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
  Destination d;
  d.id = DestinationId("d");
  d.tenantId = TenantId("t");
  d.name = "S4";
  d.scope_ = "API";
  d.systemId = SystemConnectionId("s4");
  d.authentication = AuthenticationType.basic;
  d.enabled = false;
  auto doc = entityToRecord(d);
  assert(doc["scope"].get!string == "API" && "scope_" !in doc && doc["authentication"].get!string == "basic", doc.toString);
  auto back = recordToEntity!(Destination, DestinationId)(doc);
  assert(back.id == d.id && back.tenantId == d.tenantId && back.systemId == d.systemId && !back.enabled);
  assert(back.authentication == AuthenticationType.basic && back.scope_ == "API");

  WorkflowTask t;
  t.id = WorkflowTaskId("t1");
  t.dependsOn = ["a", "b"];
  t.status = TaskStatus.failed;
  t.attempts = 2;
  t.startedAt = 42;
  auto tb = recordToEntity!(WorkflowTask, WorkflowTaskId)(entityToRecord(t));
  assert(tb.dependsOn == ["a", "b"] && tb.status == TaskStatus.failed && tb.attempts == 2 && tb.startedAt == 42);

  // tolerant reading: unknown enum values and missing members keep the defaults
  auto bad = Json(["id": Json("x"), "status": Json("vaporized")]);
  auto s = recordToEntity!(IntegrationScenario, ScenarioId)(bad);
  assert(s.status == ScenarioStatus.draft && s.version_ == "1.0");
}
