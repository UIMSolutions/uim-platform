/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.presentation.cli.commands;

import uim.platform.abap_compiler;
import std.stdio : writeln, writefln, readln;
import std.string : strip;

mixin(ShowModule!());
@safe:

/// Command-line interface commands for the ABAP Compiler.
/// Provides a simple REPL-style interface usable via `--cli` flag.
///
/// Supported commands:
///   compile <file>     — tokenise, parse, analyse and generate IR for a local .abap file
///   check   <file>     — run only lexer + parser + semantic analysis (no code gen)
///   help               — show available commands
///   exit | quit        — terminate CLI
struct AbapCliRunner {
    private CompileUseCase  compileUseCase;
    private string          tenantId;

    this(CompileUseCase uc, string tid) {
        compileUseCase = uc;
        tenantId       = tid;
    }

    void run() @trusted {
        writeln("=============================================================");
        writeln("  UIM ABAP Compiler CLI — Release 7.51 compatible");
        writeln("  Type 'help' for available commands, 'exit' to quit.");
        writeln("=============================================================");

        while (true) {
            import std.stdio : write;
            write("abap> ");
            auto line = readln().strip;
            if (line.length == 0) continue;

            auto parts = line.split(" ");
            auto cmd   = parts[0];

            switch (cmd) {
                case "help":
                    writeln("  compile <file>   Compile an ABAP source file");
                    writeln("  check   <file>   Check syntax without code generation");
                    writeln("  exit             Quit");
                    break;

                case "compile":
                    if (parts.length < 2) { writeln("Usage: compile <file>"); break; }
                    handleCompile(parts[1], false);
                    break;

                case "check":
                    if (parts.length < 2) { writeln("Usage: check <file>"); break; }
                    handleCompile(parts[1], true);
                    break;

                case "exit": case "quit":
                    writeln("Goodbye.");
                    return;

                default:
                    writefln("Unknown command: %s", cmd);
                    break;
            }
        }
    }

    private void handleCompile(string filePath, bool checkOnly) @trusted {
        import std.file : readText, exists;
        if (!exists(filePath)) { writefln("File not found: %s", filePath); return; }

        string src = readText(filePath);

        // Use the domain services directly for CLI (no HTTP overhead)
        AbapLexer        lexer;
        AbapParser       parser;
        SemanticAnalyser analyser;
        CodeGenerator    codeGen;

        auto tokens = lexer.tokenise(src);
        writefln("  Tokens: %d", tokens.length);

        auto parsed = parser.parse(tokens);
        writefln("  Statements: %d", parsed.statements.length);

        auto diags = analyser.analyse(parsed.statements);
        foreach (d; diags)
            writefln("  [%s] line %d: %s (%s)",
                d.severity.to!string, d.line, d.message, d.code);

        if (!checkOnly) {
            auto ir = codeGen.generate(parsed.statements);
            writefln("  Generated IR (%d lines):", ir.length);
            foreach (l; ir) writeln("    ", l);
        }

        bool ok = true;
        foreach (d; diags)
            if (d.severity == DiagnosticSeverity.error) { ok = false; break; }

        writeln(ok ? "  => OK" : "  => FAILED");
    }
}
