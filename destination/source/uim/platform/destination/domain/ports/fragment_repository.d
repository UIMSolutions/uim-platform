module uim.platform.xyz.domain.ports.fragment_repository;

import domain.entities.destination_fragment;
import domain.types;

/// Port: outgoing — destination fragment persistence.
interface FragmentRepository
{
    DestinationFragment findById(FragmentId id);
    DestinationFragment findByName(TenantId tenantId, SubaccountId subaccountId, string name);
    DestinationFragment[] findByTenant(TenantId tenantId);
    DestinationFragment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
    void save(DestinationFragment fragment);
    void update(DestinationFragment fragment);
    void remove(FragmentId id);
}
