/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.presentation.cli.commands.evaluation;

import uim.platform.feature_flags;
import std.stdio : writeln, writefln;

mixin(ShowModule!());

@safe:

/// CLI command for evaluating feature flags directly from the terminal.
class EvaluationCliCommand {
    private EvaluateFlagsUseCase useCase;

    this(EvaluateFlagsUseCase useCase) {
        this.useCase = useCase;
    }

    /// Evaluate a single flag and print the result.
    void evaluate(string tenantId, string instanceId, string flagName,
                  string userId = "", string[string] attributes = null) @safe {
        EvaluationRequest req;
        req.flagName   = flagName;
        req.instanceId = instanceId;
        req.tenantId   = tenantId;
        req.userId     = userId;
        req.attributes = attributes;

        auto result = useCase.evaluate(req);
        printResult(result);
    }

    /// Evaluate all flags in an instance and print results.
    void evaluateAll(string tenantId, string instanceId,
                     string userId = "", string[string] attributes = null) @safe {
        BulkEvaluationRequest req;
        req.instanceId = instanceId;
        req.tenantId   = tenantId;
        req.userId     = userId;
        req.attributes = attributes;

        auto results = useCase.evaluateAll(req);
        writefln("%-30s %-12s %-20s %s", "FLAG", "VARIANT", "VALUE", "REASON");
        writeln("─".replicate(80));
        foreach (r; results)
            writefln("%-30s %-12s %-20s %s", r.flagName, r.variantKey, r.variantValue, r.reason);
        writefln("\n%d flag(s) evaluated.", results.length);
    }

    private void printResult(EvaluationResult r) @safe {
        writeln("──────────────────────────────────────────");
        writefln("  Flag:    %s", r.flagName);
        writefln("  Enabled: %s", r.enabled);
        writefln("  Variant: %s", r.variantKey);
        writefln("  Value:   %s", r.variantValue);
        writefln("  Type:    %s", cast(string) r.type_);
        writefln("  Reason:  %s", r.reason);
        writeln("──────────────────────────────────────────");
    }
}

private string replicate(string s, size_t n) @safe {
    string result;
    foreach (_; 0 .. n) result ~= s;
    return result;
}
