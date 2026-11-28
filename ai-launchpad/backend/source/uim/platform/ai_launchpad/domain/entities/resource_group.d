/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A resource group isolates the executions, deployments and artifacts of
/// a tenant or team on a runtime (SAP AI Core resource group). The id is the
/// technical name (e.g. "default").
module uim.platform.ai_launchpad.domain.entities.resource_group;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct ResourceGroup {
  mixin TenantEntity!ResourceGroupId;

  ConnectionId connectionId;
  string description;
  string[] labels; /// "key=value"
  ResourceGroupStatus status = ResourceGroupStatus.ready;

  bool isReady() const {
    return status == ResourceGroupStatus.ready;
  }

  void requireReady(string operation) const {
    if (!isReady)
      throw AilpException.ruleViolation("Resource group '" ~ id.value ~ "' is disabled: " ~ operation ~ " is not possible");
  }

  void validate() const {
    requireId(id.value, "Resource group ID");
    requireId(connectionId.value, "Connection");
    requireMaxLength(description, 2000, "Description");
    requireLabels(labels, "Resource group label");
  }
}

///
unittest {
  ResourceGroup g;
  g.id = ResourceGroupId("default");
  g.connectionId = ConnectionId("c");
  g.labels = ["ext.ai.sap.com/team=fraud"];
  g.validate();
  g.status = ResourceGroupStatus.disabled;
  assert(failsWith(AilpErrorKind.ruleViolation, () { g.requireReady("Deploying"); }));
}
