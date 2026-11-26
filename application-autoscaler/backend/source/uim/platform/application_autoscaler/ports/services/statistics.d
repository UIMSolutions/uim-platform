/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the statistics (KPI header of the Fiori app, CLI "stats").
module uim.platform.application_autoscaler.ports.services.statistics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct AasStatistics {
  TenantId tenantId;
  long bindings;
  long autoscaledBindings; /// active with a policy
  long suspendedBindings;
  long instances; /// sum of the current instances
  long policies;
  long activePolicies;
  long rules;
  long schedules;
  long activeSchedules; /// applying right now
  long metricSamples;
  long samplesLast24h;
  long scalingEvents;
  long scaleOutsLast24h;
  long scaleInsLast24h;
  long failedLast24h;
  long users;
}

interface IAasStatisticsService {
  AasStatistics compute(TenantId t);
}
