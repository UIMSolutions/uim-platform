/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.data_source_configs;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class ManageDataSourceConfigsUseCase {
  private DataSourceConfigRepository repo;

  this(DataSourceConfigRepository repo) { this.repo = repo; }

  CommandResult create(CreateDataSourceConfigRequest r) {
    auto cfg = DataSourceConfig.init(r.tenantId);
    cfg.id = DataSourceConfigId(r.id.length > 0 ? r.id : currentTimestamp());
    cfg.dataProductId = DataProductId(r.dataProductId);
    cfg.providerId = DataProviderId(r.providerId);
    cfg.qualityRank = r.qualityRank.length > 0
      ? cast(DataQualityRank) r.qualityRank
      : DataQualityRank.medium;
    cfg.timestampConfig = TimestampConfig(r.timestampFormat, r.timestampField, r.timestampCustomPattern);
    cfg.enabled = r.enabled;
    cfg.disabledRuleIds = r.disabledRuleIds;

    auto err = ComposerValidator.validateDataSourceConfig(cfg);
    if (err !is null) return CommandResult(false, cfg.id.value, err);

    repo.save(cfg);
    return CommandResult(true, cfg.id.value, null);
  }

  DataSourceConfig[] list(TenantId tenantId) {
    return repo.findByTenant(TenantId(tenantId));
  }

  DataSourceConfig[] listByProduct(TenantId tenantId, string productId) {
    return repo.findByProduct(TenantId(tenantId), DataProductId(productId));
  }

  DataSourceConfig getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), DataSourceConfigId(id));
  }

  CommandResult update(UpdateDataSourceConfigRequest r) {
    auto cfg = repo.findById(TenantId(r.tenantId), DataSourceConfigId(r.id));
    if (cfg.isNull) return CommandResult(false, r.id, "Config not found");

    if (r.qualityRank.length > 0) cfg.qualityRank = cast(DataQualityRank) r.qualityRank;
    cfg.timestampConfig = TimestampConfig(r.timestampFormat, r.timestampField, r.timestampCustomPattern);
    cfg.enabled = r.enabled;
    cfg.disabledRuleIds = r.disabledRuleIds;

    repo.update(cfg);
    return CommandResult(true, cfg.id.value, null);
  }

  CommandResult addIdentifierMapping(AddIdentifierMappingRequest r) {
    auto cfg = repo.findById(TenantId(r.tenantId), DataSourceConfigId(r.configId));
    if (cfg.isNull) return CommandResult(false, r.configId, "Config not found");

    IdentifierMapping m;
    m.ruleId = r.ruleId;
    m.ruleAttributeName = r.ruleAttributeName;
    m.sourceAttributeName = r.sourceAttributeName;
    m.transformationType = r.transformationType;

    IdentifierMapping[] updated = cfg.identifierMappings;
    updated ~= m;
    cfg.identifierMappings = updated;

    repo.update(cfg);
    return CommandResult(true, r.configId, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto cfg = repo.findById(TenantId(tenantId), DataSourceConfigId(id));
    if (cfg.isNull) return CommandResult(false, id, "Config not found");
    repo.remove(TenantId(tenantId), DataSourceConfigId(id));
    return CommandResult(true, id, null);
  }
}
