module uim.platform.authorization.application.dto;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct UseCaseResult {
  bool ok;
  string id;
  string message;
}

struct CreateApplicationRequest {
  string tenantId;
  string name;
  string organizationId;
  string description;
}

struct UpdateApplicationRequest {
  string tenantId;
  string applicationId;
  string name;
  string organizationId;
  string description;
}

struct CreateApplicationApiRequest {
  string tenantId;
  string applicationId;
  string name;
  string endpoint;
  string[] operations;
}

struct UpdateApplicationApiRequest {
  string tenantId;
  string apiId;
  string name;
  string endpoint;
  string[] operations;
}

struct PolicyConditionDto {
  string attribute;
  string op;
  string value;
}

struct CreatePolicyRequest {
  string tenantId;
  string applicationId;
  string name;
  string description;
  string resource;
  string action;
  PolicyConditionDto[] conditions;
  bool isBasePolicy;
}

struct UpdatePolicyRequest {
  string tenantId;
  string policyId;
  string description;
  string resource;
  string action;
  PolicyConditionDto[] conditions;
}

struct CreatePolicyAssignmentRequest {
  string tenantId;
  string policyId;
  string principalType;
  string principalId;
}

struct EvaluateAuthorizationRequest {
  string tenantId;
  string principalId;
  string applicationId;
  string resource;
  string action;
  string[string] attributes;
}
