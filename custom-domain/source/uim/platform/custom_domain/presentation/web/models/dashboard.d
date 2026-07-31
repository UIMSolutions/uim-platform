/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.web.models.dashboard;

import std.array : join;
import std.conv : to;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

struct WebMetricModel {
    string label;
    string value;
}

struct WebActionModel {
    string label;
    string method;
    string path;
    string body;
}

struct WebTableModel {
    string[] headers;
    string[][] rows;
}

struct WebPageModel {
    string serviceName;
    string title;
    string tenantId;
    string intro;
    string[] highlights;
    WebMetricModel[] metrics;
    WebActionModel[] actions;
    WebTableModel table;
    string requestPath;
    string requestBody;
}

WebPageModel buildDashboardModel(string tenantId, DomainDashboard dashboard,
    CustomDomain[] domains, TlsConfiguration[] tlsConfigurations,
    DomainMapping[] mappings, DnsRecord[] dnsRecords,
    PrivateKey[] privateKeys, Certificate[] certificates,
    TrustedCertificate[] trustedCertificates) {
    WebPageModel model;
    model.serviceName = "Custom Domain";
    model.title = "Management Dashboard";
    model.tenantId = tenantId.length > 0 ? tenantId : "default";
    model.intro = "Manage domains, mappings, certificates, keys, DNS records, and TLS settings from HTML.";
    model.highlights = ["Tenant-scoped operational overview",
        "Certificate and TLS lifecycle visibility",
        "Domain-to-route mapping control",
    ];
    model.metrics = [WebMetricModel("Total domains", dashboard.totalDomains.to!string),
        WebMetricModel("Active domains", dashboard.activeDomains.to!string),
        WebMetricModel("Total certificates", dashboard.totalCertificates.to!string),
        WebMetricModel("Active certificates", dashboard.activeCertificates.to!string),
        WebMetricModel("Total mappings", dashboard.totalMappings.to!string),
        WebMetricModel("Active mappings", dashboard.activeMappings.to!string),
    ];
    model.actions = [WebActionModel("Domains", "GET", "/web/custom-domain/domains?tenantId=" ~ model.tenantId, ""),
        WebActionModel("TLS configs", "GET", "/web/custom-domain/tls-configurations?tenantId=" ~ model.tenantId, ""),
        WebActionModel("Mappings", "GET", "/web/custom-domain/mappings?tenantId=" ~ model.tenantId, ""),
        WebActionModel("DNS records", "GET", "/web/custom-domain/dns-records?tenantId=" ~ model.tenantId, ""),
        WebActionModel("Private keys", "GET", "/web/custom-domain/private-keys?tenantId=" ~ model.tenantId, ""),
        WebActionModel("Certificates", "GET", "/web/custom-domain/certificates?tenantId=" ~ model.tenantId, ""),
        WebActionModel("Trusted certs", "GET", "/web/custom-domain/trusted-certificates?tenantId=" ~ model.tenantId, ""),
    ];
    model.table.headers = ["Metric", "Value"];
    foreach (metric; dashboard.metrics) {
        auto value = metric.value.to!string;
        if (metric.unit.length > 0)
            value ~= " " ~ metric.unit;
        model.table.rows ~= [metric.name, value];
    }
    model.requestPath = "/api/v1/custom-domain/dashboard";
    return model;
}

WebPageModel buildDomainsModel(string tenantId, CustomDomain[] items) {
    auto model = buildEntityModel("Domains", tenantId,
        ["Domain name", "Status", "Environment", "Shared", "Client auth"],
        WebActionModel("Create domain", "POST", "/api/v1/custom-domain/domains", q{
{
  "customDomainId": "domain-id",
  "domainName": "example.com",
  "organizationId": "org-id",
  "spaceId": "space-id"
}
}));
    foreach (item; items) {
        model.table.rows ~= [    item.domainName,
            item.status.to!string(),
            item.environment.to!string(),
            item.isShared ? "yes" : "no",
            item.clientAuthEnabled ? "yes" : "no",
        ];
    }
    return model;
}

WebPageModel buildTlsConfigurationsModel(string tenantId, TlsConfiguration[] items) {
    auto model = buildEntityModel("TLS Configurations", tenantId,
        ["Name", "Min protocol", "Max protocol", "HTTP/2", "HSTS"],
        WebActionModel("Create TLS configuration", "POST", "/api/v1/custom-domain/tls-configurations", q{
{
  "tlsConfigurationId": "tls-config-id",
  "name": "default",
  "description": "Default TLS policy",
  "http2Enabled": true,
  "hstsEnabled": true,
  "hstsMaxAge": 31536000,
  "hstsIncludeSubDomains": true
}
}));
    foreach (item; items) {
        model.table.rows ~= [    item.name,
            item.minProtocolVersion.to!string(),
            item.maxProtocolVersion.to!string(),
            item.http2Enabled ? "yes" : "no",
            item.hstsEnabled ? "yes" : "no",
        ];
    }
    return model;
}

WebPageModel buildMappingsModel(string tenantId, DomainMapping[] items) {
    auto model = buildEntityModel("Domain Mappings", tenantId,
        ["Custom domain", "Standard route", "Custom route", "Type", "Status"],
        WebActionModel("Create mapping", "POST", "/api/v1/custom-domain/mappings", q{
{
  "domainMappingId": "mapping-id",
  "customDomainId": "domain-id",
  "standardRoute": "https://app.example.internal",
  "customRoute": "/",
  "applicationName": "app"
}
}));
    foreach (item; items) {
        model.table.rows ~= [    item.customDomainId.value,
            item.standardRoute,
            item.customRoute,
            item.mappingType.to!string(),
            item.status.to!string(),
        ];
    }
    return model;
}

WebPageModel buildDnsRecordsModel(string tenantId, DnsRecord[] items) {
    auto model = buildEntityModel("DNS Records", tenantId,
        ["Hostname", "Type", "Value", "TTL", "Validation"],
        WebActionModel("Create DNS record", "POST", "/api/v1/custom-domain/dns-records", q{
{
  "dnsRecordId": "dns-record-id",
  "customDomainId": "domain-id",
  "hostname": "example.com",
  "value": "203.0.113.10",
  "ttl": 3600
}
}));
    foreach (item; items) {
        model.table.rows ~= [    item.hostname,
            item.recordType.to!string(),
            item.value,
            item.ttl.to!string(),
            item.validationStatus.to!string(),
        ];
    }
    return model;
}

WebPageModel buildPrivateKeysModel(string tenantId, PrivateKey[] items) {
    auto model = buildEntityModel("Private Keys", tenantId,
        ["Subject", "Algorithm", "Status", "Key size", "Domains"],
        WebActionModel("Create private key", "POST", "/api/v1/custom-domain/keys", q{
{
  "privateKeyId": "key-id",
  "subject": "CN=example.com",
  "domains": ["example.com"],
  "keySize": 2048
}
}));
    foreach (item; items) {
        model.table.rows ~= [    item.subject,
            item.algorithm.to!string(),
            item.status.to!string(),
            item.keySize.to!string(),
            item.domains.join(", "),
        ];
    }
    return model;
}

WebPageModel buildCertificatesModel(string tenantId, Certificate[] items) {
    auto model = buildEntityModel("Certificates", tenantId,
        ["Subject", "Status", "Type", "Valid to", "Activated domains"],
        WebActionModel("Create certificate", "POST", "/api/v1/custom-domain/certificates", q{
{
  "certificateId": "cert-id",
  "keyId": "key-id"
}
}));
    foreach (item; items) {
        model.table.rows ~= [    item.subjectDn,
            item.status.to!string(),
            item.type.to!string(),
            item.validTo.to!string(),
            item.activatedDomains.join(", "),
        ];
    }
    return model;
}

WebPageModel buildTrustedCertificatesModel(string tenantId, TrustedCertificate[] items) {
    auto model = buildEntityModel("Trusted Certificates", tenantId,
        ["Domain", "Subject", "Status", "Auth mode", "Fingerprint"],
        WebActionModel("Create trusted certificate", "POST", "/api/v1/custom-domain/trusted-certificates", q{
{
  "trustedCertificateId": "trusted-cert-id",
  "customDomainId": "domain-id",
  "certificatePem": "-----BEGIN CERTIFICATE-----..."
}
}));
    foreach (item; items) {
        model.table.rows ~= [    item.customDomainId.value,
            item.subjectDn,
            item.status.to!string(),
            item.authMode.to!string(),
            item.fingerprint,
        ];
    }
    return model;
}

WebPageModel buildEntityModel(string title, string tenantId, string[] headers, WebActionModel action) {
    WebPageModel model;
    model.serviceName = "Custom Domain";
    model.title = title;
    model.tenantId = tenantId.length > 0 ? tenantId : "default";
    model.intro = "HTML management page for " ~ title.toLower;
    model.highlights = ["Tenant scoped view",
        "Request templates",
        "Readable resource summaries",
    ];
    model.metrics = [];
    model.actions = [action];
    model.table.headers = headers;
    model.requestPath = action.path;
    model.requestBody = action.body;
    return model;
}
