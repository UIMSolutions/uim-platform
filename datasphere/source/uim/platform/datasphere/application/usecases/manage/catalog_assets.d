/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.catalog_assets;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.catalog_asset;
import uim.platform.datasphere.domain.ports.repositories.catalog_assets;
import uim.platform.datasphere.application.dto;

import uim.platform.service;
import std.conv : to;

class ManageCatalogAssetsUseCase : UIMUseCase {
  private CatalogAssetRepository repo;

  this(CatalogAssetRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateCatalogAssetRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Catalog asset name is required");
    if (r.spaceid.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID().to!string;

    CatalogAsset ca;
    ca.id = randomUUID();
    ca.tenantId = r.tenantId;
    ca.spaceId = r.spaceId;
    ca.name = r.name;
    ca.description = r.description;
    ca.businessName = r.businessName;
    ca.sourceObjectId = r.sourceObjectId;
    ca.owner = r.owner;
    ca.glossaryTerms = r.glossaryTerms;
    ca.qualityStatus = QualityStatus.unknown;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    ca.createdAt = now;
    ca.modifiedAt = now;

    repo.save(ca);
    return CommandResult(true, ca.id, "");
  }

  CatalogAsset get_(CatalogAssetId id, SpaceId spaceId) {
    return repo.findById(id, spaceId);
  }

  CatalogAsset[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CatalogAsset[] search(string query, SpaceId spaceId) {
    return repo.search(query, spaceId);
  }

  CommandResult update(UpdateCatalogAssetRequest r) {
    auto existing = repo.findById(r.assetId, r.spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Catalog asset not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.businessName = r.businessName;
    existing.owner = r.owner;
    existing.glossaryTerms = r.glossaryTerms;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(CatalogAssetId id, SpaceId spaceId) {
    auto existing = repo.findById(id, spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Catalog asset not found");

    repo.remove(id, spaceId);
    return CommandResult(true, id, "");
  }
}
