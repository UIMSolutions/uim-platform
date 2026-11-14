/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.service_binding;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// A service binding: credentials of a service instance, delivered as a
/// Kubernetes secret into the instance's namespace.
struct ServiceBinding {
  mixin TenantEntity!ServiceBindingId;

  KymaEnvironmentId environmentId;
  NamespaceId namespaceId;
  string namespaceName;
  ServiceInstanceId serviceInstanceId;
  string serviceInstanceName;
  string name;
  string description;
  ServiceBindingStatus status = ServiceBindingStatus.creating;

  // Secret
  string secretName;
  /// Keys present in the secret once the binding is ready (values are never stored).
  string[] credentialKeys;

  /// Binding parameters (JSON text).
  string parametersJson;
  KeyValue[] labels;
}
