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

import uim.platform.hana;

// mixin(ShowModule!());

@safe:
class ManageConfigurationsUseCase { // TODO: UIMUseCase {
  private ConfigurationRepository repo;

  this(ConfigurationRepository repo) {
    this.repo = repo;
  }

  CommandResult createConfiguration(CreateConfigurationRequest r) {
    if (r.isNull || r.key.length == 0)
      return CommandResult(false, "", "Configuration ID and key are required");

    auto existing = repo.findById(r.id);
    if (!existing.isNull)
      return CommandResult(false, "", "Configuration already exists");

    Configuration c;
    c.id = r.id;
    c.tenantId = r.tenantId;
    c.instanceId = r.instanceId;
    c.section = r.section;
    c.key = r.key;
    c.value = r.value;
    c.description = r.description;

    
    c.updatedAt = currentTimestamp;

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  Configuration getConfiguration(ConfigurationId id) {
    return repo.findById(tenantId, id);
  }

  Configuration[] listConfigurations(TenantId tenantId) {
    return repo.find(tenantId);
  }

  Configuration[] listConfigurations(DatabaseInstanceId instanceId, string section) {
    return repo.findBySection(instanceId, section);
  }

  CommandResult updateConfiguration(UpdateConfigurationRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.isNull)
      return CommandResult(false, "", "Configuration not found");

    if (existing.isReadOnly)
      return CommandResult(false, "", "Configuration is read-only");

    existing.value = r.value;

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteConfiguration(ConfigurationId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Configuration not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }

  size_t countConfigurations(TenantId tenantId) {
    return repo.count(tenantId);
  }
}
