/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.ports.driving;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (REST, content API,
/// OData, CLI, GUI) depend on this bundle only — never on concrete
/// interactors, repositories or storages.
struct ObjectStorePorts {
  IManageBucketsUseCase buckets;
  IManageObjectsUseCase objects;
  IManageVersionsUseCase versions;
  IManageAccessPoliciesUseCase policies;
  IManageLifecycleRulesUseCase lifecycleRules;
  IManageCorsRulesUseCase corsRules;
  IManageServiceBindingsUseCase bindings;
  IObjectStoreCatalogService catalog;
  IObjectStoreStatisticsService statistics;
}
