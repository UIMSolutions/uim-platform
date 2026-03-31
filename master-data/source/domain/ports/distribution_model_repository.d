module domain.ports.distribution_model_repository;

import domain.entities.distribution_model;
import domain.types;

/// Port: outgoing — distribution model persistence.
interface DistributionModelRepository
{
    DistributionModel findById(DistributionModelId id);
    DistributionModel[] findByTenant(TenantId tenantId);
    DistributionModel[] findByStatus(TenantId tenantId, DistributionModelStatus status);
    DistributionModel[] findBySourceClient(TenantId tenantId, ClientId sourceClientId);
    void save(DistributionModel model);
    void update(DistributionModel model);
    void remove(DistributionModelId id);
}
