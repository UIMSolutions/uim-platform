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



import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageCatalogAssetsUseCase { // TODO: UIMUseCase {
  private CatalogAssetRepository repo;

  this(CatalogAssetRepository repo) {
    this.repo = repo;
  }

  CommandResult createCatalogAsset(CreateCatalogAssetRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Catalog asset name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID();

    CatalogAsset ca;
    ca.id = r.assetId;
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

  CatalogAsset getCatalogAssetById(SpaceId spaceId, CatalogAssetId id) {
    return repo.findById(spaceId, id);
  }

  CatalogAsset[] listCatalogAssets(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CatalogAsset[] searchCatalogAssets(SpaceId spaceId, string query) {
    return repo.search(spaceId, query);
  }

  CommandResult updateCatalogAsset(UpdateCatalogAssetRequest r) {
    auto asset = repo.findById(r.spaceId, r.assetId);
    if (asset.isNull)
      return CommandResult(false, "", "Catalog asset not found");

    asset.name = r.name;
    asset.description = r.description;
    asset.businessName = r.businessName;
    asset.owner = r.owner;
    asset.glossaryTerms = r.glossaryTerms;

    import core.time : MonoTime;
    asset.updatedAt = MonoTime.currTime.ticks;

    repo.update(asset);
    return CommandResult(true, asset.id.value, "");
  }

  CommandResult deleteCatalogAsset(SpaceId spaceId, CatalogAssetId id) {
    auto asset = repo.findById(spaceId, id);
    if (asset.isNull)
      return CommandResult(false, "", "Catalog asset not found");

    repo.remove(asset);
    return CommandResult(true, asset.id.value, "");
  }
}
