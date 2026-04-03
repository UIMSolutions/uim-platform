module uim.platform.mobile.domain.ports.client_log_repository;

import uim.platform.mobile.domain.entities.client_log;
import uim.platform.mobile.domain.types;

/// Port: outgoing — client log persistence.
interface ClientLogRepository
{
    ClientLog findById(ClientLogId id);
    ClientLog[] findByApp(MobileAppId appId);
    ClientLog[] findByDevice(MobileAppId appId, string deviceId);
    ClientLog[] findBySeverity(MobileAppId appId, LogSeverity severity);
    ClientLog[] findByUser(MobileAppId appId, string userId);
    void save(ClientLog log);
    void remove(ClientLogId id);
}
