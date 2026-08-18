/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.domain_dashboards;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageDomainDashboardsUseCase {
    private IDomainDashboardRepository dashboardRepo;
    private ICustomDomainRepository domainRepo;
    private ICertificateRepository certRepo;
    private IDomainMappingRepository mappingRepo;

    this(IDomainDashboardRepository dashboardRepo, ICustomDomainRepository domainRepo,
         ICertificateRepository certRepo, IDomainMappingRepository mappingRepo) {
        this.dashboardRepo = dashboardRepo;
        this.domainRepo = domainRepo;
        this.certRepo = certRepo;
        this.mappingRepo = mappingRepo;
    }

    DomainDashboard getDashboard(TenantId tenantId) {
        return dashboardRepo.get(tenantId);
    }

    CommandResult refreshDashboard(RefreshDashboardRequest r) {
        if (r.tenantId.isEmpty)
            return CommandResult(false, "", "Tenant ID is required");

        auto domains = domainRepo.findByTenant(r.tenantId);
        auto certs = certRepo.findByTenant(r.tenantId);
        auto mappings = mappingRepo.findByTenant(r.tenantId);

        long activeDomains = 0;
        foreach (d; domains) {
            if (d.status == DomainStatus.active)
                activeDomains++;
        }

        long activeCerts = 0;
        foreach (c; certs) {
            if (c.status == CertificateStatus.active)
                activeCerts++;
        }

        long activeMappings = 0;
        foreach (m; mappings) {
            if (m.status == MappingStatus.active)
                activeMappings++;
        }

        auto dashboard = dashboardRepo.get(r.tenantId);
        bool isNew = dashboard.isNull;
        if (isNew)
            dashboard.id = r.tenantId.value ~ "-dashboard";

        dashboard.tenantId = r.tenantId;
        dashboard.totalDomains = domains.length;
        dashboard.activeDomains = activeDomains;
        dashboard.totalCertificates = certs.length;
        dashboard.activeCertificates = activeCerts;
        dashboard.totalMappings = mappings.length;
        dashboard.activeMappings = activeMappings;

        if (activeDomains == domains.length && domains.length > 0)
            dashboard.overallHealth = HealthStatus.healthy;
        else if (activeDomains > 0)
            dashboard.overallHealth = HealthStatus.warning;
        else if (domains.length > 0)
            dashboard.overallHealth = HealthStatus.critical;
        else
            dashboard.overallHealth = HealthStatus.unknown;

        
        dashboard.lastUpdatedAt = currentTimestamp;

        if (isNew)
            dashboardRepo.save(dashboard);
        else
            dashboardRepo.update(dashboard);

        return CommandResult(true, dashboard.id.value, "");
    }
}

///
unittest {
    // auto domainDashboardRepository = new DomainDashboardRepository();
    // auto customDomainRepository = new CustomDomainRepository();
    // auto certificateRepository = new CertificateRepository();
    // auto domainMappingRepository = new DomainMappingRepository();
    // auto usecase = new ManageDomainDashboardsUseCase(domainDashboardRepository, customDomainRepository, certificateRepository, domainMappingRepository);
    // auto tenantId = TenantId("test-tenant");

    // assert(usecase !is null);
}
