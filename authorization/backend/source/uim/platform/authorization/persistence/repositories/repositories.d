/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (implement the driven repository ports).
module uim.platform.authorization.persistence.repositories.repositories;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class ApplicationRepository : DocumentRepository!(ManagedApplication, ManagedApplicationId, applicationToRecord,
  recordToApplication), IApplicationRepository {
  this(IDocumentStore store) {
    super(store, AuthorizationCollections.applications);
  }

  ManagedApplication findByName(TenantId t, string name) {
    return first(t, (const ManagedApplication e) => e.name == name);
  }
}

class ApplicationApiRepository : DocumentRepository!(ApplicationApi, ApplicationApiId, apiToRecord, recordToApi),
IApplicationApiRepository {
  this(IDocumentStore store) {
    super(store, AuthorizationCollections.applicationApis);
  }

  ApplicationApi[] findByApplication(TenantId t, ManagedApplicationId applicationId) {
    return where(t, (const ApplicationApi e) => e.applicationId == applicationId);
  }

  ApplicationApi findByName(TenantId t, ManagedApplicationId applicationId, string name) {
    return first(t, (const ApplicationApi e) => e.applicationId == applicationId && e.name == name);
  }
}

class PolicyRepository : DocumentRepository!(AuthorizationPolicy, PolicyId, policyToRecord, recordToPolicy),
IPolicyRepository {
  this(IDocumentStore store) {
    super(store, AuthorizationCollections.policies);
  }

  AuthorizationPolicy[] findByApplication(TenantId t, ManagedApplicationId applicationId) {
    return where(t, (const AuthorizationPolicy e) => e.applicationId == applicationId);
  }

  AuthorizationPolicy findByName(TenantId t, ManagedApplicationId applicationId, string name) {
    return first(t, (const AuthorizationPolicy e) => e.applicationId == applicationId && e.name == name);
  }
}

class AssignmentRepository : DocumentRepository!(PolicyAssignment, PolicyAssignmentId, assignmentToRecord,
  recordToAssignment), IAssignmentRepository {
  this(IDocumentStore store) {
    super(store, AuthorizationCollections.assignments);
  }

  PolicyAssignment[] findByPolicy(TenantId t, PolicyId policyId) {
    return where(t, (const PolicyAssignment e) => e.policyId == policyId);
  }

  PolicyAssignment[] findByPrincipal(TenantId t, PrincipalType type, string principalId) {
    return where(t, (const PolicyAssignment e) => e.principalType == type && e.principalId == principalId);
  }
}

class DecisionRepository : DocumentRepository!(DecisionRecord, DecisionRecordId, decisionToRecord, recordToDecision),
IDecisionRepository {
  this(IDocumentStore store) {
    super(store, AuthorizationCollections.decisions);
  }

  size_t removeOlderThan(TenantId t, long stdTime) {
    size_t removed;
    foreach (e; where(t, (const DecisionRecord e) => e.createdAt < stdTime))
      if (removeById(t, e.id))
        removed++;
    return removed;
  }
}
