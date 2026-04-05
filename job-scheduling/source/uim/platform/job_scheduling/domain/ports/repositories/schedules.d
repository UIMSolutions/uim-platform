/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.ports.repositories.schedules;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.schedule;

interface ScheduleRepository {
    Schedule findById(ScheduleId id, JobId jobId, TenantId tenantId);
    Schedule[] findByJob(JobId jobId, TenantId tenantId);
    Schedule[] findByStatus(ScheduleStatus status, JobId jobId, TenantId tenantId);
    Schedule[] findActiveByTenant(TenantId tenantId);
    Schedule[] search(string query, TenantId tenantId);
    void save(Schedule s);
    void update(Schedule s);
    void remove(ScheduleId id, JobId jobId, TenantId tenantId);
    void removeAllByJob(JobId jobId, TenantId tenantId);
    long countByJob(JobId jobId, TenantId tenantId);
}
