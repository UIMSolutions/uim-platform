module uim.platform.architecture.domain.entities.technology_block;

import std.conv : to;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct TechnologyBlock {
    mixin TenantEntity!(TechnologyBlockId);

    string title;
    string description;
    string owner;
    LifecycleStatus status;
    string versionLabel;
    string[] tags;
    long createdAt;
    long updatedAt;

    Json toJson() const {
        auto tagsJson = tags.toJson;
        return entityToJson
            .set("title", title)
            .set("description", description)
            .set("owner", owner)
            .set("status", status.toString)
            .set("versionLabel", versionLabel)
            .set("tags", tagsJson)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
}
