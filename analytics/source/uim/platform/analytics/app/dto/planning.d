module uim.platform.analytics.app.dto.planning;

// import std.conv : to;
import uim.platform.analytics.domain.entities.planning;
import uim.platform.analytics.domain.values.time_granularity;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
struct CreatePlanningModelRequest {
    string name;
    string description;
    string datasetId;
    string granularity;
    string userId;
}

struct PlanningModelResponse {
    string id;
    string name;
    string description;
    string datasetId;
    string granularity;
    string status;
    VersionResponse[] versions;

    static PlanningModelResponse fromEntity(PlanningModel pm) {
        if (pm is null) return PlanningModelResponse.init;

        VersionResponse[] vers;
        foreach (v; pm.versions)
            vers ~= VersionResponse(v.id.value, v.name, v.versionType.to!string, v.isReadOnly);

        return PlanningModelResponse(
            pm.id.value,
            pm.name,
            pm.description,
            pm.datasetId.value,
            pm.granularity.to!string,
            pm.planStatus.to!string,
            vers,
        );
    }
}

struct VersionResponse {
    string id;
    string name;
    string versionType;
    bool isReadOnly;
}
