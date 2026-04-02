module domain.ports.service_plan_repository;

import domain.entities.service_plan;
import domain.types;

/// Port: outgoing — service plan catalog persistence.
interface ServicePlanRepository
{
    ServicePlan findById(ServicePlanId id);
    ServicePlan[] findByService(string serviceName);
    ServicePlan[] findByCategory(ServicePlanCategory category);
    ServicePlan[] findByRegion(string region);
    ServicePlan[] findAll();
    void save(ServicePlan plan);
    void update(ServicePlan plan);
    void remove(ServicePlanId id);
}
