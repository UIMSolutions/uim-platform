module domain.ports.global_account_repository;

import domain.entities.global_account;
import domain.types;

/// Port: outgoing — global account persistence.
interface GlobalAccountRepository
{
    GlobalAccount findById(GlobalAccountId id);
    GlobalAccount[] findByStatus(GlobalAccountStatus status);
    GlobalAccount[] findAll();
    void save(GlobalAccount account);
    void update(GlobalAccount account);
    void remove(GlobalAccountId id);
}
