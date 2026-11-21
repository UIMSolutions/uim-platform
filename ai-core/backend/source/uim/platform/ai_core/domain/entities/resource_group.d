/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A resource group isolates the ML resources (scenarios, configurations,
/// executions, deployments, artifacts, secrets) of a team or tenant
/// workload. The id is chosen by the client.
module uim.platform.ai_core.domain.entities.resource_group;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct ResourceGroup {
  mixin TenantEntity!ResourceGroupId;

  ResourceGroupStatus status = ResourceGroupStatus.provisioning;
  string statusMessage;
  Label[] labels;

  bool isProvisioned() const {
    return status == ResourceGroupStatus.provisioned;
  }

  void validate() const {
    requireResourceGroupId(id.value);
    foreach (l; labels)
      if (!isValidLabel(l))
        throw AiCoreException.invalid("Invalid label '" ~ l.key ~ "'");
  }
}

///
unittest {
  ResourceGroup g;
  g.id = ResourceGroupId("team-a");
  g.validate();
  g.id = ResourceGroupId("A");
  assert(failsWith(AiCoreErrorKind.invalid, () { g.validate(); }));
}
