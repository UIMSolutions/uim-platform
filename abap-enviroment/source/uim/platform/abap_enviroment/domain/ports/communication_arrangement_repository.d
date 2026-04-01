module domain.ports.communication_arrangement_repository;

import domain.entities.communication_arrangement;
import domain.types;

/// Port: outgoing - communication arrangement persistence.
interface CommunicationArrangementRepository
{
    CommunicationArrangement* findById(CommunicationArrangementId id);
    CommunicationArrangement[] findBySystem(SystemInstanceId systemId);
    CommunicationArrangement[] findByTenant(TenantId tenantId);
    CommunicationArrangement[] findByDirection(SystemInstanceId systemId, CommunicationDirection dir);
    void save(CommunicationArrangement arrangement);
    void update(CommunicationArrangement arrangement);
    void remove(CommunicationArrangementId id);
}
