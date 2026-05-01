/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.catalog_assets;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.catalog_asset;
// import uim.platform.datasphere.domain.ports.repositories.catalog_assets;
// import uim.platform.datasphere.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageCatalogAssetsUseCase { // TODO: UIMUseCase {
  private CatalogAssetRepository repo;

  this(CatalogAssetRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateCatalogAssetRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Catalog asset name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID();

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
    ca.updatedAt = now;

    repo.save(ca);
    return CommandResult(true, ca.id.value, "");
  }

  CatalogAsset getById(SpaceId spaceId, CatalogAssetId id) {
    return repo.findById(spaceId, id);
  }

  CatalogAsset[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CatalogAsset[] search(SpaceId spaceId, string query) {
    return repo.search(query, spaceId);
  }

  CommandResult update(UpdateCatalogAssetRequest r) {
    auto existing = repo.findById(r.spaceId, r.assetId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Catalog asset not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.businessName = r.businessName;
    existing.owner = r.owner;
    existing.glossaryTerms = r.glossaryTerms;

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult remove(SpaceId spaceId, CatalogAssetId id, ) {
    auto existing = repo.findById(spaceId, id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Catalog asset not found");

    repo.remove(id, spaceId);
    return CommandResult(true, id.value, "");
  }
}
