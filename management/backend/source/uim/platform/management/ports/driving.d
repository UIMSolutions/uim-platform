/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.ports.driving;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (HTTP, REST, OData, CLI, GUI)
/// depend on this bundle only — never on concrete use cases or repositories.
struct ManagementPorts {
  IManageGlobalAccountsUseCase globalAccounts;
  IManageDirectoriesUseCase directories;
  IManageSubaccountsUseCase subaccounts;
  IManageEntitlementsUseCase entitlements;
  IManageEnvironmentsUseCase environments;
  IManageSubscriptionsUseCase subscriptions;
  IManageServicePlansUseCase servicePlans;
  IManageLabelsUseCase labels;
  IQueryEnvironmentEventsUseCase events;
  IPruneEventsUseCase pruneEvents;
  IGetAccountOverviewUseCase overview;
  IDemoDataService demoData;
}
