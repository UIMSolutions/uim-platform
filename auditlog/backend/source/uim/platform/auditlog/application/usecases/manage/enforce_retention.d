/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.manage.enforce_retention;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Interactor: purges expired audit data using the domain RetentionEnforcer.
class EnforceRetentionUseCase : IEnforceRetentionUseCase {
  protected RetentionEnforcer enforcer;
  protected IAuditEventPublisher publisher;

  this(RetentionEnforcer enforcer, IAuditEventPublisher publisher = null) {
    this.enforcer = enforcer;
    this.publisher = publisher;
  }

  UsecaseResult enforce(TenantId tenantId) {
    if (tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required", 400);

    auto outcome = enforcer.enforceForTenant(tenantId);
    auto data = Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("cutoff", outcome.cutoff)
      .set("retentionDays", outcome.retentionDays)
      .set("removed", outcome.removed);

    if (publisher !is null)
      publisher.publish(AuditTopics.retentionEnforced, data);

    return UsecaseResult(true, tenantId.value,
      "Removed %d expired records".format(outcome.removed), 0, data);
  }
}
