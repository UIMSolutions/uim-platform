/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.cli.controllers;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// CLI controller for FlexChange management commands.
/// Usage: uim-ui-flexibility-platform-service changes list [--tenant=T] [--appId=A]
class FlexChangeCliController {
  private ManageFlexChangesUseCase usecase;

  this(ManageFlexChangesUseCase usecase) {
    this.usecase = usecase;
  }

  void execute(string[] args) {
    import std.stdio : writeln;
    if (args.length < 2) { writeln("Usage: changes <list|get|delete> [options]"); return; }

    switch (args[1]) {
      case "list":
        TenantId tenantId = "default";
        foreach (a; args[2 .. $]) {
          if (a.length > 9 && a[0..9] == "--tenant=") tenantId = a[9 .. $];
        }
        auto changes = usecase.listChanges(tenantId);
        writeln("Listing " ~ changes.length.to!string ~ " changes for tenant " ~ tenantId);
        foreach (c; changes) writeln("  " ~ c.id_.value ~ " | " ~ c.appId_);
        break;
      default:
        writeln("Unknown command: " ~ args[1]);
    }
  }
}

/// CLI controller for FlexVariant management commands.
class FlexVariantCliController {
  private ManageFlexVariantsUseCase usecase;

  this(ManageFlexVariantsUseCase usecase) {
    this.usecase = usecase;
  }

  void execute(string[] args) {
    import std.stdio : writeln;
    if (args.length < 2) { writeln("Usage: variants <list|get|delete> [options]"); return; }

    switch (args[1]) {
      case "list":
        TenantId tenantId = "default";
        foreach (a; args[2 .. $]) {
          if (a.length > 9 && a[0..9] == "--tenant=") tenantId = a[9 .. $];
        }
        auto variants = usecase.listVariants(tenantId);
        writeln("Listing " ~ variants.length.to!string ~ " variants for tenant " ~ tenantId);
        foreach (v; variants) writeln("  " ~ v.id_.value ~ " | " ~ v.variantName_);
        break;
      default:
        writeln("Unknown command: " ~ args[1]);
    }
  }
}
