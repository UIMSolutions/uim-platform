module analytics.app.dto.dashboard_dto;

import std.conv : to;
import analytics.domain.entities.dashboard;
import analytics.domain.values.common;

struct CreateDashboardRequest {
    string name;
    string description;
    string ownerId;
}

struct DashboardResponse {
    string id;
    string name;
    string description;
    string ownerId;
    string visibility;
    string status;
    PageResponse[] pages;
    string[] tags;

    static DashboardResponse fromEntity(Dashboard d) {
        if (d is null) return DashboardResponse.init;

        PageResponse[] pgs;
        foreach (p; d.pages)
            pgs ~= PageResponse(p.id.value, p.title);

        return DashboardResponse(
            d.id.value,
            d.name,
            d.description,
            d.ownerId.value,
            d.visibility.to!string,
            d.status.to!string,
            pgs,
            d.tags,
        );
    }
}

struct PageResponse {
    string id;
    string title;
}
