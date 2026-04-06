/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.domain_dashboard;

import uim.platform.custom_domain.domain.types;

struct DashboardMetric {
    string name;
    DashboardMetricType metricType;
    double value;
    string unit;
    long measuredAt;
}

struct CertificateExpirationWarning {
    string certificateId;
    string domainName;
    long expiresAt;
    int daysRemaining;
    ExpirationSeverity severity;
}

struct DomainDashboard {
    DomainDashboardId id;
    TenantId tenantId;
    long totalDomains;
    long activeDomains;
    long totalCertificates;
    long activeCertificates;
    long totalMappings;
    long activeMappings;
    HealthStatus overallHealth;
    DashboardMetric[] metrics;
    CertificateExpirationWarning[] expirationWarnings;
    long lastUpdatedAt;
}
