/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.shell_plugin;

import uim.platform.workzone.domain.types;

/// A shell plugin — extensibility plugin for the shell / framework.
struct ShellPlugin {
  ShellPluginId id;
  TenantId tenantId;
  string name;
  string description;
  string version_;
  string vendor;
  string scriptUrl;
  string configSchemaUrl;
  PluginStatus status = PluginStatus.inactive;
  SiteId[] assignedSiteIds;
  string[] hookPoints; // e.g., "header", "footer", "sidebar", "shell-bar"
  long installedAt;
  long updatedAt;
}
