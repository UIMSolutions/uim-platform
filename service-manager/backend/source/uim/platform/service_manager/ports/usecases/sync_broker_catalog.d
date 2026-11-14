/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.sync_broker_catalog;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ISyncBrokerCatalog {
  /// Fetch the catalog of one broker and reconcile offerings and plans.
  CatalogSyncResult syncCatalog(TenantId tenantId, ServiceBrokerId brokerId, UserId actor);
  /// Sync every active broker of the tenant; failures are recorded on the broker.
  CatalogSyncResult[] syncAll(TenantId tenantId, UserId actor);
}
