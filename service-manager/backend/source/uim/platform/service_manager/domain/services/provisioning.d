/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business rules for provisioning, plan changes and binding.
module uim.platform.service_manager.domain.services.provisioning;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ProvisioningPolicy {
  /// A new instance of `plan` may be created. `platform` may be Platform.init
  /// (no platform requested).
  static void checkProvisionable(const ServiceBroker broker, const ServiceOffering offering,
    const ServicePlan plan, size_t instancesOfPlan, const Platform platform) {
    if (plan.offeringId != offering.id)
      throw ServiceManagerException.invalid("Service plan '" ~ plan.name ~ "' does not belong to offering '" ~ offering.name ~ "'");
    if (!broker.isActive)
      throw ServiceManagerException.ruleViolation("Service broker '" ~ broker.name ~ "' is " ~ cast(string) broker.status);
    if (!offering.isAvailable)
      throw ServiceManagerException.ruleViolation("Service offering '" ~ offering.name ~ "' is " ~ cast(
          string) offering.status ~ " and accepts no new instances");
    if (plan.quotaExhausted(instancesOfPlan))
      throw ServiceManagerException.ruleViolation(format("Quota of service plan '%s' exhausted (%d instances)", plan.name, plan
          .maxInstances));
    if (!platform.isNull && !platform.isActive)
      throw ServiceManagerException.ruleViolation("Platform '" ~ platform.name ~ "' is " ~ cast(string) platform.status);
  }

  /// The plan of `instance` may be changed to `newPlan`.
  static void checkPlanChange(const ServiceInstance instance, const ServiceOffering offering, const ServicePlan newPlan,
    size_t instancesOfNewPlan) {
    if (newPlan.offeringId != instance.offeringId)
      throw ServiceManagerException.ruleViolation("Service plan '" ~ newPlan.name ~ "' belongs to another service offering");
    if (!offering.planUpdateable)
      throw ServiceManagerException.ruleViolation("Service offering '" ~ offering.name ~ "' does not support plan updates");
    if (newPlan.quotaExhausted(instancesOfNewPlan))
      throw ServiceManagerException.ruleViolation("Quota of service plan '" ~ newPlan.name ~ "' exhausted");
  }

  /// A binding may be created for `instance`.
  static void checkBindable(const ServiceInstance instance, const ServiceOffering offering, const ServicePlan plan) {
    if (!instance.isReady)
      throw ServiceManagerException.ruleViolation("Service instance '" ~ instance.name ~ "' is " ~ cast(
          string) instance.status ~ "; bindings need a created instance");
    if (!instance.usable)
      throw ServiceManagerException.ruleViolation("Service instance '" ~ instance.name ~ "' is not usable");
    if (!offering.bindable || !plan.bindable)
      throw ServiceManagerException.ruleViolation("Service plan '" ~ plan.name ~ "' is not bindable");
  }
}

///
unittest {
  ServiceBroker broker;
  broker.id = ServiceBrokerId("b");
  broker.name = "b";
  ServiceOffering offering;
  offering.id = ServiceOfferingId("o");
  offering.name = "o";
  ServicePlan plan;
  plan.id = ServicePlanId("p");
  plan.offeringId = offering.id;
  plan.name = "p";
  plan.maxInstances = 1;

  ProvisioningPolicy.checkProvisionable(broker, offering, plan, 0, Platform.init);
  assert(failsWith(ServiceManagerErrorKind.ruleViolation, () {
      ProvisioningPolicy.checkProvisionable(broker, offering, plan, 1, Platform.init);
    }));

  offering.status = ServiceOfferingStatus.deprecated_;
  assert(failsWith(ServiceManagerErrorKind.ruleViolation, () {
      ProvisioningPolicy.checkProvisionable(broker, offering, plan, 0, Platform.init);
    }));

  ServiceInstance instance;
  instance.name = "i";
  assert(failsWith(ServiceManagerErrorKind.ruleViolation, () {
      ProvisioningPolicy.checkBindable(instance, offering, plan);
    }));
  instance.status = ServiceInstanceStatus.created;
  ProvisioningPolicy.checkBindable(instance, offering, plan);
}
