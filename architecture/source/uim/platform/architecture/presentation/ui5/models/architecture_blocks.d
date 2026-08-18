module uim.platform.architecture.presentation.ui5.models.architecture_blocks;

import std.array : join;
import std.string : split, strip;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct Ui5ArchitectureBlockItem {
    string id;
    string name;
    string description;
    string owner;
    string status;
    string lifecycle;
    string versionLabel;
    string tags;
}

struct Ui5ArchitectureBlockPageModel {
    string title;
    string subtitle;
    string tenantId;
    string blockType;
    Ui5ArchitectureBlockItem[] items;
}

struct Ui5ArchitectureBlockDetailModel {
    string title;
    string subtitle;
    string tenantId;
    string blockType;
    bool found;
    Ui5ArchitectureBlockItem item;
}

class ArchitectureBlockUi5Model {
    private ManageArchitectureBlocksUseCase architectureUseCase;

    this(
        ManageArchitectureBlocksUseCase architectureUseCase,
    ) {
        this.architectureUseCase = architectureUseCase;
    }

    Ui5ArchitectureBlockPageModel architecturePage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Architecture Architecture Blocks", "Capability-focused architecture landscape.", tenantLabel, "architecture");
        foreach (block; architectureUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5ArchitectureBlockItem(block.id.value, block.title, block.description, block.owner,
                block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5ArchitectureBlockDetailModel architectureDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Architecture Block Detail", "Detailed architecture block view.", tenantLabel, "architecture");
        auto block = architectureUseCase.getBlock(tenantId, ArchitectureBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5ArchitectureBlockItem(block.id.value, block.title, block.description, block.owner,
            block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        return detail;
    }

    UsecaseResult createArchitecture(TenantId tenantId, Json data) {
        auto req = CreateArchitectureBlockRequest();
        req.tenantId = tenantId;
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return architectureUseCase.createBlock(req);
    }

    UsecaseResult updateArchitecture(TenantId tenantId, string id, Json data) {
        auto req = UpdateArchitectureBlockRequest();
        req.tenantId = tenantId;
        req.blockId = ArchitectureBlockId(id);
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return architectureUseCase.updateBlock(req);
    }

    UsecaseResult deleteArchitecture(TenantId tenantId, string id) {
        return architectureUseCase.deleteBlock(tenantId, ArchitectureBlockId(id));
    }

    private Ui5ArchitectureBlockPageModel basePage(string title, string subtitle, string tenantLabel, string blockType) {
        Ui5ArchitectureBlockPageModel page;
        page.title = title;
        page.subtitle = subtitle;
        page.tenantId = tenantLabel;
        page.blockType = blockType;
        return page;
    }

    private Ui5ArchitectureBlockDetailModel baseDetail(string title, string subtitle, string tenantLabel, string blockType) {
        Ui5ArchitectureBlockDetailModel detail;
        detail.title = title;
        detail.subtitle = subtitle;
        detail.tenantId = tenantLabel;
        detail.blockType = blockType;
        detail.found = false;
        return detail;
    }

    private string formatTags(string[] tags) {
        if (tags.length == 0)
            return "-";
        return tags.join(", ");
    }

    private string[] parseTags(string value) {
        string[] tags;
        if (value.length == 0)
            return tags;

        foreach (raw; value.split(",")) {
            auto t = raw.strip;
            if (t.length > 0)
                tags ~= t;
        }
        return tags;
    }
}
