/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.container;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

struct Container {
    // Repositories (driven adapters)
    MemoryCustomDomainRepository domainRepo;
    MemoryPrivateKeyRepository keyRepo;
    MemoryCertificateRepository certRepo;
    MemoryTlsConfigurationRepository tlsRepo;
    MemoryDomainMappingRepository mappingRepo;
    MemoryTrustedCertificateRepository trustedCertRepo;
    MemoryDnsRecordRepository dnsRepo;
    MemoryDomainDashboardRepository dashboardRepo;

    // Use cases (application layer)
    ManageCustomDomainsUseCase manageDomains;
    ManagePrivateKeysUseCase manageKeys;
    ManageCertificatesUseCase manageCertificates;
    ManageTlsConfigurationsUseCase manageTlsConfigs;
    ManageDomainMappingsUseCase manageMappings;
    ManageTrustedCertificatesUseCase manageTrustedCerts;
    ManageDnsRecordsUseCase manageDnsRecords;
    ManageDomainDashboardsUseCase manageDashboards;

    // Controllers (driving adapters)
    CustomDomainController domainController;
    PrivateKeyController keyController;
    CertificateController certController;
    TlsConfigurationController tlsController;
    DomainMappingController mappingController;
    TrustedCertificateController trustedCertController;
    DnsRecordController dnsController;
    DomainDashboardController dashboardController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Infrastructure adapters
    c.domainRepo = new MemoryCustomDomainRepository();
    c.keyRepo = new MemoryPrivateKeyRepository();
    c.certRepo = new MemoryCertificateRepository();
    c.tlsRepo = new MemoryTlsConfigurationRepository();
    c.mappingRepo = new MemoryDomainMappingRepository();
    c.trustedCertRepo = new MemoryTrustedCertificateRepository();
    c.dnsRepo = new MemoryDnsRecordRepository();
    c.dashboardRepo = new MemoryDomainDashboardRepository();

    // Application use cases
    c.manageDomains = new ManageCustomDomainsUseCase(c.domainRepo);
    c.manageKeys = new ManagePrivateKeysUseCase(c.keyRepo);
    c.manageCertificates = new ManageCertificatesUseCase(c.certRepo);
    c.manageTlsConfigs = new ManageTlsConfigurationsUseCase(c.tlsRepo);
    c.manageMappings = new ManageDomainMappingsUseCase(c.mappingRepo);
    c.manageTrustedCerts = new ManageTrustedCertificatesUseCase(c.trustedCertRepo);
    c.manageDnsRecords = new ManageDnsRecordsUseCase(c.dnsRepo);
    c.manageDashboards = new ManageDomainDashboardsUseCase(c.dashboardRepo, c.domainRepo, c.certRepo, c.mappingRepo);

    // Presentation controllers
    c.domainController = new CustomDomainController(c.manageDomains);
    c.keyController = new PrivateKeyController(c.manageKeys);
    c.certController = new CertificateController(c.manageCertificates);
    c.tlsController = new TlsConfigurationController(c.manageTlsConfigs);
    c.mappingController = new DomainMappingController(c.manageMappings);
    c.trustedCertController = new TrustedCertificateController(c.manageTrustedCerts);
    c.dnsController = new DnsRecordController(c.manageDnsRecords);
    c.dashboardController = new DomainDashboardController(c.manageDashboards);
    c.healthController = new HealthController("custom-domain", "1.0.0");

    return c;
}
