/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.views;

// import uim.platform.datasphere.domain.entities.view_;
import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
interface ViewRepository : ITentRepository!(View, ViewId) {

  bool existsById(TenantId tenantId, SpaceId spaceId, ViewId id);
  View findById(TenantId tenantId, SpaceId spaceId, ViewId id);
  void removeById(TenantId tenantId, SpaceId spaceId, ViewId id);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  View[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic);
  View[] findBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic);
  void removeBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic);

  size_t countExposed(TenantId tenantId, SpaceId spaceId);
  View[] findExposed(TenantId tenantId, SpaceId spaceId);
  void removeExposed(TenantId tenantId, SpaceId spaceId);

}
