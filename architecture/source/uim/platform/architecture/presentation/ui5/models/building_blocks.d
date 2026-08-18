module uim.platform.architecture.presentation.ui5.models.building_blocks;

import std.array : join;
import std.string : split, strip;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct Ui5BuildingBlockItem {
    string id;
    string name;
    string description;
    string owner;
    string status;
    string lifecycle;
    string versionLabel;
    string tags;
}

struct Ui5BuildingBlockPageModel {
    string title;
    string subtitle;
    string tenantId;
    string blockType;
    Ui5BuildingBlockItem[] items;
}

struct Ui5BuildingBlockDetailModel {
    string title;
    string subtitle;
    string tenantId;
    string blockType;
    bool found;
    Ui5BuildingBlockItem item;
}

class BuildingBlockUi5Model {
    private ManageArchitectureBlocksUseCase architectureUseCase;
    private ManageSolutionBlocksUseCase solutionUseCase;
    private ManageDataBlocksUseCase dataUseCase;
    private ManageBusinessBlocksUseCase businessUseCase;
    private ManageTechnologyBlocksUseCase technologyUseCase;

    this(
        ManageArchitectureBlocksUseCase architectureUseCase,
        ManageSolutionBlocksUseCase solutionUseCase,
        ManageDataBlocksUseCase dataUseCase,
        ManageBusinessBlocksUseCase businessUseCase,
        ManageTechnologyBlocksUseCase technologyUseCase
    ) {
        this.architectureUseCase = architectureUseCase;
        this.solutionUseCase = solutionUseCase;
        this.dataUseCase = dataUseCase;
        this.businessUseCase = businessUseCase;
        this.technologyUseCase = technologyUseCase;
    }

    Ui5BuildingBlockPageModel architecturePage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Architecture Building Blocks", "Capability-focused architecture landscape.", tenantLabel, "architecture");
        foreach (block; architectureUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
                block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockPageModel solutionPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Solution Building Blocks", "Concrete solution implementations and mappings.", tenantLabel, "solution");
        foreach (block; solutionUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
                block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockPageModel dataPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Data Building Blocks", "Data ownership, quality and classification units.", tenantLabel, "data");
        foreach (block; dataUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
                block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockPageModel businessPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Business Building Blocks", "Business capabilities and process-aligned assets.", tenantLabel, "business");
        foreach (block; businessUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
                block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockPageModel technologyPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Technology Building Blocks", "Infrastructure and technology foundation elements.", tenantLabel, "technology");
        foreach (block; technologyUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
                block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockDetailModel architectureDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Architecture Block Detail", "Detailed architecture block view.", tenantLabel, "architecture");
        auto block = architectureUseCase.getBlock(tenantId, ArchitectureBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
            block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        return detail;
    }

    Ui5BuildingBlockDetailModel solutionDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Solution Block Detail", "Detailed solution block view.", tenantLabel, "solution");
        auto block = solutionUseCase.getBlock(tenantId, SolutionBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
            block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        return detail;
    }

    Ui5BuildingBlockDetailModel dataDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Data Block Detail", "Detailed data block view.", tenantLabel, "data");
        auto block = dataUseCase.getBlock(tenantId, DataBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
            block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        return detail;
    }

    Ui5BuildingBlockDetailModel businessDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Business Block Detail", "Detailed business block view.", tenantLabel, "business");
        auto block = businessUseCase.getBlock(tenantId, BusinessBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
            block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        return detail;
    }

    Ui5BuildingBlockDetailModel technologyDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Technology Block Detail", "Detailed technology block view.", tenantLabel, "technology");
        auto block = technologyUseCase.getBlock(tenantId, TechnologyBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.title, block.description, block.owner,
            block.status.toString, "-", block.versionLabel, formatTags(block.tags));
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

    UsecaseResult createSolution(TenantId tenantId, Json data) {
        auto req = CreateSolutionBlockRequest();
        req.tenantId = tenantId;
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return solutionUseCase.createBlock(req);
    }

    UsecaseResult createData(TenantId tenantId, Json data) {
        auto req = CreateDataBlockRequest();
        req.tenantId = tenantId;
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return dataUseCase.createBlock(req);
    }

    UsecaseResult createBusiness(TenantId tenantId, Json data) {
        auto req = CreateBusinessBlockRequest();
        req.tenantId = tenantId;
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return businessUseCase.createBlock(req);
    }

    UsecaseResult createTechnology(TenantId tenantId, Json data) {
        auto req = CreateTechnologyBlockRequest();
        req.tenantId = tenantId;
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return technologyUseCase.createBlock(req);
    }

    UsecaseResult updateArchitecture(TenantId tenantId, string id, Json data) {
        auto req = UpdateArchitectureBlockRequest();
        req.tenantId = tenantId;
        req.blockId = ArchitectureBlockId(id);
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return architectureUseCase.updateBlock(req);
    }

    UsecaseResult updateSolution(TenantId tenantId, string id, Json data) {
        auto req = UpdateSolutionBlockRequest();
        req.tenantId = tenantId;
        req.blockId = SolutionBlockId(id);
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return solutionUseCase.updateBlock(req);
    }

    UsecaseResult updateData(TenantId tenantId, string id, Json data) {
        auto req = UpdateDataBlockRequest();
        req.tenantId = tenantId;
        req.blockId = DataBlockId(id);
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return dataUseCase.updateBlock(req);
    }

    UsecaseResult updateBusiness(TenantId tenantId, string id, Json data) {
        auto req = UpdateBusinessBlockRequest();
        req.tenantId = tenantId;
        req.blockId = BusinessBlockId(id);
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return businessUseCase.updateBlock(req);
    }

    UsecaseResult updateTechnology(TenantId tenantId, string id, Json data) {
        auto req = UpdateTechnologyBlockRequest();
        req.tenantId = tenantId;
        req.blockId = TechnologyBlockId(id);
        req.title = data.getString("title", "");
        req.description = data.getString("description", "");
        req.owner = data.getString("owner", "");
        req.lifecycleState = data.getString("lifecycleState", "");
        req.status = data.getString("status", "");
        req.versionLabel = data.getString("versionLabel", "");
        req.tags = parseTags(data.getString("tags", ""));
        return technologyUseCase.updateBlock(req);
    }

    UsecaseResult deleteArchitecture(TenantId tenantId, string id) {
        return architectureUseCase.deleteBlock(tenantId, ArchitectureBlockId(id));
    }

    UsecaseResult deleteSolution(TenantId tenantId, string id) {
        return solutionUseCase.deleteBlock(tenantId, SolutionBlockId(id));
    }

    UsecaseResult deleteData(TenantId tenantId, string id) {
        return dataUseCase.deleteBlock(tenantId, DataBlockId(id));
    }

    UsecaseResult deleteBusiness(TenantId tenantId, string id) {
        return businessUseCase.deleteBlock(tenantId, BusinessBlockId(id));
    }

    UsecaseResult deleteTechnology(TenantId tenantId, string id) {
        return technologyUseCase.deleteBlock(tenantId, TechnologyBlockId(id));
    }

    private Ui5BuildingBlockPageModel basePage(string title, string subtitle, string tenantLabel, string blockType) {
        Ui5BuildingBlockPageModel page;
        page.title = title;
        page.subtitle = subtitle;
        page.tenantId = tenantLabel;
        page.blockType = blockType;
        return page;
    }

    private Ui5BuildingBlockDetailModel baseDetail(string title, string subtitle, string tenantLabel, string blockType) {
        Ui5BuildingBlockDetailModel detail;
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
