module uim.platform.abap_enviroment.domain.ports.software_component_repository;

import uim.platform.abap_enviroment.domain.entities.software_component;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - software component persistence.
interface SoftwareComponentRepository
{
  SoftwareComponent* findById(SoftwareComponentId id);
  SoftwareComponent[] findBySystem(SystemInstanceId systemId);
  SoftwareComponent[] findByTenant(TenantId tenantId);
  SoftwareComponent* findByName(SystemInstanceId systemId, string name);
  void save(SoftwareComponent component);
  void update(SoftwareComponent component);
  void remove(SoftwareComponentId id);
}
