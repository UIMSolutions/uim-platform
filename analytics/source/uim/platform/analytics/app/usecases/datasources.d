/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.datasources;
// import uim.platform.analytics.domain.entities.datasource;
// import uim.platform.analytics.domain.repositories.datasource;
// import uim.platform.analytics.domain.values.common;
// import uim.platform.analytics.app.dto.datasource;
// import uim.platform.analytics.app.ports.dataconnector;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class DataSourceUseCases {
  private DataSourceRepository repo;
  private DataConnector connector;

  this(DataSourceRepository repo, DataConnector connector) {
    this.repo = repo;
    this.connector = connector;
  }

  DataSourceResponse createSource(CreateDataSourceRequest req) {
    DataSourceType st;
    try {
      st = req.sourceType.to!DataSourceType;
    } catch (Exception) {
      st = DataSourceType.Database;
    }
    auto conn = ConnectionInfo(req.host, req.port, req.databaseName, req.username, "");
    auto ds = DataSource.create(req.name, st, conn, req.userId);
    repo.save(ds);
    return DataSourceResponse.fromEntity(ds);
  }

  DataSourceResponse getSource(TenantId tenantId, DataSourceId id) {
    return DataSourceResponse.fromEntity(repo.findById(tenantId, id));
  }

  DataSourceResponse[] listSources(TenantId tenantId) {
    DataSourceResponse[] result;
    foreach (ds; repo.findAll(tenantId))
      result ~= DataSourceResponse.fromEntity(ds);
    return result;
  }

  DataSourceResponse testConnection(TenantId tenantId, DataSourceId id) {
    auto ds = repo.findById(tenantId, id);
    if (ds.isNull)
      return DataSourceResponse.init;

    auto connStr = ds.connection.host ~ ":" ~ ds.connection.port.to!string;
    if (connector !is null && connector.testConnection(connStr)) {
      ds.markConnected();
    } else {
      ds.markError("Connection test failed or connector unavailable");
    }
    repo.save(ds);
    return DataSourceResponse.fromEntity(ds);
  }

  CommandResult deleteSource(TenantId tenantId, DataSourceId id) {
    auto ds = repo.findById(tenantId, id);
    if (ds.isNull)
      return CommandResult(false, "", "Data source not found");

    repo.remove(ds);
    return CommandResult(true, id.value, "");
  }
}
