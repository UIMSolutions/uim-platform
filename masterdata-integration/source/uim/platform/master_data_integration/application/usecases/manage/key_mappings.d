/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.key_mappings;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.key_mapping;
// import uim.platform.master_data_integration.domain.ports.repositories.key_mappings;
// import uim.platform.master_data_integration.domain.services.key_mapping_resolver;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

// mixin(ShowModule!());

@safe:
/// Application service for cross-system key mapping management.
class ManageKeyMappingsUseCase { // TODO: UIMUseCase {
  private KeyMappingRepository repo;
  private KeyMappingResolver resolver;

  this(KeyMappingRepository repo, KeyMappingResolver resolver) {
    this.repo = repo;
    this.resolver = resolver;
  }

  CommandResult createKeyMapping(CreateKeyMappingRequest req) {
    if (req.masterDataObjectId.isEmpty)
      return CommandResult(false, "", "Master data object ID is required");
    if (req.entries.length == 0)
      return CommandResult(false, "", "At least one key mapping entry is required");

    KeyMapping mapping;
    mapping.initEntity(req.tenantId);

    mapping.masterDataObjectId = req.masterDataObjectId;
    mapping.category = req.category.to!MasterDataCategory;
    mapping.objectType = req.objectType;
    mapping.entries = toEntries(req.entries);

    if (!resolver.isValid(mapping))
      return CommandResult(false, "",
          "Key mapping must have exactly one primary entry and all entries must have local keys");

    repo.save(mapping);
    return CommandResult(true, mapping.id.value, "");
  }

  CommandResult updateKeyMapping(UpdateKeyMappingRequest req) {
    auto mapping = repo.findById(tenantId, req.id);
    if (mapping.isNull)
      return CommandResult(false, "", "Key mapping not found");

    if (req.entries.length > 0)
      mapping.entries = toEntries(req.entries);
    mapping.updatedAt = clockSeconds();

    if (!resolver.isValid(mapping))
      return CommandResult(false, "", "Invalid key mapping: must have exactly one primary entry");

    repo.update(mapping);
    return CommandResult(true, mapping.id.value, "");
  }

  /// Lookup: given a source client+key, find the target client's key.
  string lookupKey(LookupKeyRequest req) {
    auto mapping = repo.findByClientKey(req.tenantId, req.sourceClientId, req.sourceLocalKey);
    if (mapping.isNull)
      return ;
    return resolver.resolveLocalKey(mapping, req.targetClientId);
  }

  KeyMapping getKeyMapping(KeyMappingId id) {
    return repo.findById(tenantId, id);
  }

  KeyMapping[] listKeyMappings(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  KeyMapping[] listKeyMappings(TenantId tenantId, MasterDataObjectId objectId) {
    return repo.findByObjectId(tenantId, objectId);
  }

  KeyMapping[] listKeyMappings(TenantId tenantId, string category) {
    return repo.findByCategory(tenantId, category.to!MasterDataCategory);
  }

  CommandResult deleteKeyMapping(KeyMappingId id) {
    auto mapping = repo.findById(tenantId, id);
    if (mapping.isNull)
      return CommandResult(false, "", "Key mapping not found");

    repo.remove(mapping);
    return CommandResult(true, mapping.id.value, "");
  }

  private KeyMappingEntry[] toEntries(KeyMappingEntryDto[] dtos) {
    KeyMappingEntry[] result;
    foreach (dto; dtos) {
      KeyMappingEntry e;
      e.clientId = dto.clientId;
      e.systemId = dto.systemId;
      e.localKey = dto.localKey;
      e.sourceType = dto.sourceType.to!KeyMappingSourceType;
      e.isPrimary = dto.isPrimary;
      result ~= e;
    }
    return result;
  }

}


