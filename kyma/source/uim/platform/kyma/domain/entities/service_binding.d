/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.service_binding;

// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// A service binding — connects a service instance to an application/function.
struct ServiceBinding {
  ServiceBindingId id;
  ServiceInstanceId serviceInstanceId;
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  ServiceBindingStatus status = ServiceBindingStatus.creating;

  // Secret reference
  string secretName;
  string secretNamespace;

  // Parameters
  string parametersJson;

  // Credentials (resolved)
  string[string] credentials;

  // Labels
  string[string] labels;

  // Metadata
  string createdBy;
  long createdAt;
  long modifiedAt;
}
