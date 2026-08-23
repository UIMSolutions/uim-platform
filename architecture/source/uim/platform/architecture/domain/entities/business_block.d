module uim.platform.architecture.domain.entities.business_block;

import std.conv : to;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct BusinessBlock {
    mixin TenantEntity!(BusinessBlockId);

    string title;
    string description;
    string owner;
    string lifecycleState;
    LifecycleStatus status;
    string versionLabel;
    string[] tags;
    ArchiMateDomain archimateDomain;
    ArchiMateAspect archimateAspect;
    string viewpoint;
    ArchiMateRelationship[] relationships;
    long createdAt;
    long updatedAt;

    Json toJson() const {
        auto tagsJson = tags.toJson;
        return entityToJson
            .set("title", title)
            .set("description", description)
            .set("owner", owner)
            .set("lifecycleState", lifecycleState)
            .set("status", status.toString)
            .set("versionLabel", versionLabel)
            .set("tags", tagsJson)
            .set("archimateDomain", archimateDomain.toString)
            .set("archimateAspect", archimateAspect.toString)
            .set("viewpoint", viewpoint)
            .set("relationships", relationships.toJson)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
}
