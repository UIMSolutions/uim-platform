module domain.ports.application_job_repository;

import domain.entities.application_job;
import domain.types;

/// Port: outgoing - application job persistence.
interface ApplicationJobRepository
{
    ApplicationJob* findById(ApplicationJobId id);
    ApplicationJob[] findBySystem(SystemInstanceId systemId);
    ApplicationJob[] findByTenant(TenantId tenantId);
    ApplicationJob[] findByStatus(SystemInstanceId systemId, JobStatus status);
    void save(ApplicationJob job);
    void update(ApplicationJob job);
    void remove(ApplicationJobId id);
}
