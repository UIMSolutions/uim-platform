/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.service_instance;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// A BTP service instance (services.cloud.sap.com ServiceInstance), provisioned
/// by the BTP service operator from the service marketplace.
struct ServiceInstance {
  mixin TenantEntity!ServiceInstanceId;

  KymaEnvironmentId environmentId;
  NamespaceId namespaceId;
  string namespaceName;
  string name;
  string description;
  ServiceInstanceStatus status = ServiceInstanceStatus.creating;

  // Marketplace reference
  string serviceOfferingName;
  string servicePlanName;
  string externalName;

  /// Provisioning parameters (JSON text).
  string parametersJson;
  KeyValue[] labels;

  /// Number of bindings (maintained by the binding use case).
  int bindingCount;
}
