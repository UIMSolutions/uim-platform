/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.views;

// import uim.platform.datasphere.domain.entities.view_;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IViewRepository : ITenantRepository!(DataView, DataViewId) {

  bool existsById(TenantId tenantId, SpaceId spaceId, DataViewId id);
  DataView findById(TenantId tenantId, SpaceId spaceId, DataViewId id);
  void removeById(TenantId tenantId, SpaceId spaceId, DataViewId id);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  DataView[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic);
  DataView[] findBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic);
  void removeBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic);

  size_t countExposed(TenantId tenantId, SpaceId spaceId);
  DataView[] findExposed(TenantId tenantId, SpaceId spaceId);
  void removeExposed(TenantId tenantId, SpaceId spaceId);

}
