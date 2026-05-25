/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.attribute_mappings;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class ManageAttributeMappingsUseCase {
  private AttributeMappingRepository repo;

  this(AttributeMappingRepository repo) { this.repo = repo; }

  CommandResult create(CreateAttributeMappingRequest r) {
    AttributeMapping m;
    m.id = AttributeMappingId(r.id.length > 0 ? r.id : currentTimestamp());
    m.tenantId = TenantId(r.tenantId);
    m.configId = DataSourceConfigId(r.configId);
    m.sourceAttributeName = r.sourceAttributeName;
    m.sourceDataType = r.sourceDataType;
    m.targetAttributeName = r.targetAttributeName;
    m.targetDataType = r.targetDataType;
    m.delimiter = r.delimiter;
    m.sortOrder = r.sortOrder;
    m.active = true;
    initEntity(m);

    auto err = ComposerValidator.validateAttributeMapping(m);
    if (err !is null) return CommandResult(false, m.id.value, err);

    repo.save(m);
    return CommandResult(true, m.id.value, null);
  }

  AttributeMapping[] list(string tenantId) {
    return repo.findByTenant(TenantId(tenantId));
  }

  AttributeMapping[] listByConfig(string tenantId, string configId) {
    return repo.findByConfig(TenantId(tenantId), DataSourceConfigId(configId));
  }

  AttributeMapping getById(string tenantId, string id) {
    return repo.findById(TenantId(tenantId), AttributeMappingId(id));
  }

  CommandResult update(UpdateAttributeMappingRequest r) {
    auto m = repo.findById(TenantId(r.tenantId), AttributeMappingId(r.id));
    if (m.isNull) return CommandResult(false, r.id, "Mapping not found");

    if (r.sourceAttributeName.length > 0) m.sourceAttributeName = r.sourceAttributeName;
    if (r.sourceDataType.length > 0)      m.sourceDataType = r.sourceDataType;
    if (r.targetAttributeName.length > 0) m.targetAttributeName = r.targetAttributeName;
    if (r.targetDataType.length > 0)      m.targetDataType = r.targetDataType;
    if (r.delimiter.length > 0)           m.delimiter = r.delimiter;
    if (r.sortOrder >= 0)                  m.sortOrder = r.sortOrder;
    m.active = r.active;

    repo.update(m);
    return CommandResult(true, m.id.value, null);
  }

  CommandResult remove(string tenantId, string id) {
    auto m = repo.findById(TenantId(tenantId), AttributeMappingId(id));
    if (m.isNull) return CommandResult(false, id, "Mapping not found");
    repo.remove(TenantId(tenantId), AttributeMappingId(id));
    return CommandResult(true, id, null);
  }
}
