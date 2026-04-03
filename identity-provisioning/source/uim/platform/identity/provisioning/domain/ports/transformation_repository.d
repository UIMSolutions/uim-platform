module uim.platform.xyz.domain.ports.transformation_repository;

import domain.types;
import domain.entities.transformation;

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
