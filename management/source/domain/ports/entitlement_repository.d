module domain.ports.entitlement_repository;

import domain.entities.entitlement;
import domain.types;

/// Port: outgoing — entitlement persistence.
interface EntitlementRepository
{
    Entitlement findById(EntitlementId id);
    Entitlement[] findByGlobalAccount(GlobalAccountId globalAccountId);
    Entitlement[] findBySubaccount(SubaccountId subaccountId);
    Entitlement[] findByDirectory(DirectoryId directoryId);
    Entitlement[] findByServicePlan(GlobalAccountId globalAccountId, ServicePlanId planId);
    void save(Entitlement ent);
    void update(Entitlement ent);
    void remove(EntitlementId id);
}
