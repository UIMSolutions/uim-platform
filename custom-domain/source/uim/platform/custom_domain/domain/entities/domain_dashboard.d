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

    Json toJson() const {
        return Json.emptyObject
            .set("name", name)
            .set("metricType", metricType.to!string)
            .set("value", value)
            .set("unit", unit)
            .set("measuredAt", measuredAt);
    }
}

struct CertificateExpirationWarning {
    string certificateId;
    string domainName;
    long expiresAt;
    int daysRemaining;
    ExpirationSeverity severity;

    Json toJson() const {
        return Json.emptyObject
            .set("certificateId", certificateId)
            .set("domainName", domainName)
            .set("expiresAt", expiresAt)
            .set("daysRemaining", daysRemaining)
            .set("severity", severity.to!string);
    }
}

struct DomainDashboard {
    mixin TenantEntity!(DomainDashboardId);

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

    Json toJson() const {
        return entityToJson
            .set("totalDomains", totalDomains)
            .set("activeDomains", activeDomains)
            .set("totalCertificates", totalCertificates)
            .set("activeCertificates", activeCertificates)
            .set("totalMappings", totalMappings)
            .set("activeMappings", activeMappings)
            .set("overallHealth", overallHealth.to!string)
            .set("metrics", metrics.array.map!(m => m.toJson()).array)
            .set("expirationWarnings", expirationWarnings.array.map!(w => w.toJson()).array)
            .set("lastUpdatedAt", lastUpdatedAt);
    }
}
