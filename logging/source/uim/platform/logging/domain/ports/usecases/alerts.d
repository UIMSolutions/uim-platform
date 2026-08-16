/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.usecases.alerts;
// import uim.platform.logging.domain.entities.alert;
// import uim.platform.logging.domain.ports.repositories.alerts;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface IManageAlertsUseCase {

  size_t countOpen(TenantId tenantId);

  size_t countByTenant(TenantId tenantId);

  Alert[] listAlerts(TenantId tenantId, AlertState state);

  Alert[] listAlerts(TenantId tenantId, AlertSeverity severity);

  CommandResult acknowledgeAlert(AcknowledgeAlertRequest req);

  CommandResult resolveAlert(ResolveAlertRequest req);

  CommandResult triggerAlert(TenantId tenantId, AlertRuleId ruleId, string ruleName,
    AlertSeverity severity, string message, long matchCount, LogEntryId sampleId);

  CommandResult deleteAlert(TenantId tenantId, AlertId id);

}
