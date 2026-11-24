/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The editable attributes of the maintained resources, as plain values.
/// One input type serves create (defaults below for missing members) and
/// update (PATCH: only the sent members change, see Changes!T).
module uim.platform.data_retention.application.dtos.inputs;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ApplicationGroupInput {
  string name;
  string description;
  string scope_ = "global"; /// "scope" in the APIs
  string[] applicationIds;
  bool active = true;
}

struct LegalEntityInput {
  string name;
  string description;
  string country;
  string region;
  bool active = true;
}

struct DataSubjectRoleInput {
  string name;
  string description;
  bool active = true;
}

struct BusinessPurposeInput {
  string name;
  string description;
  string applicationGroupId;
  string dataSubjectRoleId;
  string legalEntityId;
}

struct LegalGroundInput {
  string businessPurposeId;
  string name;
  string description;
  string type = "contract";
  string legalReference;
  bool active = true;
}

struct ResidenceRuleInput {
  string businessPurposeId;
  string legalGroundId;
  int duration;
  string periodUnit = "years";
  bool active = true;
}

struct RetentionRuleInput {
  string businessPurposeId;
  string legalGroundId;
  int duration;
  string periodUnit = "years";
  string actionOnExpiry = "delete";
  bool active = true;
}

/// applicationGroupId and dataSubjectRoleId default to the business purpose's.
struct DataSubjectInput {
  string externalId;
  string displayName;
  string applicationGroupId;
  string dataSubjectRoleId;
  string businessPurposeId;
  string legalGroundId;
  string legalEntityId;
  string referenceDate; /// ISO 8601 date or date-time; "" = business ongoing
}

/// Create a resource: an optional id ("" = generated) and the input.
struct CreateCommand(TInput) {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!TInput input;
}

/// Change a resource (PATCH semantics).
struct UpdateCommand(TInput) {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!TInput changes;
}

/// A create command with every member of the input set (tests, demo data).
CreateCommand!TInput createCommand(TInput)(TenantId t, UserId actor, string id, TInput input) {
  import std.traits : FieldNameTuple;

  CreateCommand!TInput c;
  c.tenantId = t;
  c.actor = actor;
  c.id = id;
  c.input.values = input;
  static foreach (name; FieldNameTuple!TInput)
    c.input.set(name);
  return c;
}

/// An update command changing the given members only.
UpdateCommand!TInput updateCommand(TInput)(TenantId t, UserId actor, string id, TInput values, string[] fields...) {
  UpdateCommand!TInput c;
  c.tenantId = t;
  c.actor = actor;
  c.id = id;
  c.changes.values = values;
  foreach (f; fields)
    c.changes.set(f);
  return c;
}
