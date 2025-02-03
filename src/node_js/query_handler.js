
import * as mysql from 'mysql';
import {InputGetter} from './user_input/InputGetter';
import {Error, endWithError} from './err/errors';
import {InputValidator} from './user_input/InputValidator';


export async function query_handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");

  // Get user ID and session ID at first if provided.
  let [reqType, userID, sesIDHex] = await InputGetter.getParamsPromise(
    req, ["req", "u", "ses"], [undefined, "0", ""]
  );

  // Authenticate user if non-zero user ID is provided.
  if (userID !== "0") {
    // TODO: Consider removing input validation here.
    InputValidator.validateParams(
      [userID, sesIDHex], ["id", "session_id_hex"], ["u", "ses"]
    );
    // TODO: Call an authenticator method here.
  }


  // Branch and get SQL statement and input specifications.
  let sql, paramNameArr, typeArr, defaultValArr;
  switch (reqType) {
    /* Scores */
    case "entList":
      res.setHeader("Cache-Control", "max-age=3"); // TODO: Change/adjust.
      sql = "CALL selectEntityList (?, ?, ?, ?, ?, ?, ?)";
      paramNameArr = [
          "u", "d", "w",
          "hi", "lo",
          "n", "o",
          "a",
          "f", "d"
      ];
      typeArr = [
          "id", "id", "id",
          "float", "float",
          "uint", "uint",
          "bool",
          "bool", "bool"
      ];
      defaultValArr = []; // TODO: Add default values.
      // output: [
      //   [[tagName | null, outID, exitCode]], ...
      //   [( [score1, subjID] | [score1, score2, subjID] ), ...]
      // ].
      break;
    case "score":
      header("Cache-Control: max-age=3"); // TODO: Change/adjust.
      sql = "CALL selectPublicScore (?, ?, ?)";
      paramNameArr = ["u", "d", "w", "s"];
      typeArr = ["id", "id", "id", "id"];
      defaultValArr = []; // TODO: Add default values.
      // output: [
      //   [[tagName | null, outID, exitCode]], ...
      //   [[score1, score2, otherDataHex]]
      // ].
      break;
    /* Entities */
    case "ent":
      sql = "CALL selectEntity (?, ?, ?, ?)";
      paramNameArr = ["u", "e", "m", "s"];
      typeArr = ["id", "id", "uint", "uint"];
      defaultValArr = []; // TODO: Add default values.
      // output: [[
      //  [entType, defStr, len, creatorID, isEditable, readerWhitelistID] |
      //  [null, exitCode]
      // ]].
      break;
    case "entRec":
      sql = "CALL selectEntityRecursively (?, ?, ?, ?, ?)";
      paramNameArr = ["u", "id", "m", "i", "l"];
      typeArr = ["id", "id", "uint", "rec_instr_list", "utint"];
      defaultValArr = []; // TODO: Add default values.
      // output: [[
      //  [entID, entType, defStr, len, creatorID, isEditable,
      //    readerWhitelistID
      //  ] |
      //  [entID, null, exitCode]
      // ], ...].
      break;
    case "entID":
      sql = "CALL selectEntityIDFromSecKey (?, ?, ?, ?)";
      paramNameArr = ["u", "t", "w", "d"];
      typeArr = ["id", "char", "id", "str"];
      defaultValArr = []; // TODO: Add default values.
      // output: [[[entID | null]]].
      break;
    case "regEnt":
      sql = "CALL parseAndObtainRegularEntity (?, ?, ?, ?)";
      paramNameArr = ["u", "w", "d"];
      typeArr = ["id", "id", "str"];
      defaultValArr = []; // TODO: Add default values.
      // output: [
      //   [[(tagName | null), outID, exitCode]], ...
      // ].
      break;
    // case "entFromSK":
    //     sql = "CALL selectEntityFromSecKey (?, ?, ?, ?)";
    //     paramNameArr = ["u", "t", "w", "d"];
    //     typeArr = ["id", "char", "id", "str"];
    //     // output: [[entID, creatorID, editableUntil]].
    //     break;
    /* User data */
    // case "user":
    //     sql = "CALL selectUserInfo (?)";
    //     paramNameArr = ["id"];
    //     typeArr = ["id"];
    //     // output: [[username, publicKeys]].
    //     break;
    default:
        throw new Error("Unrecognized request type");
  }


  res.writeHead(200, {'Content-Type': 'text/json'});
  res.end(JSON.stringify('Hello World!'));
}