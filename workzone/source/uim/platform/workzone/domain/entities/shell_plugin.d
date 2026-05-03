/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.shell_plugin;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A shell plugin — extensibility plugin for the shell / framework.
struct ShellPlugin {
  mixin TenantEntity!(ShellPluginId);

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

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("version", version_)
      .set("vendor", vendor)
      .set("scriptUrl", scriptUrl)
      .set("configSchemaUrl", configSchemaUrl)
      .set("status", status.toString())
      .set("assignedSiteIds", assignedSiteIds.map!(s => s.value).array)
      .set("hookPoints", hookPoints.array);
  }
}
