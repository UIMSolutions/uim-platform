module uim.platform.xyz.domain.ports.fragment_repository;

import uim.platform.xyz.domain.entities.destination_fragment;
import uim.platform.xyz.domain.types;

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
