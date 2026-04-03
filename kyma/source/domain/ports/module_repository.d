module uim.platform.xyz.domain.ports.module_repository;

import uim.platform.xyz.domain.entities.kyma_module;
import uim.platform.xyz.domain.types;

/// Port: outgoing — Kyma module persistence.
interface ModuleRepository
{
    KymaModule findById(ModuleId id);
    KymaModule findByName(KymaEnvironmentId envId, string name);
    KymaModule[] findByEnvironment(KymaEnvironmentId envId);
    KymaModule[] findByStatus(ModuleStatus status);
    KymaModule[] findByType(ModuleType moduleType);
    void save(KymaModule mod);
    void update(KymaModule mod);
    void remove(ModuleId id);
}
