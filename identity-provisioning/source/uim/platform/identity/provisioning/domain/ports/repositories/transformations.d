/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.transformations;

// import uim.platform.identity.provisioning.domain.types;
// import uim.platform.identity.provisioning.domain.entities.transformation;
import uim.platform.identity.provisioning;

// mixin(ShowModule!());

@safe:  
interface TransformationRepository : ITenantRepository!(Transformation, TransformationId) {

  size_t countBySystem(TenantId tenantId, string systemtenantId);
  Transformation[] findBySystem(TenantId tenantId, string systemtenantId);
  void removeBySystem(TenantId tenantId, string systemtenantId);

  size_t countBySystemRole(TenantId tenantId, SystemRole role);
  Transformation[] findBySystemRole(TenantId tenantId, SystemRole role);
  void removeBySystemRole(TenantId tenantId, SystemRole role);
  
}
