/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.domain.entities.assignment;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Assignment of a policy to a user or a group, optionally time bound.
struct PolicyAssignment {
  mixin TenantEntity!PolicyAssignmentId;

  PolicyId policyId;
  PrincipalType principalType = PrincipalType.user;
  string principalId; /// user id / login name or group name
  long validFrom; /// std time, 0 = immediately
  long validTo; /// std time, 0 = unlimited

  /// True if the assignment is in force at the given time.
  bool isEffective(long at) const {
    return (validFrom == 0 || validFrom <= at) && (validTo == 0 || at < validTo);
  }

  bool isExpired(long at) const {
    return validTo != 0 && at >= validTo;
  }

  /// True if the assignment applies to the principal (user id or one of its groups).
  bool appliesTo(string userId, const string[] groups) const {
    final switch (principalType) {
    case PrincipalType.user:
      return principalId == userId;
    case PrincipalType.group:
      return groups.canFind(principalId);
    }
  }

  void validate() const {
    if (policyId.isNull)
      throw AuthorizationException.invalid("policyId is required");
    if (principalId.strip.length == 0)
      throw AuthorizationException.invalid("principalId is required");
    if (validFrom != 0 && validTo != 0 && validTo <= validFrom)
      throw AuthorizationException.ruleViolation("validTo must be after validFrom");
  }
}

///
unittest {
  mixin(ShowTest!("PolicyAssignment"));

  PolicyAssignment a;
  a.policyId = PolicyId("p");
  a.principalType = PrincipalType.group;
  a.principalId = "Support";
  a.validFrom = 100;
  a.validTo = 200;
  a.validate();
  assert(a.appliesTo("alice", ["Support"]) && !a.appliesTo("alice", []));
  assert(!a.isEffective(99) && a.isEffective(100) && !a.isEffective(200));
  assert(a.isExpired(200));
  a.validTo = 50;
  assert(failsWith(AuthorizationErrorKind.ruleViolation, () { a.validate(); }));
}
