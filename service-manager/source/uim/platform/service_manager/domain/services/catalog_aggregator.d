module uim.platform.service_manager.domain.services.catalog_aggregator;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Aggregates service offerings and plans from registered brokers
class CatalogAggregator {
    private ServiceOfferingRepository offeringRepo;
    private ServicePlanRepository planRepo;

    this(ServiceOfferingRepository offeringRepo, ServicePlanRepository planRepo) {
        this.offeringRepo = offeringRepo;
        this.planRepo = planRepo;
    }

    /// Get all available offerings with their plans for a tenant
    ServiceOffering[] getAvailableOfferings(TenantId tenantId) {
        auto offerings = offeringRepo.findByTenant(tenantId);
        ServiceOffering[] available;
        foreach (o; offerings) {
            if (o.status == ServiceOfferingStatus.available) {
                available ~= o;
            }
        }
        return available;
    }

    /// Find plans for a specific offering
    ServicePlan[] getPlansForOffering(TenantId tenantId, ServiceOfferingId offeringId) {
        auto plans = planRepo.findByTenant(tenantId);
        ServicePlan[] matching;
        foreach (p; plans) {
            if (p.offeringId == offeringId) {
                matching ~= p;
            }
        }
        return matching;
    }

    /// Check if a plan allows new instances
    bool canProvision(TenantId tenantId, ServicePlanId planId) {
        auto plan = planRepo.findById(tenantId, planId);
        if (plan.isNull) return false;
        if (plan.maxInstances <= 0) return true;
        return true;
    }
}
