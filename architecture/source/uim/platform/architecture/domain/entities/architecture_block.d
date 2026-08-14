module uim.platform.architecture.domain.entities.architecture_block;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct ArchitectureBlock {
    mixin TenantEntity!(ArchitectureBlockId);

    string name;
    string description;
    string owner;
    string lifecycleState;
    string versionLabel;
    string[] tags;
    string capabilityProvided;
    string[] requiredInterfaces;
    // DataArchitectureBlock[] associatedDataBlocks;
    LifecycleStatus status;

    Json toJson() const {
        auto tagsJson = tags.toJson;
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("owner", owner)
            .set("lifecycleState", lifecycleState)
            .set("status", status.toString)
            .set("versionLabel", versionLabel)
            .set("tags", tagsJson)
            .set("capabilityProvided", capabilityProvided)
            .set("requiredInterfaces", requiredInterfaces.toJson);
            //.set("associatedDataBlocks", associatedDataBlocks.toJson);
    }
}
