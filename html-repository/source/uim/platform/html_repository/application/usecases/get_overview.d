/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.get_overview;
// import uim.platform.html_repository.domain.ports.repositories.html_apps;
// import uim.platform.html_repository.domain.ports.repositories.app_versions;
// import uim.platform.html_repository.domain.ports.repositories.app_files;
// import uim.platform.html_repository.domain.ports.repositories.service_instances;
// import uim.platform.html_repository.domain.ports.repositories.deployment_records;
// import uim.platform.html_repository.domain.ports.repositories.app_routes;
// import uim.platform.html_repository.domain.ports.repositories.content_caches;
// import uim.platform.html_repository.domain.types;
// import uim.platform.html_repository.application.dto;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class GetOverviewUseCase {
    private IHtmlAppRepository appRepo;
    private IAppVersionRepository versionRepo;
    private IAppFileRepository fileRepo;
    private IServiceInstanceRepository instanceRepo;
    private IDeploymentRecordRepository deploymentRepo;
    private IAppRouteRepository routeRepo;
    private IContentCacheRepository cacheRepo;

    this(IHtmlAppRepository appRepo,
        IAppVersionRepository versionRepo,
        IAppFileRepository fileRepo,
        IServiceInstanceRepository instanceRepo,
        IDeploymentRecordRepository deploymentRepo,
        IAppRouteRepository routeRepo,
        IContentCacheRepository cacheRepo) {
        this.appRepo = appRepo;
        this.versionRepo = versionRepo;
        this.fileRepo = fileRepo;
        this.instanceRepo = instanceRepo;
        this.deploymentRepo = deploymentRepo;
        this.routeRepo = routeRepo;
        this.cacheRepo = cacheRepo;
    }

    OverviewSummary getSummary(TenantId tenantId) {
        OverviewSummary s;
        s.totalApps = appRepo.countByTenant(tenantId);
        s.totalVersions = versionRepo.countByTenant(tenantId);
        s.totalFiles = fileRepo.countByTenant(tenantId);
        s.totalServiceInstances = instanceRepo.countByTenant(tenantId);
        s.totalDeployments = deploymentRepo.countByTenant(tenantId);
        s.totalRoutes = routeRepo.countByTenant(tenantId);
        s.totalCacheEntries = cacheRepo.countByTenant(tenantId);
        s.totalStorageBytesUsed = cacheRepo.totalSizeByTenant(tenantId);
        return s;
    }
}
