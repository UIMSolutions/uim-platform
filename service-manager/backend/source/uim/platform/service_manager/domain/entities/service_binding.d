/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.entities.service_binding;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Access credentials of an application to a service instance.
struct ServiceBinding {
  mixin TenantEntity!ServiceBindingId;

  string name;
  ServiceInstanceId instanceId;
  ServiceBindingStatus status = ServiceBindingStatus.creating;
  string credentials; /// JSON text — secret, returned only to authorized readers
  string parameters; /// JSON text
  string bindResource; /// JSON text (OSB bind_resource)
  string context; /// JSON text
  OperationId lastOperationId;

  void transitionTo(ServiceBindingStatus next) {
    ensureBindingTransition(status, next);
    status = next;
  }

  void validate() const {
    requireName(name, "Service binding");
    if (instanceId.isNull)
      throw ServiceManagerException.invalid("Service binding instanceId is required");
    requireJsonText(credentials, "credentials");
    requireJsonText(parameters, "parameters");
    requireJsonText(bindResource, "bindResource");
    requireJsonText(context, "context");
  }
}
