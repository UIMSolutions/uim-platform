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
///   RetentionPeriod period        "duration" + "periodUnit"
///   name_ (D keywords)            "name"
///
/// Derived attributes (DataSubject.evaluation) are never persisted.
/// Reading is tolerant: missing or unknown values keep their defaults.
module uim.platform.data_retention.persistence.mappers.entities;

import std.traits : FieldNameTuple;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

private enum string[] auditAttributes = ["tenantId", "id", "createdBy", "createdAt", "updatedBy", "updatedAt"];
private enum string[] derivedAttributes = ["evaluation"];

/// Record key of an attribute ("scope_" → "scope").
string recordKey(string attribute) pure {
  return attribute.length > 1 && attribute[$ - 1] == '_' ? attribute[0 .. $ - 1] : attribute;
}

private enum bool persisted(string name) = !auditAttributes.canFind(name) && !derivedAttributes.canFind(name);

private enum bool isTypedId(M) = is(M == struct) && __traits(hasMember, M, "value") && !is(M == RetentionPeriod);

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
        else static if (is(M == RetentionPeriod)) {
          d["duration"] = v.duration;
          d["periodUnit"] = cast(string) v.unit;
        } else static if (isTypedId!M)
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
          __traits(getMember, e, name) = textField(d, key);
        else static if (is(M == bool))
          __traits(getMember, e, name) = boolField(d, key, fallback);
        else static if (is(M == int))
          __traits(getMember, e, name) = cast(int) longField(d, key, fallback);
        else static if (is(M == long))
          __traits(getMember, e, name) = longField(d, key, fallback);
        else static if (is(M == string[]))
          __traits(getMember, e, name) = textsField(d, key);
        else static if (is(M == RetentionPeriod))
          __traits(getMember, e, name) = RetentionPeriod(cast(int) longField(d, "duration", fallback.duration),
            domainEnumOr!PeriodUnit(textField(d, "periodUnit"), fallback.unit));
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
  ApplicationGroup g;
  g.id = ApplicationGroupId("erp");
  g.tenantId = TenantId("t");
  g.name = "ERP";
  g.scope_ = ApplicationGroupScope.regional;
  g.applicationIds = ["S4-SD"];
  g.active = false;
  auto doc = entityToRecord(g);
  assert(doc["scope"].get!string == "regional" && "scope_" !in doc, doc.toString);
  auto back = recordToEntity!(ApplicationGroup, ApplicationGroupId)(doc);
  assert(back.id == g.id && back.tenantId == g.tenantId && back.scope_ == g.scope_ && back.applicationIds == g.applicationIds);
  assert(!back.active);

  RetentionRule r;
  r.id = RetentionRuleId("r");
  r.legalGroundId = LegalGroundId("g");
  r.period = RetentionPeriod(10, PeriodUnit.years);
  r.actionOnExpiry = DeletionAction.anonymize;
  auto rd = entityToRecord(r);
  assert(rd["duration"].get!long == 10 && rd["periodUnit"].get!string == "years" && rd["actionOnExpiry"].get!string == "anonymize");
  auto rb = recordToEntity!(RetentionRule, RetentionRuleId)(rd);
  assert(rb.period == r.period && rb.actionOnExpiry == r.actionOnExpiry && rb.legalGroundId == r.legalGroundId && rb.active);

  DataSubject s;
  s.id = DataSubjectId("ds");
  s.evaluation.phase = RetentionPhase.endOfRetention;
  s.legalHold = true;
  auto sd = entityToRecord(s);
  assert("evaluation" !in sd && sd["lifecycleStatus"].get!string == "active");
  auto sb = recordToEntity!(DataSubject, DataSubjectId)(sd);
  assert(sb.legalHold && sb.evaluation.phase == RetentionPhase.noRule);

  // tolerant reading: unknown enum values and missing members keep the defaults
  auto bad = Json(["id": Json("x"), "lifecycleStatus": Json("vaporized")]);
  assert(recordToEntity!(DataSubject, DataSubjectId)(bad).lifecycleStatus == LifecycleStatus.active);
}
