/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.ports.usecases.compile;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Primary application use case: compile an ABAP program source.
///
/// Pipeline (follows the ABAP compiler pipeline described in the ABAP documentation):
///   1. Lexical analysis   — tokenise source (AbapLexer)
///   2. Syntax analysis    — parse statements (AbapParser)
///   3. Semantic analysis  — validate structure (SemanticAnalyser)
///   4. Code generation    — emit IR (CodeGenerator)
interface ICompileUseCase {

    CompileResponse compile(CompileRequest req);

}
