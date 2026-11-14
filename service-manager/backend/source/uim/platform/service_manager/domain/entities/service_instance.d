/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.entities.service_instance;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// A provisioned instance of a service plan.
struct ServiceInstance {
  mixin TenantEntity!ServiceInstanceId;

  string name;
  ServicePlanId planId;
  ServiceOfferingId offeringId;
  PlatformId platformId; /// optional: platform the instance was provisioned for
  ServiceInstanceStatus status = ServiceInstanceStatus.creating;
  string context; /// JSON text (OSB context object)
  string parameters; /// JSON text (provisioning parameters)
  string dashboardUrl;
  bool shared_; /// shared to other environments
  bool usable = true;
  OperationId lastOperationId;

  /// Change the lifecycle state; throws ruleViolation for illegal transitions.
  void transitionTo(ServiceInstanceStatus next) {
    ensureInstanceTransition(status, next);
    status = next;
  }

  bool isReady() const {
    return status == ServiceInstanceStatus.created;
  }

  void validate() const {
    requireName(name, "Service instance");
    if (planId.isNull)
      throw ServiceManagerException.invalid("Service instance planId is required");
    requireJsonText(context, "context");
    requireJsonText(parameters, "parameters");
  }
}

///
unittest {
  ServiceInstance i;
  i.transitionTo(ServiceInstanceStatus.created);
  assert(i.isReady);
  assert(failsWith(ServiceManagerErrorKind.ruleViolation, () { i.transitionTo(ServiceInstanceStatus.creating); }));
}
