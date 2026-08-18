/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.catalog_assets;

// import uim.platform.datasphere.domain.entities.catalog_asset;
// import uim.platform.datasphere.domain.ports.repositories.catalog_assets;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageCatalogAssetsUseCase {
  protected ICatalogAssetRepository repo;

  this(ICatalogAssetRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createCatalogAsset(CreateCatalogAssetRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "Catalog asset name is required");
      
    if (r.spaceId.isEmpty)
      return UsecaseResult(false, "", "Space ID is required");

    auto ca = CatalogAsset(r.tenantId, r.assetId);
    ca.spaceId = r.spaceId;
    ca.name = r.name;
    ca.description = r.description;
    ca.businessName = r.businessName;
    ca.sourceObjectId = r.sourceObjectId;
    ca.owner = r.owner;
    ca.glossaryTerms = r.glossaryTerms;
    ca.qualityStatus = QualityStatus.unknown;

    repo.save(ca);
    return UsecaseResult(true, ca.id.value, "");
  }

  CatalogAsset getCatalogAsset(TenantId tenantId, SpaceId spaceId, CatalogAssetId id) {
    return repo.findById(tenantId, spaceId, id);
  }

  CatalogAsset[] listCatalogAssets(TenantId tenantId, SpaceId spaceId) {
    return repo.findBySpace(tenantId, spaceId);
  }

  CatalogAsset[] searchCatalogAssets(TenantId tenantId, SpaceId spaceId, string query) {
    return repo.search(tenantId, spaceId, query);
  }

  UsecaseResult updateCatalogAsset(UpdateCatalogAssetRequest r) {
    auto asset = repo.findById(r.tenantId, r.spaceId, r.assetId);
    if (asset.isNull)
      return UsecaseResult(false, "", "Catalog asset not found");

    asset.name = r.name;
    asset.description = r.description;
    asset.businessName = r.businessName;
    asset.owner = r.owner;
    asset.glossaryTerms = r.glossaryTerms;

    
    asset.updatedAt = currentTimestamp;

    repo.update(asset);
    return UsecaseResult(true, asset.id.value, "");
  }

  UsecaseResult deleteCatalogAsset(TenantId tenantId, SpaceId spaceId, CatalogAssetId id) {
    auto asset = repo.findById(tenantId, spaceId, id);
    if (asset.isNull)
      return UsecaseResult(false, "", "Catalog asset not found");

    repo.remove(asset);
    return UsecaseResult(true, asset.id.value, "");
  }
}
