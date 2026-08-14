module uim.platform.architecture.presentation.ui5.models.building_blocks;

import std.array : join;
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
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
                block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockPageModel solutionPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Solution Building Blocks", "Concrete solution implementations and mappings.", tenantLabel, "solution");
        foreach (block; solutionUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
                block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockPageModel dataPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Data Building Blocks", "Data ownership, quality and classification units.", tenantLabel, "data");
        foreach (block; dataUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
                block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockPageModel businessPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Business Building Blocks", "Business capabilities and process-aligned assets.", tenantLabel, "business");
        foreach (block; businessUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
                block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        }
        return page;
    }

    Ui5BuildingBlockPageModel technologyPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Technology Building Blocks", "Infrastructure and technology foundation elements.", tenantLabel, "technology");
        foreach (block; technologyUseCase.listBlocks(tenantId)) {
            page.items ~= Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
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
        detail.item = Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
            block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        return detail;
    }

    Ui5BuildingBlockDetailModel solutionDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Solution Block Detail", "Detailed solution block view.", tenantLabel, "solution");
        auto block = solutionUseCase.getBlock(tenantId, SolutionBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
            block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        return detail;
    }

    Ui5BuildingBlockDetailModel dataDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Data Block Detail", "Detailed data block view.", tenantLabel, "data");
        auto block = dataUseCase.getBlock(tenantId, DataBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
            block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        return detail;
    }

    Ui5BuildingBlockDetailModel businessDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Business Block Detail", "Detailed business block view.", tenantLabel, "business");
        auto block = businessUseCase.getBlock(tenantId, BusinessBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
            block.status.toString, block.lifecycleState, block.versionLabel, formatTags(block.tags));
        return detail;
    }

    Ui5BuildingBlockDetailModel technologyDetail(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Technology Block Detail", "Detailed technology block view.", tenantLabel, "technology");
        auto block = technologyUseCase.getBlock(tenantId, TechnologyBlockId(id));
        if (block.id.value.length == 0)
            return detail;
        detail.found = true;
        detail.item = Ui5BuildingBlockItem(block.id.value, block.name, block.description, block.owner,
            block.status.toString, "-", block.versionLabel, formatTags(block.tags));
        return detail;
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
}
