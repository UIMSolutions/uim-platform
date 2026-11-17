/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.shell_plugin;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A shell plugin (script injected into the launchpad shell of sites).
struct ShellPlugin {
  mixin TenantEntity!ShellPluginId;

  string name; /// unique per tenant
  string description;
  string version_ = "1.0.0";
  string vendor;
  string scriptUrl; /// https://... or a relative path
  string configSchemaUrl;
  PluginStatus status = PluginStatus.inactive;
  string[] assignedSites; /// site names
  HookPoint[] hookPoints;
  long installedAt;
}
