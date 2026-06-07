/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.application.usecases.compile;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Primary application use case: compile an ABAP program source.
///
/// Pipeline (follows the ABAP compiler pipeline described in the ABAP documentation):
///   1. Lexical analysis   — tokenise source (AbapLexer)
///   2. Syntax analysis    — parse statements (AbapParser)
///   3. Semantic analysis  — validate structure (SemanticAnalyser)
///   4. Code generation    — emit IR (CodeGenerator)
class CompileUseCase {
    private AbapProgramRepository     programRepo;
    private CompilationJobRepository  jobRepo;

    private AbapLexer         lexer;
    private AbapParser        parser;
    private SemanticAnalyser  analyser;
    private CodeGenerator     codeGen;

    this(AbapProgramRepository programRepo, CompilationJobRepository jobRepo) {
        this.programRepo = programRepo;
        this.jobRepo     = jobRepo;
        this.lexer       = AbapLexer();
        this.parser      = AbapParser();
        this.analyser    = SemanticAnalyser();
        this.codeGen     = CodeGenerator();
    }

    CompileResponse compile(CompileRequest req) {
        import core.time : MonoTime;

        // Resolve source code
        string source = req.sourceCode;
        if (source.length == 0) {
            auto prog = programRepo.findById(req.tenantId, req.programId);
            if (prog.isNull)
                return CompileResponse(
                    CompilationJobId(""), CompilationStatus.failed, [], [], false,
                    "Program '" ~ req.programId.value ~ "' not found"
                );
            source = prog.sourceCode;
        }

        // Create job record
        auto job = CompilationJob.create(req.tenantId, req.programId);
        job.status = CompilationStatus.running;
        jobRepo.save(job);

        // --- Stage 1: Lex
        Token[] tokens = lexer.tokenise(source);

        // --- Stage 2: Parse
        ParseResult parsed = parser.parse(tokens);

        // --- Stage 3: Semantic analysis
        Diagnostic[] semanticDiags = analyser.analyse(parsed.statements);

        // Merge all diagnostics
        Diagnostic[] allDiags = parsed.diagnostics ~ semanticDiags;

        string[] irCode;
        CompilationStatus finalStatus;

        bool anyErrors = false;
        foreach (d; allDiags)
            if (d.severity == DiagnosticSeverity.error) { anyErrors = true; break; }

        if (anyErrors) {
            finalStatus = CompilationStatus.failed;
        } else {
            // --- Stage 4: Code generation
            irCode      = codeGen.generate(parsed.statements);
            finalStatus = CompilationStatus.succeeded;
        }

        // Persist result
        job.status        = finalStatus;
        job.diagnostics   = allDiags;
        job.generatedCode = irCode;
        job.finishedAt    = MonoTime.currTime.ticks;
        jobRepo.update(job);

        return CompileResponse(
            job.id, finalStatus, allDiags, irCode,
            finalStatus == CompilationStatus.succeeded,
            anyErrors ? "Compilation failed with errors" : ""
        );
    }
}
