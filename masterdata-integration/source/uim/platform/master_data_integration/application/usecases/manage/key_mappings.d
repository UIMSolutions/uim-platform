/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.key_mappings;

import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.key_mapping;
import uim.platform.master_data_integration.domain.ports.repositories.key_mappings;
import uim.platform.master_data_integration.domain.services.key_mapping_resolver;
import uim.platform.master_data_integration.domain.types;

/// Application service for cross-system key mapping management.
class ManageKeyMappingsUseCase { // TODO: UIMUseCase {
  private KeyMappingRepository repo;
  private KeyMappingResolver resolver;

  this(KeyMappingRepository repo, KeyMappingResolver resolver) {
    this.repo = repo;
    this.resolver = resolver;
  }

  CommandResult create(CreateKeyMappingRequest req) {
    if (req.masterDataObjectId.isEmpty)
      return CommandResult(false, "", "Master data object ID is required");
    if (req.entries.length == 0)
      return CommandResult(false, "", "At least one key mapping entry is required");

    KeyMapping mapping;
    mapping.id = randomUUID();
    mapping.tenantId = req.tenantId;
    mapping.masterDataObjectId = req.masterDataObjectId;
    mapping.category = parseCategory(req.category);
    mapping.objectType = req.objectType;
    mapping.entries = toEntries(req.entries);
    mapping.createdAt = clockSeconds();
    mapping.updatedAt = mapping.createdAt;

    if (!resolver.isValid(mapping))
      return CommandResult(false, "",
          "Key mapping must have exactly one primary entry and all entries must have local keys");

    repo.save(mapping);
    return CommandResult(true, id.toString, "");
  }

  CommandResult updateMapping(KeyMappingId id, UpdateKeyMappingRequest req) {
    auto mapping = repo.findById(id);
    if (mapping.isNull)
      return CommandResult(false, "", "Key mapping not found");

    if (req.entries.length > 0)
      mapping.entries = toEntries(req.entries);
    mapping.updatedAt = clockSeconds();

    if (!resolver.isValid(mapping))
      return CommandResult(false, "", "Invalid key mapping: must have exactly one primary entry");

    repo.update(mapping);
    return CommandResult(true, id.toString, "");
  }

  /// Lookup: given a source client+key, find the target client's key.
  string lookupKey(LookupKeyRequest req) {
    auto mapping = repo.findByClientKey(req.tenantId, req.sourceClientId, req.sourceLocalKey);
    if (mapping.isNull)
      return "";
    return resolver.resolveLocalKey(mapping, req.targetClientId);
  }

  KeyMapping getMapping(KeyMappingId id) {
    return repo.findById(id);
  }

  KeyMapping[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  KeyMapping[] listByObjectId(TenantId tenantId, MasterDataObjectId objectId) {
    return repo.findByObjectId(tenantId, objectId);
  }

  KeyMapping[] listByCategory(TenantId tenantId, string category) {
    return repo.findByCategory(tenantId, parseCategory(category));
  }

  CommandResult deleteMapping(KeyMappingId id) {
    auto mapping = repo.findById(id);
    if (mapping.isNull)
      return CommandResult(false, "", "Key mapping not found");
    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  private KeyMappingEntry[] toEntries(KeyMappingEntryDto[] dtos) {
    KeyMappingEntry[] result;
    foreach (dto; dtos) {
      KeyMappingEntry e;
      e.clientId = dto.clientId;
      e.systemId = dto.systemId;
      e.localKey = dto.localKey;
      e.sourceType = parseSourceType(dto.sourceType);
      e.isPrimary = dto.isPrimary;
      result ~= e;
    }
    return result;
  }

  private KeyMappingSourceType parseSourceType(string s) {
    switch (s) {
    case "local":
      return KeyMappingSourceType.local;
    case "remote":
      return KeyMappingSourceType.remote;
    case "universal":
      return KeyMappingSourceType.universal;
    default:
      return KeyMappingSourceType.local;
    }
  }

  private MasterDataCategory parseCategory(string s) {
    switch (s) {
    case "businessPartner":
      return MasterDataCategory.businessPartner;
    case "costCenter":
      return MasterDataCategory.costCenter;
    case "profitCenter":
      return MasterDataCategory.profitCenter;
    case "companyCode":
      return MasterDataCategory.companyCode;
    case "workforcePerson":
      return MasterDataCategory.workforcePerson;
    case "custom":
      return MasterDataCategory.custom;
    default:
      return MasterDataCategory.businessPartner;
    }
  }
}


