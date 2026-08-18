/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.tls_configurations;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageTlsConfigurationsUseCase {
    private ITlsConfigurationRepository repo;

    this(ITlsConfigurationRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createTlsConfiguration(CreateTlsConfigurationRequest r) {
        auto err = DomainValidator.validate(r.tlsConfigurationId.value, r.name);
        if (err.length > 0)
            return UsecaseResult(false, "", err);

        if (repo.existsById(r.tenantId, r.tlsConfigurationId))
            return UsecaseResult(false, "", "TLS configuration already exists");

        auto c = TlsConfiguration(r.tenantId, r.tlsConfigurationId, r.createdBy);
        c.name = r.name;
        c.description = r.description;
        c.http2Enabled = r.http2Enabled;
        c.hstsEnabled = r.hstsEnabled;
        c.hstsMaxAge = r.hstsMaxAge;
        c.hstsIncludeSubDomains = r.hstsIncludeSubDomains;

        repo.save(c);
        return UsecaseResult(true, c.id.value, "");
    }

    TlsConfiguration getTlsConfiguration(TenantId tenantId, TlsConfigurationId id) {
        return repo.findById(tenantId, id);
    }

    TlsConfiguration[] listTlsConfigurations(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult updateTlsConfiguration(UpdateTlsConfigurationRequest r) {
        auto config = repo.findById(r.tenantId, r.tlsConfigurationId);
        if (config.isNull)
            return UsecaseResult(false, "", "TLS configuration not found");

        config.name = r.name;
        config.description = r.description;
        config.http2Enabled = r.http2Enabled;
        config.hstsEnabled = r.hstsEnabled;
        config.hstsMaxAge = r.hstsMaxAge;
        config.hstsIncludeSubDomains = r.hstsIncludeSubDomains;
        config.updatedBy = r.updatedBy;
        config.updatedAt = currentTimestamp();

        repo.update(config);
        return UsecaseResult(true, config.id.value, "");
    }

    UsecaseResult deleteTlsConfiguration(TenantId tenantId, TlsConfigurationId id) {
        auto config = repo.findById(tenantId, id);
        if (config.isNull)
            return UsecaseResult(false, "", "TLS configuration not found");

        repo.remove(config);
        return UsecaseResult(true, config.id.value, "");
    }
}

///
unittest {
    // auto repo = new TlsConfigurationRepository();
    // auto usecase = new ManageTlsConfigurationsUseCase(repo);
    // auto tenantId = TenantId("test-tenant");

    // // Test list
    // auto items = usecase.listTlsConfigurations(tenantId);
    // assert(items !is null);

}
