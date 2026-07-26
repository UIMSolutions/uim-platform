module uim.platform.authorization.tests.integration;

import std.algorithm : filter;
import std.array : array;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

unittest {
  auto repo = new MemoryAuthorizationRepository();
  auto evaluator = new PolicyEvaluator();

  auto apps = new ManageApplicationsUseCase(repo);
  auto policies = new ManagePoliciesUseCase(repo);
  auto assignments = new ManageAssignmentsUseCase(repo);
  auto eval = new EvaluateAuthorizationsUseCase(repo, evaluator);

  CreateApplicationRequest appReq;
  appReq.tenantId = "t1";
  appReq.name = "incident-management";
  appReq.organizationId = "global";
  appReq.description = "test app";

  auto appCreated = apps.createApplication(appReq);
  assert(appCreated.ok);

  CreatePolicyRequest policyReq;
  policyReq.tenantId = "t1";
  policyReq.applicationId = appCreated.id;
  policyReq.name = "support-us";
  policyReq.description = "Support in US";
  policyReq.resource = "Incident";
  policyReq.action = "Read";
  policyReq.isBasePolicy = false;
  policyReq.conditions ~= PolicyConditionDto("country", "eq", "US");

  auto policyCreated = policies.createPolicy(policyReq);
  assert(policyCreated.ok);

  CreatePolicyAssignmentRequest assignReq;
  assignReq.tenantId = "t1";
  assignReq.policyId = policyCreated.id;
  assignReq.principalType = "user";
  assignReq.principalId = "alice";

  auto assignmentCreated = assignments.createAssignment(assignReq);
  assert(assignmentCreated.ok);

  EvaluateAuthorizationRequest allowReq;
  allowReq.tenantId = "t1";
  allowReq.principalId = "alice";
  allowReq.applicationId = appCreated.id;
  allowReq.resource = "Incident";
  allowReq.action = "Read";
  allowReq.attributes["country"] = "US";

  auto allowResult = eval.evaluate(allowReq);
  assert(allowResult.allowed);
  assert(allowResult.matchedPolicyIds.length == 1);

  EvaluateAuthorizationRequest denyReq = allowReq;
  denyReq.attributes["country"] = "DE";
  auto denyResult = eval.evaluate(denyReq);
  assert(!denyResult.allowed);
}

unittest {
  auto repo = new MemoryAuthorizationRepository();
  auto apps = new ManageApplicationsUseCase(repo);
  auto policies = new ManagePoliciesUseCase(repo);

  CreateApplicationRequest appReq;
  appReq.tenantId = "t-seed";
  appReq.name = "authorization-management";
  appReq.organizationId = "global";
  appReq.description = "seed target";

  auto appCreated = apps.createApplication(appReq);
  assert(appCreated.ok);

  auto firstSeed = policies.seedBasePolicies("t-seed", appCreated.id);
  assert(firstSeed.length == 3);

  auto secondSeed = policies.seedBasePolicies("t-seed", appCreated.id);
  assert(secondSeed.length == 3);

  auto allBase = policies
    .listBasePolicies("t-seed")
    .filter!(p => p.applicationId == appCreated.id)
    .array;

  assert(allBase.length == 3);
}
