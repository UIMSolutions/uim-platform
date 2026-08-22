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
  protected IAttributeMappingRepository repo;

  this(IAttributeMappingRepository repo) {
    this.repo = repo;
  }

  UsecaseResult create(CreateAttributeMappingRequest r) {
    auto m = AttributeMapping(r.tenantId);
    m.id = r.mappingId.isNull ? AttributeMappingId(createId) : r.mappingId;
    m.configId = DataSourceConfigId(r.configId);
    m.sourceAttributeName = r.sourceAttributeName;
    m.sourceDataType = r.sourceDataType;
    m.targetAttributeName = r.targetAttributeName;
    m.targetDataType = r.targetDataType;
    m.delimiter = r.delimiter;
    m.sortOrder = r.sortOrder;
    m.active = true;
    // initEntity(m);

    auto err = ComposerValidator.validateAttributeMapping(m);
    if (err !is null)
      return UsecaseResult(false, m.id.value, err);

    repo.save(m);
    return UsecaseResult(true, m.id.value, null);
  }

  AttributeMapping[] listMappings(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AttributeMapping[] listMappings(TenantId tenantId, DataSourceConfigId configId) {
    return repo.findByConfig(tenantId, configId);
  }

  AttributeMapping getMapping(TenantId tenantId, AttributeMappingId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult updateMapping(UpdateAttributeMappingRequest r) {
    auto m = repo.findById(r.tenantId, r.mappingId);
    if (m.isNull)
      return UsecaseResult(false, r.mappingId, "Mapping not found");

    if (r.sourceAttributeName.length > 0)
      m.sourceAttributeName = r.sourceAttributeName;
    if (r.sourceDataType.length > 0)
      m.sourceDataType = r.sourceDataType;
    if (r.targetAttributeName.length > 0)
      m.targetAttributeName = r.targetAttributeName;
    if (r.targetDataType.length > 0)
      m.targetDataType = r.targetDataType;
    if (r.delimiter.length > 0)
      m.delimiter = r.delimiter;
    if (r.sortOrder >= 0)
      m.sortOrder = r.sortOrder;
    m.active = r.active;

    repo.update(m);
    return UsecaseResult(true, m.id.value, null);
  }

  UsecaseResult deleteMapping(TenantId tenantId, AttributeMappingId id) {
    auto m = repo.findById(tenantId, id);
    if (m.isNull)
      return UsecaseResult(false, id, "Mapping not found");
      
    repo.remove(m);
    return UsecaseResult(true, m.id.value, null);
  }
}
