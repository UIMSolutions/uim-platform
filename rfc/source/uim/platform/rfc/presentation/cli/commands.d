/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.presentation.cli.commands;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// Interactive CLI runner for the RFC Interface service.
/// Useful for development, testing, and debugging RFC calls without HTTP.
///
/// Usage:
///   uim-rfc-platform-service --cli
///
/// Commands:
///   call  <destination> <function> [srfc|arfc|trfc|qrfc|bgrfc]
///       — invoke a function module on a destination
///   destinations
///       — list all registered RFC destinations
///   functions
///       — list all registered function modules
///   status <call-id>
///       — show status and result of an RFC call
///   add-destination <id> <host> [abapSystem|http|tcpip]
///       — register a new RFC destination
///   help  — show available commands
///   exit  — quit
struct RfcCliRunner {

    void run() @trusted {
        import std.stdio  : writeln, write, stdout, readln;
        import std.string : strip, split, startsWith;
        import std.conv   : to;

        // Build an in-memory container for CLI use
        auto config = SrvConfig.load();
        auto c      = buildContainer(config);
        auto tenantId = "cli";

        writeln("UIM RFC Interface CLI (port: " ~ config.port.to!string ~ ")");
        writeln("Type 'help' for available commands, 'exit' to quit.");
        writeln();

        while (true) {
            write("rfc> ");
            stdout.flush();
            auto line = readln();
            if (line is null) break;
            auto cmd = line.strip();
            if (cmd.length == 0) continue;

            auto parts = cmd.split(" ");
            auto verb  = parts[0];

            switch (verb) {
                case "exit", "quit":
                    writeln("Bye.");
                    return;

                case "help":
                    _printHelp();
                    break;

                case "call":
                    if (parts.length < 3) {
                        writeln("Usage: call <destination> <function> [srfc|arfc|trfc|qrfc|bgrfc]");
                        break;
                    }
                    _doCall(c, tenantId, parts[1], parts[2],
                            parts.length >= 4 ? parts[3] : "srfc");
                    break;

                case "destinations":
                    _listDestinations(c, tenantId);
                    break;

                case "functions":
                    _listFunctions(c, tenantId);
                    break;

                case "status":
                    if (parts.length < 2) { writeln("Usage: status <call-id>"); break; }
                    _showStatus(c, tenantId, parts[1]);
                    break;

                case "add-destination":
                    if (parts.length < 3) {
                        writeln("Usage: add-destination <id> <host> [abapSystem|http|tcpip]");
                        break;
                    }
                    _addDestination(c, tenantId, parts[1], parts[2],
                                    parts.length >= 4 ? parts[3] : "abapSystem");
                    break;

                default:
                    writeln("Unknown command '" ~ verb ~ "'. Type 'help' for available commands.");
            }
        }
    }

private:
    void _printHelp() @trusted {
        import std.stdio : writeln;
        writeln("Available commands:");
        writeln("  call  <destination> <function> [srfc|arfc|trfc|qrfc|bgrfc]");
        writeln("        — invoke a remote function module");
        writeln("  destinations");
        writeln("        — list registered RFC destinations");
        writeln("  functions");
        writeln("        — list registered RFC function modules");
        writeln("  status <call-id>");
        writeln("        — show status and result of an RFC call");
        writeln("  add-destination <id> <host> [abapSystem|http|tcpip]");
        writeln("        — register a new RFC destination");
        writeln("  help  — show this help");
        writeln("  exit  — quit");
    }

    void _doCall(ref Container c, string tenantId, string dest, string fm, string rfcTypeStr) @trusted {
        import std.stdio : writeln;
        import std.conv  : to;

        RfcType rt;
        switch (rfcTypeStr) {
            case "arfc":  rt = RfcType.aRFC;  break;
            case "trfc":  rt = RfcType.tRFC;  break;
            case "qrfc":  rt = RfcType.qRFC;  break;
            case "bgrfc": rt = RfcType.bgRFC; break;
            default:      rt = RfcType.sRFC;  break;
        }

        InvokeRfcRequest req;
        req.tenantId       = tenantId;
        req.destinationId  = dest;
        req.functionModule = fm;
        req.rfcType        = rt;

        writeln("Invoking " ~ rfcTypeStr.toUpper ~ ": " ~ fm ~ " @ " ~ dest ~ " ...");
        auto result = c.invokeRfc.invoke(req);

        if (result.success) {
            writeln("  Status : " ~ result.status.to!string);
            writeln("  Call ID: " ~ result.callId);
            if (result.tid.length > 0) writeln("  TID    : " ~ result.tid);
        } else {
            writeln("  ERROR  : " ~ result.error);
        }
    }

    void _listDestinations(ref Container c, string tenantId) @trusted {
        import std.stdio : writeln;
        auto dests = c.manageDestinations.listDestinations(tenantId);
        if (dests.length == 0) { writeln("  No destinations registered."); return; }
        foreach (d; dests)
            writeln("  [" ~ (d.active ? "ON " : "OFF") ~ "] " ~ d.id ~ "\t" ~ d.host);
    }

    void _listFunctions(ref Container c, string tenantId) @trusted {
        import std.stdio : writeln;
        auto fms = c.manageFunctionModules.listFunctionModules(tenantId);
        if (fms.length == 0) { writeln("  No function modules registered."); return; }
        foreach (f; fms)
            writeln("  " ~ f.id ~ "\t" ~ f.functionGroup ~ "\t" ~ f.shortText);
    }

    void _showStatus(ref Container c, string tenantId, string callId) @trusted {
        import std.stdio : writeln;
        import std.conv  : to;
        auto call = c.manageCalls.getCall(tenantId, callId);
        if (call.isNull()) { writeln("  Call not found: " ~ callId); return; }
        writeln("  ID        : " ~ call.id);
        writeln("  Status    : " ~ call.status.to!string);
        writeln("  RFC Type  : " ~ call.rfcType.to!string);
        writeln("  Destination: " ~ call.destinationId);
        writeln("  Function  : " ~ call.functionModule);
        if (call.tid.length > 0) writeln("  TID       : " ~ call.tid);
        if (call.errorMessage.length > 0) writeln("  Error     : " ~ call.errorMessage);
    }

    void _addDestination(ref Container c, string tenantId, string id, string host, string ctStr) @trusted {
        import std.stdio : writeln;
        ConnectionType ct;
        switch (ctStr) {
            case "http":  ct = ConnectionType.httpConnection; break;
            case "tcpip": ct = ConnectionType.tcpIpConnection; break;
            default:      ct = ConnectionType.abapSystem; break;
        }
        CreateDestinationRequest r;
        r.tenantId       = tenantId;
        r.id             = id;
        r.connectionType = ct;
        r.host           = host;
        r.port           = 3300;

        auto result = c.manageDestinations.createDestination(r);
        if (result.success)
            writeln("  Destination '" ~ id ~ "' registered.");
        else
            writeln("  ERROR: " ~ result.error);
    }
}
