/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.configurations;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.configuration;
// import uim.platform.hana.domain.ports.repositories.configurations;
// import uim.platform.hana.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageConfigurationsUseCase : UIMUseCase {
  private ConfigurationRepository repo;

  this(ConfigurationRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateConfigurationRequest r) {
    if (r.id.isEmpty || r.key.length == 0)
      return CommandResult(false, "", "Configuration ID and key are required");

    auto existing = repo.findById(r.id);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Configuration already exists");

    Configuration c;
    c.id = r.id;
    c.tenantId = r.tenantId;
    c.instanceId = r.instanceId;
    c.section = r.section;
    c.key = r.key;
    c.value = r.value;
    c.description = r.description;

    import core.time : MonoTime;
    c.modifiedAt = MonoTime.currTime.ticks;

    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  Configuration get_(ConfigurationId id) {
    return repo.findById(id);
  }

  Configuration[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Configuration[] listBySection(InstanceId instanceId, string section) {
    return repo.findBySection(instanceId, section);
  }

  CommandResult update(UpdateConfigurationRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Configuration not found");

    if (existing.isReadOnly)
      return CommandResult(false, "", "Configuration is read-only");

    existing.value = r.value;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(ConfigurationId id) {
    auto existing = repo.findById(id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Configuration not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
