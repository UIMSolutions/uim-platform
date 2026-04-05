/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.shell_plugins;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.shell_plugin;

interface ShellPluginRepository {
  ShellPlugin[] findByTenant(TenantId tenantId);
  ShellPlugin* findById(ShellPluginId id, TenantId tenantId);
  ShellPlugin[] findBySite(SiteId siteId, TenantId tenantId);
  ShellPlugin[] findByStatus(PluginStatus status, TenantId tenantId);
  void save(ShellPlugin plugin);
  void update(ShellPlugin plugin);
  void remove(ShellPluginId id, TenantId tenantId);
}
