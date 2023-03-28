

import lex from "./lex.js";

export function parseModuleScript(script) {
    // get lexeme array.
    // TODO: implement exception handling here.
    var lexArr = lex(script);
    // initialize position object.
    var nextPos = [0];

    // if first lexeme is '"use strict"', continue, or else return false.
    if (lexArr[0] == '"use strict"' && lexArr[1] == ';') {
        nextPos[0] = 2;
    } else {
        return false;
    }
    // (Even though strict mode is automatic for all modules, let us still
    // include it just in case we allow other script types in the future, and
    // also just in case sloppy mode can somehow make the scripts unsafe when
    // not loaded as module scripts like they are supposed to.)

    // parse a list of import statements.
    while (parseImportStmt(lexArr, nextPos, false));

    // parse a list of function definitions or pure variable definitions. (We
    // only allow these two types of definitions at this point.)
    while (parseDef(lexArr, nextPos, false));

    // return true only if all lexemes have been successfully parsed.
    return (nextPos[0] == lexArr.length);
}


/* Not needed after all, for users should instead define a main procedure
 * in their main module.
 **/
// function parseMainScript(script) {
//     // get lexeme array.
//     // TODO: implement exception handling here.
//     var lexArr = lex(script);
//     // initialize position object and ...
//     var nextPos = {pos:0};
//
//     // if first lexeme is '"use strict"', continue, or else return false.
//     if (lexArr[0] == '"use strict"' && lexArr[1] == ';') {
//         nextPos[0] = 2;
//     } else {
//         return false;
//     }
//
//     // parse a list of import statements.
//     var matchWasFound = true;
//     while (matchWasFound) {
//         matchWasFound = parseImportStmt(lexArr, nextPos);
//     }
//
//     // parse a list of function definitions or pure variable definitions.
//     var matchWasFound = true;
//     while (matchWasFound) {
//         matchWasFound = parseStmt(lexArr, nextPos);
//     }
//
//     // return true only if all lexemes have been successfully parsed.
//     if (nextPos[0] == lexArr.length) {
//         return true;
//     } else {
//         return false;
//     }
// }



// import stmtLst
// from "./stmt.js";
//
//
// import funDefLst
// from "./fun_def.js";
//
// import importLst
// from "./import.js";
//
//
// const s = "\s?";
//
// export const modulePattern =
//     // '"use strict";' +s+ // not necessary; strict mode is default for modules.
//     "/^" +s+
//         importLst +s+
//         "(" +
//             "(" + pureVarAssign +s+ ")" +
//         "|" +
//             "(" + funDefLst +s+ ")" +
//         ")*" +
//     "$/";
//
// export const scriptPattern =
//     "/^" +s+
//         '"use strict";' +s+
//         importLst +s+
//         stmtLst +s+
//     "$/";
// // (I'm purposefully adding redundant +s+'s; rather have too many than too few.)
