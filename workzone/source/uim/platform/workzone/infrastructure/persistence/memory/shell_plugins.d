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

class MemoryShellPluginRepository : ShellPluginRepository {
  private ShellPlugin[ShellPluginId] store;

  ShellPlugin[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(p => p.tenantId == tenantId).array;
  }

  ShellPlugin* findById(ShellPluginId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ShellPlugin[] findBySite(SiteId siteId, TenantId tenantId) {
    ShellPlugin[] result;
    foreach (ref p; store.byValue())
    {
      if (p.tenantId != tenantId)
        continue;
      foreach (ref sid; p.assignedSiteIds)
        if (sid == siteId)
        {
          result ~= p;
          break;
        }
    }
    return result;
  }

  ShellPlugin[] findByStatus(PluginStatus status, TenantId tenantId) {
    return store.byValue().filter!(p => p.tenantId == tenantId && p.status == status).array;
  }

  void save(ShellPlugin plugin) {
    store[plugin.id] = plugin;
  }

  void update(ShellPlugin plugin) {
    store[plugin.id] = plugin;
  }

  void remove(ShellPluginId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
