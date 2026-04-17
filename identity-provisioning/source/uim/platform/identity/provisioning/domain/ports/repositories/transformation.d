/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.transformations;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.transformation;

interface TransformationRepository {
  bool existsById(TransformationId tenantId, id tenantId);
  Transformation findById(TransformationId tenantId, id tenantId);
  
  Transformation[] findByTenant(TenantId tenantId);
  Transformation[] findBySystem(string systemtenantId, id tenantId);
  Transformation[] findBySystemRole(TenantId tenantId, SystemRole role);
  
  void save(Transformation entity);
  void update(Transformation entity);
  void remove(TransformationId tenantId, id tenantId);
}
