module uim.platform.analytics.app.dto.datasource;

import std.conv : to;
import analytics.domain.entities.datasource;

struct CreateDataSourceRequest {
    string name;
    string sourceType;
    string host;
    int port;
    string databaseName;
    string username;
    string userId;
}

struct DataSourceResponse {
    string id;
    string name;
    string sourceType;
    string host;
    int port;
    string databaseName;
    string status;

    static DataSourceResponse fromEntity(DataSource ds) {
        if (ds is null) return DataSourceResponse.init;

        return DataSourceResponse(
            ds.id.value,
            ds.name,
            ds.sourceType.to!string,
            ds.connection.host,
            ds.connection.port,
            ds.connection.databaseName,
            ds.connStatus.to!string,
        );
    }
}
