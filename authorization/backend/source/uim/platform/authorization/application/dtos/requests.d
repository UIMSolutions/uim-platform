/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Request models of the use cases (protocol neutral).
module uim.platform.authorization.application.dtos.requests;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// The fields an update request actually carries (merge semantics).
struct FieldSet {
  string[] names;

  void mark(string name) {
    if (!names.canFind(name))
      names ~= name;
  }

  bool has(string name) const {
    return names.canFind(name);
  }
}

struct CreateApplicationRequest {
  TenantId tenantId;
  UserId actor;
  string name;
  string organizationId;
  string description;
}

struct UpdateApplicationRequest {
  TenantId tenantId;
  UserId actor;
  ManagedApplicationId id;
  FieldSet fields;
  string name;
  string organizationId;
  string description;
}

struct CreateApplicationApiRequest {
  TenantId tenantId;
  UserId actor;
  ManagedApplicationId applicationId;
  string name;
  string endpoint;
  string[] operations;
}

struct UpdateApplicationApiRequest {
  TenantId tenantId;
  UserId actor;
  ApplicationApiId id;
  FieldSet fields;
  string name;
  string endpoint;
  string[] operations;
}

struct CreatePolicyRequest {
  TenantId tenantId;
  UserId actor;
  ManagedApplicationId applicationId;
  string name;
  string description;
  string resource;
  string action;
  PolicyCondition[] conditions;
  PolicyKind kind = PolicyKind.custom;
  PolicyStatus status = PolicyStatus.active;
}

struct UpdatePolicyRequest {
  TenantId tenantId;
  UserId actor;
  PolicyId id;
  FieldSet fields;
  string name;
  string description;
  string resource;
  string action;
  PolicyCondition[] conditions;
  string status;
}

struct CreateAssignmentRequest {
  TenantId tenantId;
  UserId actor;
  PolicyId policyId;
  string principalType = "user";
  string principalId;
  long validFrom;
  long validTo;
}

struct UpdateAssignmentRequest {
  TenantId tenantId;
  UserId actor;
  PolicyAssignmentId id;
  FieldSet fields;
  long validFrom;
  long validTo;
}

struct EvaluateAuthorizationRequest {
  TenantId tenantId;
  string principalId;
  string[] groups;
  string application; /// application id or name
  string resource;
  string action;
  string[string] attributes;
  string channel = "api";
  bool record = true; /// write a DecisionRecord (if the service records decisions)
}
