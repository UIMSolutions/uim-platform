/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.catalog_sync;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Outcome of a broker catalog sync.
struct CatalogSyncResult {
  ServiceBrokerId brokerId;
  string brokerName;
  bool succeeded;
  string error;
  size_t offeringsCreated, offeringsUpdated, offeringsRemoved;
  size_t plansCreated, plansUpdated;
  long syncedAt;
}
