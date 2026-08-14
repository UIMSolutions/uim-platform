module uim.platform.architecture.domain.entities.data_block ;

import std.conv : to;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct DataBlock {
    mixin TenantEntity!(DataBlockId);

    string name;
    string description;
    string owner;
    LifecycleStatus status;
    string versionLabel;
    string[] tags;
    string dataOwner;
    string dataClassification; // z.B. "Confidential", "Public"

    Json toJson() const {
        auto tagsJson = tags.toJson;
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("owner", owner)
            .set("status", status.toString)
            .set("versionLabel", versionLabel)
            .set("tags", tagsJson)
            .set("dataOwner", dataOwner)
            .set("dataClassification", dataClassification);
    }
}
