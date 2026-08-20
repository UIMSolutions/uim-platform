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
  
  /// Creates a new catalog asset in the specified space.
  /// @param r The request containing the catalog asset details.
  UsecaseResult createCatalogAsset(CreateCatalogAssetRequest r);

  /// Retrieves a catalog asset by its ID for a given tenant and space.
  /// @param tenantId The tenant ID.
  /// @param spaceId The space ID.
  /// @param id The ID of the catalog asset to retrieve.
  CatalogAsset getCatalogAssetById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id);

  /// Lists all catalog assets for a given tenant and space.
  /// @param tenantId The tenant ID.
  /// @param spaceId The space ID.
  CatalogAsset[] listCatalogAssets(TenantId tenantId, SpaceId spaceId);

  /// Searches for catalog assets in a given space based on the provided query.
  /// @param spaceId The space ID.
  /// @param query The search query to filter catalog assets.
  CatalogAsset[] searchCatalogAssets(SpaceId spaceId, string query);

  /// Updates an existing catalog asset in the specified space.
  /// @param r The request containing the updated catalog asset details.
  UsecaseResult updateCatalogAsset(UpdateCatalogAssetRequest r);

  /// Deletes a catalog asset from the specified space.
  /// @param tenantId The tenant ID.
  /// @param spaceId The space ID.
  /// @param id The ID of the catalog asset to delete.
  UsecaseResult deleteCatalogAsset(TenantId tenantId, SpaceId spaceId, CatalogAssetId id);

}
