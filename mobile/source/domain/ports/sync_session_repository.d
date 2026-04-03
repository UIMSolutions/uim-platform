module uim.platform.mobile.domain.ports.sync_session_repository;

import uim.platform.mobile.domain.entities.sync_session;
import uim.platform.mobile.domain.types;

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
