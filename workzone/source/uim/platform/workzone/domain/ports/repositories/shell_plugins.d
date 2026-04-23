/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.shell_plugins;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.shell_plugin;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface ShellPluginRepository : ITenantRepository!(ShellPlugin, ShellPluginId) {

  size_t countBySite(TenantId tenantId, SiteId siteId);
  ShellPlugin[] findBySite(TenantId tenantId, SiteId siteId);
  void removeBySite(TenantId tenantId, SiteId siteId);

  size_t countByStatus(TenantId tenantId, PluginStatus status);
  ShellPlugin[] findByStatus(TenantId tenantId, PluginStatus status);
  void removeByStatus(TenantId tenantId, PluginStatus status);

}
