module analytics.app.dto.dataset_dto;

import std.conv : to;
import analytics.domain.entities.dataset;

struct CreateDatasetRequest {
    string name;
    string description;
    string dataSourceId;
    string userId;
}

struct DatasetResponse {
    string id;
    string name;
    string description;
    string dataSourceId;
    string status;
    ColumnResponse[] columns;

    static DatasetResponse fromEntity(Dataset d) {
        if (d is null) return DatasetResponse.init;

        ColumnResponse[] cols;
        foreach (c; d.columns)
            cols ~= ColumnResponse(c.name, c.role.to!string, c.dataType.to!string);

        return DatasetResponse(
            d.id.value,
            d.name,
            d.description,
            d.dataSourceId.value,
            d.status.to!string,
            cols,
        );
    }
}

struct ColumnResponse {
    string name;
    string role;
    string dataType;
}
