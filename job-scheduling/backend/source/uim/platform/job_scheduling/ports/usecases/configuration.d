/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the scheduler configuration of a tenant.
module uim.platform.job_scheduling.ports.usecases.configuration;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IManageConfiguration {
  /// The stored configuration or the defaults.
  SchedulerConfiguration get(TenantId t);
  SchedulerConfiguration update(UpdateCommand!ConfigurationInput c);
}
