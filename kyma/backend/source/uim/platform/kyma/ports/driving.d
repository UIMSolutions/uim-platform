/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.driving;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (REST, OData, CLI, GUI)
/// depend on this bundle only — never on concrete interactors or repositories.
struct KymaPorts {
  IManageEnvironmentsUseCase environments;
  IManageNamespacesUseCase namespaces;
  IManageFunctionsUseCase functions;
  IManageApiRulesUseCase apiRules;
  IManageServiceInstancesUseCase serviceInstances;
  IManageServiceBindingsUseCase serviceBindings;
  IManageEventSubscriptionsUseCase subscriptions;
  IManageModulesUseCase modules;
  IManageApplicationsUseCase applications;
  IReconcileUseCase reconciler;
  IKymaStatisticsService statistics;
}
