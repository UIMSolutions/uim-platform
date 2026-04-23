/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.shell_plugins;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.shell_plugin;
import uim.platform.workzone.domain.ports.repositories.shell_plugins;

// import std.algorithm : filter;
// import std.array : array;

class MemoryShellPluginRepository : TenantRepository!(ShellPlugin, ShellPluginId), ShellPluginRepository {

  // #region BySite
  size_t countBySite(TenantId tenantId, SiteId siteId) {
    return findBySite(tenantId, siteId).length;
  }

  ShellPlugin[] findBySite(TenantId tenantId, SiteId siteId) {
    ShellPlugin[] result;
    foreach (p; findByTenant(tenantId)) {
      foreach (sid; p.assignedSiteIds)
        if (sid == siteId) {
          result ~= p;
          break;
        }
    }
    return result;
  }

  void removeBySite(TenantId tenantId, SiteId siteId) {
    findBySite(tenantId, siteId).each!(p => remove(p));
  }
  // #endregion BySite

  // #region ByStatus
  size_t countByStatus(PluginStatus status, TenantId tenantId) {
    return findByStatus(status, tenantId).length;
  }

  ShellPlugin[] findByStatus(PluginStatus status, TenantId tenantId) {
    return findByTenant(tenantId).filter!(p => p.status == status).array;
  }

  void removeByStatus(PluginStatus status, TenantId tenantId) {
    findByStatus(status, tenantId).each!(p => remove(p));
  }
  // #endregion ByStatus

}
