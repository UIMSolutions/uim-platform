module domain.ports.environment_instance_repository;

import domain.entities.environment_instance;
import domain.types;

/// Port: outgoing — environment instance persistence.
interface EnvironmentInstanceRepository
{
    EnvironmentInstance findById(EnvironmentInstanceId id);
    EnvironmentInstance[] findBySubaccount(SubaccountId subaccountId);
    EnvironmentInstance[] findByType(SubaccountId subaccountId, EnvironmentType envType);
    EnvironmentInstance[] findByStatus(SubaccountId subaccountId, EnvironmentStatus status);
    void save(EnvironmentInstance inst);
    void update(EnvironmentInstance inst);
    void remove(EnvironmentInstanceId id);
}
