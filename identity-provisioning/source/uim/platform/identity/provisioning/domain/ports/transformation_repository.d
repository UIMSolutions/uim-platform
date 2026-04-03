module uim.platform.identity.provisioning.domain.ports.transformation_repository;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.transformation;

interface TransformationRepository
{
  Transformation[] findByTenant(TenantId tenantId);
  Transformation* findById(TransformationId id, TenantId tenantId);
  Transformation[] findBySystem(string systemId, TenantId tenantId);
  Transformation[] findBySystemRole(TenantId tenantId, SystemRole role);
  void save(Transformation entity);
  void update(Transformation entity);
  void remove(TransformationId id, TenantId tenantId);
}
