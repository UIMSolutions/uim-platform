module domain.ports.subaccount_repository;

import domain.entities.subaccount;
import domain.types;

/// Port: outgoing — subaccount persistence.
interface SubaccountRepository
{
    Subaccount findById(SubaccountId id);
    Subaccount findBySubdomain(string subdomain);
    Subaccount[] findByGlobalAccount(GlobalAccountId globalAccountId);
    Subaccount[] findByDirectory(DirectoryId directoryId);
    Subaccount[] findByRegion(GlobalAccountId globalAccountId, string region);
    Subaccount[] findByStatus(GlobalAccountId globalAccountId, SubaccountStatus status);
    void save(Subaccount sub);
    void update(Subaccount sub);
    void remove(SubaccountId id);
}
