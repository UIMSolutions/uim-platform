/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.services.environment_provisioner;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Result of provisioning validation.
struct ProvisionValidation {
  bool valid;
  string reason;
}

/// Domain service: validates environment provisioning constraints.
class EnvironmentProvisioner {
  /// Validate that an environment can be provisioned in the given subaccount.
  ProvisionValidation validateProvisioning(EnvironmentType envType, string planName,
      const Subaccount subaccount, const Environment[] existingInstances) const {
    if (subaccount.status != SubaccountStatus.active)
      return ProvisionValidation(false, "Subaccount must be in active status to provision environments");

    if (planName.length == 0)
      return ProvisionValidation(false, "Plan name is required for environment provisioning");

    // Only one Cloud Foundry org and one Kyma runtime per subaccount
    if (envType == EnvironmentType.cloudFoundry || envType == EnvironmentType.kyma)
      foreach (inst; existingInstances)
        if (inst.environmentType == envType && inst.isLive)
          return ProvisionValidation(false, "Only one " ~ enumName(envType) ~ " environment allowed per subaccount");

    return ProvisionValidation(true, "");
  }

  /// Determine if an environment can be deleted.
  bool canDelete(const Environment inst) const {
    return inst.status == EnvironmentStatus.active
      || inst.status == EnvironmentStatus.error || inst.status == EnvironmentStatus.suspended;
  }
}

///
unittest {
  mixin(ShowTest!("EnvironmentProvisioner"));

  auto p = new EnvironmentProvisioner();
  auto sub = Subaccount(TenantId("t"));
  auto cf = Environment(TenantId("t"));
  cf.status = EnvironmentStatus.active;

  assert(p.validateProvisioning(EnvironmentType.kyma, "standard", sub, [cf]).valid);
  assert(!p.validateProvisioning(EnvironmentType.cloudFoundry, "standard", sub, [cf]).valid);
  assert(!p.validateProvisioning(EnvironmentType.abap, "", sub, []).valid);
  sub.status = SubaccountStatus.suspended;
  assert(!p.validateProvisioning(EnvironmentType.abap, "standard", sub, []).valid);
  assert(p.canDelete(cf));
}
