/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.shell_plugins;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.shell_plugin;
// import uim.platform.workzone.domain.ports.repositories.shell_plugins;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageShellPluginsUseCase { // TODO: UIMUseCase {
  private ShellPluginRepository repo;

  this(ShellPluginRepository repo) {
    this.repo = repo;
  }

  CommandResult createPlugin(CreateShellPluginRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Plugin name is required");

    auto now = Clock.currStdTime();
    auto p = ShellPlugin();
    p.id = randomUUID();
    p.tenantId = req.tenantId;
    p.name = req.name;
    p.description = req.description;
    p.version_ = req.version_;
    p.vendor = req.vendor;
    p.scriptUrl = req.scriptUrl;
    p.configSchemaUrl = req.configSchemaUrl;
    p.status = PluginStatus.inactive;
    p.hookPoints = req.hookPoints;
    p.installedAt = now;
    p.updatedAt = now;

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  ShellPlugin getPlugin(TenantId tenantId, ShellPluginId id) {
    return repo.findById(tenantId, id);
  }

  ShellPlugin[] listPlugins(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updatePlugin(UpdateShellPluginRequest req) {
    auto p = repo.findById(req.tenantId, req.id);
    if (p.isNull)
      return CommandResult(false, "", "Plugin not found");

    if (req.name.length > 0)
      p.name = req.name;
    if (req.description.length > 0)
      p.description = req.description;
    if (req.scriptUrl.length > 0)
      p.scriptUrl = req.scriptUrl;
    p.status = req.status;
    p.updatedAt = Clock.currStdTime();

    repo.update(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult deletePlugin(TenantId tenantId, ShellPluginId id) {
    auto p = repo.findById(tenantId, id);
    if (p.isNull)
      return CommandResult(false, "", "Plugin not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
