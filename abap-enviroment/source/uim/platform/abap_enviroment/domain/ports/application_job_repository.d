module uim.platform.abap_enviroment.domain.ports.application_job_repository;

import uim.platform.abap_enviroment.domain.entities.application_job;
import uim.platform.abap_enviroment.domain.types;

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
