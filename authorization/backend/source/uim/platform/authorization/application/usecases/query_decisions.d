/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.application.usecases.query_decisions;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Use case: read and prune the decision log.
class QueryDecisionsUseCase : IQueryDecisions {
  protected IDecisionRepository decisions;

  this(IDecisionRepository decisions) {
    this.decisions = decisions;
  }

  DecisionRecord[] listDecisions(TenantId tenantId) {
    return decisions.findAll(tenantId);
  }

  DecisionRecord getDecision(TenantId tenantId, DecisionRecordId id) {
    return required(decisions.findById(tenantId, id), "Decision '" ~ id.value ~ "'");
  }

  size_t pruneDecisions(TenantId tenantId, int olderThanDays) {
    if (olderThanDays < 0)
      throw AuthorizationException.invalid("olderThanDays must not be negative");
    return decisions.removeOlderThan(tenantId, daysAgo(olderThanDays));
  }
}
