/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.web.controllers.dashboard;

import uim.platform.custom_domain;
import uim.platform.custom_domain.presentation.web.models;
import uim.platform.custom_domain.presentation.web.views;

mixin(ShowModule!());

@safe:

class CustomDomainWebController {
    private ManageCustomDomainsUseCase domains;
    private ManageTlsConfigurationsUseCase tlsConfigs;
    private ManageDomainMappingsUseCase mappings;
    private ManageDnsRecordsUseCase dnsRecords;
    private ManagePrivateKeysUseCase privateKeys;
    private ManageCertificatesUseCase certificates;
    private ManageTrustedCertificatesUseCase trustedCertificates;
    private ManageDomainDashboardsUseCase dashboards;
    private CustomDomainWebView view;

    this(ManageCustomDomainsUseCase domains, ManageTlsConfigurationsUseCase tlsConfigs,
        ManageDomainMappingsUseCase mappings, ManageDnsRecordsUseCase dnsRecords,
        ManagePrivateKeysUseCase privateKeys, ManageCertificatesUseCase certificates,
        ManageTrustedCertificatesUseCase trustedCertificates,
        ManageDomainDashboardsUseCase dashboards) {
        this.domains = domains;
        this.tlsConfigs = tlsConfigs;
        this.mappings = mappings;
        this.dnsRecords = dnsRecords;
        this.privateKeys = privateKeys;
        this.certificates = certificates;
        this.trustedCertificates = trustedCertificates;
        this.dashboards = dashboards;
        this.view = CustomDomainWebView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/custom-domain", &handleDashboard);
        router.get("/web/custom-domain/domains", &handleDomains);
        router.get("/web/custom-domain/tls-configurations", &handleTlsConfigurations);
        router.get("/web/custom-domain/mappings", &handleMappings);
        router.get("/web/custom-domain/dns-records", &handleDnsRecords);
        router.get("/web/custom-domain/private-keys", &handlePrivateKeys);
        router.get("/web/custom-domain/certificates", &handleCertificates);
        router.get("/web/custom-domain/trusted-certificates", &handleTrustedCertificates);
    }

    private void handleDashboard(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = req.query.get("tenantId", "default");
        auto tenant = TenantId(tenantId);
        auto model = buildDashboardModel(tenantId,
            dashboards.getDashboard(tenant),
            domains.listDomains(tenant),
            tlsConfigs.listTlsConfigurations(tenant),
            mappings.listDomainMappings(tenant),
            dnsRecords.listDnsRecords(tenant),
            privateKeys.listPrivateKeys(tenant),
            certificates.listCertificates(tenant),
            trustedCertificates.listCertificates(tenant));
        res.writeBody(view.renderDashboard(model), cast(int)HTTPStatus.ok,
            "text/html; charset=utf-8");
    }

    private void handleDomains(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = req.query.get("tenantId", "default");
        auto model = buildDomainsModel(tenantId, domains.listDomains(TenantId(tenantId)));
        res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok,
            "text/html; charset=utf-8");
    }

    private void handleTlsConfigurations(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = req.query.get("tenantId", "default");
        auto model = buildTlsConfigurationsModel(tenantId,
            tlsConfigs.listTlsConfigurations(TenantId(tenantId)));
        res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok,
            "text/html; charset=utf-8");
    }

    private void handleMappings(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = req.query.get("tenantId", "default");
        auto model = buildMappingsModel(tenantId, mappings.listDomainMappings(TenantId(tenantId)));
        res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok,
            "text/html; charset=utf-8");
    }

    private void handleDnsRecords(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = req.query.get("tenantId", "default");
        auto model = buildDnsRecordsModel(tenantId, dnsRecords.listDnsRecords(TenantId(tenantId)));
        res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok,
            "text/html; charset=utf-8");
    }

    private void handlePrivateKeys(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = req.query.get("tenantId", "default");
        auto model = buildPrivateKeysModel(tenantId, privateKeys.listPrivateKeys(TenantId(tenantId)));
        res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok,
            "text/html; charset=utf-8");
    }

    private void handleCertificates(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = req.query.get("tenantId", "default");
        auto model = buildCertificatesModel(tenantId, certificates.listCertificates(TenantId(tenantId)));
        res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok,
            "text/html; charset=utf-8");
    }

    private void handleTrustedCertificates(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenantId = req.query.get("tenantId", "default");
        auto model = buildTrustedCertificatesModel(tenantId,
            trustedCertificates.listCertificates(TenantId(tenantId)));
        res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok,
            "text/html; charset=utf-8");
    }
}
