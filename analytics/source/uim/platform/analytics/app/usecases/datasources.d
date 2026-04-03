module uim.platform.analytics.app.usecases.datasources;

import uim.platform.analytics.domain.entities.datasource;
import uim.platform.analytics.domain.repositories.datasource;
import uim.platform.analytics.domain.values.common;
import uim.platform.analytics.app.dto.datasource;
import uim.platform.analytics.app.ports.dataconnector;
// import std.conv : to;
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

    DataSourceResponse create(CreateDataSourceRequest req) {
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

    DataSourceResponse getById(string id) {
        return DataSourceResponse.fromEntity(repo.findById(EntityId(id)));
    }

    DataSourceResponse[] list() {
        DataSourceResponse[] result;
        foreach (ds; repo.findAll())
            result ~= DataSourceResponse.fromEntity(ds);
        return result;
    }

    DataSourceResponse testConnection(string id) {
        auto ds = repo.findById(EntityId(id));
        if (ds is null) return DataSourceResponse.init;

        auto connStr = ds.connection.host ~ ":" ~ ds.connection.port.to!string;
        if (connector !is null && connector.testConnection(connStr)) {
            ds.markConnected();
        } else {
            ds.markError("Connection test failed or connector unavailable");
        }
        repo.save(ds);
        return DataSourceResponse.fromEntity(ds);
    }

    void remove(string id) {
        repo.remove(EntityId(id));
    }
}
