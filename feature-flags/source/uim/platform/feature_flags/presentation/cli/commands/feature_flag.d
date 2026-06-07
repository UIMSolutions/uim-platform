/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.presentation.cli.commands.feature_flag;

import uim.platform.feature_flags;
import std.stdio : writeln, writefln;

// mixin(ShowModule!());

@safe:

/// MVC Controller for CLI interactions with feature flags.
/// Each method corresponds to a CLI sub-command invoked from main() or a shell wrapper.
class FeatureFlagCliCommand {
    private ManageFeatureFlagsUseCase useCase;

    this(ManageFeatureFlagsUseCase useCase) {
        this.useCase = useCase;
    }

    /// List all flags for a tenant (optionally filtered by instanceId).
    void listFlags(TenantId tenantId, string instanceId = "") @safe {
        FeatureFlag[] flags;
        if (instanceId.length > 0)
            flags = useCase.listFlagsByInstance(tenantId, ServiceInstanceId(instanceId));
        else
            flags = useCase.listFlags(tenantId);

        writefln("%-38s %-30s %-10s %-10s", "ID", "NAME", "TYPE", "STATE");
        writeln("─".replicate(92));
        foreach (f; flags)
            writefln("%-38s %-30s %-10s %-10s", f.id.value, f.name, cast(string) f.type_, cast(string) f.state_);
        writefln("\n%d flag(s) found.", flags.length);
    }

    /// Print a single flag's details.
    void getFlag(TenantId tenantId, string id) @safe {
        auto flag_ = useCase.getFlag(tenantId, FlagId(id));
        if (flag_.isNull) { writeln("Error: Feature flag not found."); return; }
        printFlag(flag_);
    }

    /// Enable a flag.
    void enableFlag(TenantId tenantId, string id, string updatedBy = "") @safe {
        auto req = PatchFeatureFlagRequest("ENABLED", updatedBy);
        auto r   = useCase.patchFlagState(tenantId, FlagId(id), req);
        writeln(r.hasError ? "Error: " ~ r.message : "Flag enabled: " ~ r.id);
    }

    /// Disable a flag.
    void disableFlag(TenantId tenantId, string id, string updatedBy = "") @safe {
        auto req = PatchFeatureFlagRequest("DISABLED", updatedBy);
        auto r   = useCase.patchFlagState(tenantId, FlagId(id), req);
        writeln(r.hasError ? "Error: " ~ r.message : "Flag disabled: " ~ r.id);
    }

    /// Archive a flag.
    void archiveFlag(TenantId tenantId, string id, string updatedBy = "") @safe {
        auto req = PatchFeatureFlagRequest("ARCHIVED", updatedBy);
        auto r   = useCase.patchFlagState(tenantId, FlagId(id), req);
        writeln(r.hasError ? "Error: " ~ r.message : "Flag archived: " ~ r.id);
    }

    /// Delete a flag.
    void deleteFlag(TenantId tenantId, string id, string deletedBy = "") @safe {
        auto r = useCase.deleteFlag(tenantId, FlagId(id), deletedBy);
        writeln(r.hasError ? "Error: " ~ r.message : "Flag deleted: " ~ r.id);
    }

    private void printFlag(FeatureFlag f) @safe {
        writeln("──────────────────────────────────────────");
        writefln("  ID:             %s", f.id.value);
        writefln("  Name:           %s", f.name);
        writefln("  Description:    %s", f.description);
        writefln("  Type:           %s", cast(string) f.type_);
        writefln("  State:          %s", cast(string) f.state_);
        writefln("  Instance:       %s", f.instanceId.value);
        writefln("  Default Variant: %s", f.defaultVariant);
        writefln("  Created:        %s by %s", f.createdAt, f.createdBy);
        writefln("  Updated:        %s by %s", f.updatedAt, f.updatedBy);
        writeln("  Variants:");
        foreach (v; f.variants)
            writefln("    [%s] %s = %s (weight %d)", v.key, v.name, v.value, v.weight);
        writeln("  Targeting Rules:");
        foreach (r; f.rules)
            writefln("    [prio %d] %s -> variant '%s'", r.priority, cast(string) r.type_, r.variantKey);
        writeln("──────────────────────────────────────────");
    }
}

private string replicate(string s, size_t n) @safe {
    string result;
    foreach (_; 0 .. n) result ~= s;
    return result;
}
