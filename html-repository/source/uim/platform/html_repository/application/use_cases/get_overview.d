/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.use_cases.get_overview;

import uim.platform.html_repository.domain.ports.html_app_repository;
import uim.platform.html_repository.domain.ports.app_version_repository;
import uim.platform.html_repository.domain.ports.app_file_repository;
import uim.platform.html_repository.domain.ports.service_instance_repository;
import uim.platform.html_repository.domain.ports.deployment_record_repository;
import uim.platform.html_repository.domain.ports.app_route_repository;
import uim.platform.html_repository.domain.ports.content_cache_repository;
import uim.platform.html_repository.domain.types;
import uim.platform.html_repository.application.dto;

class GetOverviewUseCase : UIMUseCase {
    private HtmlAppRepository appRepo;
    private AppVersionRepository versionRepo;
    private AppFileRepository fileRepo;
    private ServiceInstanceRepository instanceRepo;
    private DeploymentRecordRepository deploymentRepo;
    private AppRouteRepository routeRepo;
    private ContentCacheRepository cacheRepo;

    this(
        HtmlAppRepository appRepo,
        AppVersionRepository versionRepo,
        AppFileRepository fileRepo,
        ServiceInstanceRepository instanceRepo,
        DeploymentRecordRepository deploymentRepo,
        AppRouteRepository routeRepo,
        ContentCacheRepository cacheRepo,
    ) {
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
