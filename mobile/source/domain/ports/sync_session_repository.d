module uim.platform.xyz.domain.ports.sync_session_repository;

import domain.entities.sync_session;
import domain.types;

/// Port: outgoing — sync session persistence.
interface SyncSessionRepository
{
    SyncSession findById(SyncSessionId id);
    SyncSession[] findByConfig(OfflineConfigId configId);
    SyncSession[] findByDevice(string deviceId);
    SyncSession[] findByStatus(OfflineConfigId configId, SyncSessionStatus status);
    void save(SyncSession session);
    void update(SyncSession session);
    void remove(SyncSessionId id);
}
