/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.archiving_jobs;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageArchivingJobsUseCase { 
    
    UsecaseResult createArchivingJob(CreateArchivingJobRequest req);
    UsecaseResult updateArchivingJob(UpdateArchivingJobRequest req);
    bool hasArchivingJob(TenantId tenantId, ArchivingJobId id);
    ArchivingJob getArchivingJob(TenantId tenantId, ArchivingJobId id);
    ArchivingJob[] listArchivingJobs(TenantId tenantId);
    ArchivingJob[] listArchivingJobs(TenantId tenantId, ArchivingJobStatus status);
    UsecaseResult deleteArchivingJob(TenantId tenantId, ArchivingJobId id);

}

