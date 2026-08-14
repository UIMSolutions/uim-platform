module uim.platform.architecture.presentation.ui5.models.overview;

import std.array : join;
import std.string : split, strip;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct Ui5OverviewkItem {
    string id;
    string name;
    string description;
    string owner;
    string status;
    string lifecycle;
    string versionLabel;
    string tags;
}

struct Ui5OverviewkPageModel {
    string title;
    string subtitle;
    string tenantId;
    string blockType;
    Ui5OverviewkItem[] items;
}

struct Ui5OverviewkDetailModel {
    string title;
    string subtitle;
    string tenantId;
    string blockType;
    bool found;
    Ui5OverviewkItem item;
}

class OverviewUi5Model {
    this() {}
}
