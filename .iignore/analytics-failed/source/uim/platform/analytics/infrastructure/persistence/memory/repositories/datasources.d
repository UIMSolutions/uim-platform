/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.datasources;
// import uim.platform.analytics.domain.entities.datasource;
// import uim.platform.analytics.domain.repositories.datasource;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
class MemoryDataSourceRepository : TentRepository!(DataSource, DataSourceId), DataSourceRepository {

  size_t countBySourceType(TenantId tenantId, DataSourceType sourceType) {
    return findBySourceType(tenantId, sourceType).length;
  }

  DataSource[] findBySourceType(TenantId tenantId, DataSourceType sourceType) {
    return findByTenant(tenantId).filter!(ds => ds.sourceType == sourceType).array;
  }

  void removeBySourceType(TenantId tenantId, DataSourceType sourceType) {
    foreach (ds; findBySourceType(tenantId, sourceType))
      remove(ds);
  }
}
