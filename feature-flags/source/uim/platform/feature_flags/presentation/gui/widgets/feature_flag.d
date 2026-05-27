/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.presentation.gui.widgets.feature_flag;

import uim.platform.feature_flags;
import std.stdio : writeln, writefln;

mixin(ShowModule!());

@safe:

/// MVC GUI Widget controller — provides a structured view model for desktop/terminal-UI
/// rendering (e.g. a TUI dashboard or future GTK/wxD binding).
/// Returns a ViewModel struct that a renderer can draw without knowing domain types.
struct FlagRowViewModel {
    string id;
    string name;
    string type_;
    string state_;
    string defaultVariant;
    string instanceId;
    long updatedAt;
}

struct FlagDetailViewModel {
    string id;
    string name;
    string description;
    string type_;
    string state_;
    string instanceId;
    string defaultVariant;
    long createdAt;
    long updatedAt;
    string createdBy;
    string updatedBy;
    VariantViewModel[]      variants;
    TargetingRuleViewModel[] rules;
}

struct VariantViewModel {
    string key;
    string name;
    string value;
    uint   weight;
}

struct TargetingRuleViewModel {
    uint   priority;
    string type_;
    string variantKey;
}

/// Widget that builds view-models for GUI rendering.
class FeatureFlagWidget {
    private ManageFeatureFlagsUseCase useCase;

    this(ManageFeatureFlagsUseCase useCase) {
        this.useCase = useCase;
    }

    FlagRowViewModel[] buildListViewModel(string tenantId, string instanceId = "") @safe {
        FeatureFlag[] flags;
        if (instanceId.length > 0)
            flags = useCase.listFlagsByInstance(tenantId, ServiceInstanceId(instanceId));
        else
            flags = useCase.listFlags(tenantId);

        FlagRowViewModel[] rows;
        foreach (f; flags) {
            FlagRowViewModel row;
            row.id             = f.id.value;
            row.name           = f.name;
            row.type_          = cast(string) f.type_;
            row.state_         = cast(string) f.state_;
            row.defaultVariant = f.defaultVariant;
            row.instanceId     = f.instanceId.value;
            row.updatedAt      = f.updatedAt;
            rows ~= row;
        }
        return rows;
    }

    FlagDetailViewModel buildDetailViewModel(string tenantId, string id) @safe {
        auto f = useCase.getFlag(tenantId, FlagId(id));
        FlagDetailViewModel vm;
        if (f.isNull) return vm;

        vm.id             = f.id.value;
        vm.name           = f.name;
        vm.description    = f.description;
        vm.type_          = cast(string) f.type_;
        vm.state_         = cast(string) f.state_;
        vm.instanceId     = f.instanceId.value;
        vm.defaultVariant = f.defaultVariant;
        vm.createdAt      = f.createdAt;
        vm.updatedAt      = f.updatedAt;
        vm.createdBy      = f.createdBy;
        vm.updatedBy      = f.updatedBy;

        foreach (v; f.variants)
            vm.variants ~= VariantViewModel(v.key, v.name, v.value, v.weight);
        foreach (r; f.rules)
            vm.rules ~= TargetingRuleViewModel(r.priority, cast(string) r.type_, r.variantKey);

        return vm;
    }
}
