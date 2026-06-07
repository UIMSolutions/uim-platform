/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.enumerations.reporting;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:

/// Status of a generated report.
enum ReportStatus {
  pending,
  processing,
  ready,
  failed,
  archived,
}

/// BTP runtime environment where the service or application is running.
enum Environment {
  cloudFoundry,
  kyma,
  neo,
  other,
}

/// Unit of measurement for a service metric.
enum MetricUnit {
  requests,
  hours,
  gigabytes,
  items,
  users,
  instances,
  calls,
  gigabyteHours,
  blocks,
  documents,
  executions,
  connections,
}

/// BTP commercial / licensing model under which costs are calculated.
enum CommercialModel {
  cpea,
  payg,
  subscription,
  free_,
}

/// Type of a BTP account hierarchy node.
enum AccountType {
  globalAccount,
  directory,
  subaccount,
}
