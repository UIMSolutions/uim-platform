module uim.platform.abap_enviroment.infrastructure.persistence.memory.application_job_repo;

// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.domain.entities.application_job;
// import uim.platform.abap_enviroment.domain.ports.application_job_repository;
// 
// import std.algorithm : filter;
// import std.array : array;

import uim.platform.abap_enviroment;
mixin(ShowModule!());
@safe:

class MemoryApplicationJobRepository : ApplicationJobRepository {
    private ApplicationJob[ApplicationJobId] store;

    ApplicationJob findById(ApplicationJobId id) {
        if (id in store)
            return store[id];
        return ApplicationJob.init;
    }

    ApplicationJob[] findBySystem(SystemInstanceId systemId) {
        return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
    }

    ApplicationJob[] findByTenant(TenantId tenantId) {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    ApplicationJob[] findByStatus(SystemInstanceId systemId, JobStatus status) {
        return store.byValue()
            .filter!(e => e.systemInstanceId == systemId && e.status == status)
            .array;
    }

    void save(ApplicationJob job) {
        store[job.id] = job;
    }

    void update(ApplicationJob job) {
        store[job.id] = job;
    }

    void remove(ApplicationJobId id) {
        store.remove(id);
    }
}
