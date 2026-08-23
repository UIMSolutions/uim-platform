module uim.platform.architecture.domain.entities.data_block ;

import std.conv : to;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct DataBlock {
    mixin TenantEntity!(DataBlockId);

    string title;
    string description;
    string owner;
    LifecycleStatus status;
    string versionLabel;
    string[] tags;
    string dataOwner;
    string dataClassification; // z.B. "Confidential", "Public"
    LeanIXDataObjectType leanixObjectType;
    string leanixFactSheetId;
    string sourceSystem;
    ArchiMateDomain archimateDomain;
    ArchiMateAspect archimateAspect;
    string viewpoint;
    ArchiMateRelationship[] relationships;

    Json toJson() const {
        auto tagsJson = tags.toJson;
        return entityToJson
            .set("title", title)
            .set("description", description)
            .set("owner", owner)
            .set("status", status.toString)
            .set("versionLabel", versionLabel)
            .set("tags", tagsJson)
            .set("dataOwner", dataOwner)
            .set("dataClassification", dataClassification)
            .set("leanixObjectType", leanixObjectType.toString)
            .set("leanixFactSheetId", leanixFactSheetId)
            .set("sourceSystem", sourceSystem)
            .set("archimateDomain", archimateDomain.toString)
            .set("archimateAspect", archimateAspect.toString)
            .set("viewpoint", viewpoint)
            .set("relationships", relationships.toJson);
    }
}
