module uim.platform.architecture.presentation.web.models.building_blocks;

import std.array : join;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct WebBuildingBlockItem {
    string id;
    string name;
    string description;
    string owner;
    string status;
    string lifecycle;
    string versionLabel;
    string tags;
}

struct WebBuildingBlockPageModel {
    string title;
    string subtitle;
    string tenantId;
    string blockType;
    WebBuildingBlockItem[] items;
}

struct WebBuildingBlockDetailModel {
    string title;
    string subtitle;
    string tenantId;
    string blockType;
    bool found;
    WebBuildingBlockItem item;
}

class BuildingBlockWebModel {
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

    WebBuildingBlockPageModel architecturePage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Architecture Building Blocks", "Capability-focused architecture landscape.", tenantLabel, "architecture");
        foreach (block; architectureUseCase.listBlocks(tenantId)) {
            page.items ~= WebBuildingBlockItem(
                block.id.value,
                block.name,
                block.description,
                block.owner,
                block.status.toString,
                block.lifecycleState,
                block.versionLabel,
                formatTags(block.tags)
            );
        }
        return page;
    }

    WebBuildingBlockPageModel solutionPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Solution Building Blocks", "Concrete solution implementations and mappings.", tenantLabel, "solution");
        foreach (block; solutionUseCase.listBlocks(tenantId)) {
            page.items ~= WebBuildingBlockItem(
                block.id.value,
                block.name,
                block.description,
                block.owner,
                block.status.toString,
                "-",
                block.versionLabel,
                formatTags(block.tags)
            );
        }
        return page;
    }

    WebBuildingBlockPageModel dataPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Data Building Blocks", "Data ownership, quality and classification units.", tenantLabel, "data");
        foreach (block; dataUseCase.listBlocks(tenantId)) {
            page.items ~= WebBuildingBlockItem(
                block.id.value,
                block.name,
                block.description,
                block.owner,
                block.status.toString,
                "-",
                block.versionLabel,
                formatTags(block.tags)
            );
        }
        return page;
    }

    WebBuildingBlockPageModel businessPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Business Building Blocks", "Business capabilities and process-aligned assets.", tenantLabel, "business");
        foreach (block; businessUseCase.listBlocks(tenantId)) {
            page.items ~= WebBuildingBlockItem(
                block.id.value,
                block.name,
                block.description,
                block.owner,
                block.status.toString,
                block.lifecycleState,
                block.versionLabel,
                formatTags(block.tags)
            );
        }
        return page;
    }

    WebBuildingBlockPageModel technologyPage(TenantId tenantId, string tenantLabel) {
        auto page = basePage("Technology Building Blocks", "Infrastructure and technology foundation elements.", tenantLabel, "technology");
        foreach (block; technologyUseCase.listBlocks(tenantId)) {
            page.items ~= WebBuildingBlockItem(
                block.id.value,
                block.name,
                block.description,
                block.owner,
                block.status.toString,
                "-",
                block.versionLabel,
                formatTags(block.tags)
            );
        }
        return page;
    }

    WebBuildingBlockDetailModel architectureDetails(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Architecture Building Block Details", "Capability-focused architecture block detail.", tenantLabel, "architecture");
        auto block = architectureUseCase.getBlock(tenantId, ArchitectureBlockId(id));
        if (block.id.value.length == 0)
            return detail;

        detail.found = true;
        detail.item = WebBuildingBlockItem(
            block.id.value,
            block.name,
            block.description,
            block.owner,
            block.status.toString,
            block.lifecycleState,
            block.versionLabel,
            formatTags(block.tags)
        );
        return detail;
    }

    WebBuildingBlockDetailModel solutionDetails(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Solution Building Block Details", "Solution implementation block detail.", tenantLabel, "solution");
        auto block = solutionUseCase.getBlock(tenantId, SolutionBlockId(id));
        if (block.id.value.length == 0)
            return detail;

        detail.found = true;
        detail.item = WebBuildingBlockItem(
            block.id.value,
            block.name,
            block.description,
            block.owner,
            block.status.toString,
            "-",
            block.versionLabel,
            formatTags(block.tags)
        );
        return detail;
    }

    WebBuildingBlockDetailModel dataDetails(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Data Building Block Details", "Data classification block detail.", tenantLabel, "data");
        auto block = dataUseCase.getBlock(tenantId, DataBlockId(id));
        if (block.id.value.length == 0)
            return detail;

        detail.found = true;
        detail.item = WebBuildingBlockItem(
            block.id.value,
            block.name,
            block.description,
            block.owner,
            block.status.toString,
            "-",
            block.versionLabel,
            formatTags(block.tags)
        );
        return detail;
    }

    WebBuildingBlockDetailModel businessDetails(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Business Building Block Details", "Business capability block detail.", tenantLabel, "business");
        auto block = businessUseCase.getBlock(tenantId, BusinessBlockId(id));
        if (block.id.value.length == 0)
            return detail;

        detail.found = true;
        detail.item = WebBuildingBlockItem(
            block.id.value,
            block.name,
            block.description,
            block.owner,
            block.status.toString,
            block.lifecycleState,
            block.versionLabel,
            formatTags(block.tags)
        );
        return detail;
    }

    WebBuildingBlockDetailModel technologyDetails(TenantId tenantId, string tenantLabel, string id) {
        auto detail = baseDetail("Technology Building Block Details", "Technology foundation block detail.", tenantLabel, "technology");
        auto block = technologyUseCase.getBlock(tenantId, TechnologyBlockId(id));
        if (block.id.value.length == 0)
            return detail;

        detail.found = true;
        detail.item = WebBuildingBlockItem(
            block.id.value,
            block.name,
            block.description,
            block.owner,
            block.status.toString,
            "-",
            block.versionLabel,
            formatTags(block.tags)
        );
        return detail;
    }

    private WebBuildingBlockPageModel basePage(string title, string subtitle, string tenantLabel, string blockType) {
        WebBuildingBlockPageModel page;
        page.title = title;
        page.subtitle = subtitle;
        page.tenantId = tenantLabel;
        page.blockType = blockType;
        return page;
    }

    private WebBuildingBlockDetailModel baseDetail(string title, string subtitle, string tenantLabel, string blockType) {
        WebBuildingBlockDetailModel detail;
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
