/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.catalog_assets;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IManageCatalogAssetsUseCase { 
  
  UsecaseResult createCatalogAsset(CreateCatalogAssetRequest r);
  CatalogAsset getCatalogAssetById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id);
  CatalogAsset[] listCatalogAssets(TenantId tenantId, SpaceId spaceId);
  CatalogAsset[] searchCatalogAssets(SpaceId spaceId, string query);
  UsecaseResult updateCatalogAsset(UpdateCatalogAssetRequest r);
  UsecaseResult deleteCatalogAsset(TenantId tenantId, SpaceId spaceId, CatalogAssetId id);

}
