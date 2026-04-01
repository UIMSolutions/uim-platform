module domain.ports.software_component_repository;

import domain.entities.software_component;
import domain.types;

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
