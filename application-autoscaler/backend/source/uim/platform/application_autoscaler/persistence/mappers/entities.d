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
module uim.platform.application_autoscaler.persistence.mappers.entities;

import std.traits : FieldNameTuple;
import uim.platform.application_autoscaler;

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
  ScalingSchedule s;
  s.id = ScheduleId("s");
  s.tenantId = TenantId("t");
  s.policyId = ScalingPolicyId("p");
  s.kind = ScheduleKind.specificDate;
  s.daysOfWeek = ["1", "5"];
  s.instanceMaxCount = 9;
  auto doc = entityToRecord(s);
  assert(doc["kind"].get!string == "specificDate" && doc["policyId"].get!string == "p", doc.toString);
  auto back = recordToEntity!(ScalingSchedule, ScheduleId)(doc);
  assert(back.id == s.id && back.tenantId == s.tenantId && back.daysOfWeek == s.daysOfWeek && back.instanceMaxCount == 9);
  ScalingRule r;
  r.operator = ComparisonOperator.lt;
  r.threshold = 12.5;
  auto rd = entityToRecord(r);
  assert(rd["operator"].get!string == "<" && rd["threshold"].get!double == 12.5);
  // tolerant reading: unknown enum values and missing members keep the defaults
  auto bad = Json(["id": Json("x"), "metricType": Json("gpu"), "threshold": Json(90)]);
  auto b = recordToEntity!(ScalingRule, ScalingRuleId)(bad);
  assert(b.metricType == MetricType.cpu && b.threshold == 90.0 && b.adjustment == "+1" && b.enabled);
}
