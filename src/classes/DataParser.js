
import {basicEntIDs} from "../entity_ids/basic_entity_ids.js";

import {LRUCache} from "../classes/LRUCache.js";
import {Parser} from "./Parser.js";

const entitySyntaxTreeCache = new LRUCache(200);



export class DataParser {

  static parseEntity(
    entType, defStr, len, creatorID, isEditable, readerWhitelistID
  ) {
    switch (entType) {
      case "r":
        return this.parseRegularEntity(
          defStr, len, creatorID, isEditable, readerWhitelistID
        );
      case "f":
        return this.parseFunctionEntity(
          defStr, len, creatorID, isEditable, readerWhitelistID
        );
      case "h":
        return this.parseHTMLEntity(
          defStr, len, creatorID, isEditable, readerWhitelistID
        );
      // TODO: Continue.
      default:
        throw "DataParser.parseEntity(): Unrecognized entType.";
    }
  }

  static parseRegularEntity(
    defStr, len, creatorID, isEditable, readerWhitelistID
  ) {

  }

  static parseFunctionEntity(
    defStr, len, creatorID, isEditable, readerWhitelistID
  ) {
    
  }

  static parseHTMLEntity(
    defStr, len, creatorID, isEditable, readerWhitelistID
  ) {
    
  }


}


const specialCharPattern =
  /=>|[,;:"'\/\\+\-\.\*\?\|&@\(\)\[\]\{\}=<>]/;
const nonSpecialCharsPattern = new RegExp (
  "[^" + specialCharPattern.source.substring(1) + "+"
);







const rfEntLexemePatternArr = [
  /"([^"\\]|\\[.\n])*"/,
  /\-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][\-+]?(0|[1-9][0-9]*))?/,
  /[,:\[\]\{\}]/,
  "/true|false|null/",
];





const jsonGrammar = {
  "json-object": {
    rules: [
      ["object"],
      ["array"],
    ],
    process: becomeChild,
  },
  "literal-list": {
    rules: [
      ["literal", "/,/", "literal-list"],
      ["literal"],
    ],
    process: straightenListSyntaxTree,
  },
  "literal": {
    rules: [
      ["string"],
      ["number"],
      ["array"],
      ["object"],
      ["/true|false|null/"],
    ],
    process: becomeChild,
  },
  "string": {
    rules: [
      [/"([^"\\]|\\[.\n])*"/],
    ],
    process: (syntaxTree) => {
      // Concat all the nested lexemes.
      let stringLiteral = syntaxTree.children[0].lexeme;

      // Test that the resulting string is a valid JSON string. 
      try {
        JSON.parse(stringLiteral);
      } catch (error) {
        return `Invalid JSON string: ${stringLiteral}`;
      }

      syntaxTree.children = stringLiteral;
    },
  },
  "number": {
    rules: [
      [/\-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][\-+]?(0|[1-9][0-9]*))?/],
    ],
    process: makeChildrenIntoLexemeArray,
  },
  "constant": {
    rules: [
      ["/true|false|null/"],
    ],
    process: makeChildrenIntoLexemeArray,
  },
  "array": {
    rules: [
      [/\[/, "literal-list", /\]/],
    ],
    process: (syntaxTree) => becomeChildExceptSym(syntaxTree, 1),
  },
  "object": {
    rules: [
      [/\{/, "member-list", /\}/],
    ],
    process: (syntaxTree) => becomeChildExceptSym(syntaxTree, 1),
  },
  "member-list": {
    rules: [
      ["member", "/,/", "member-list"],
      ["member"],
    ],
    process: straightenListSyntaxTree,
  },
  "member": {
    rules: [
      ["string", "/:/", "literal"],
    ],
  },
  process: (syntaxTree) => {
    syntaxTree.children = {
      name: syntaxTree.children[0],
      val: syntaxTree.children[2],
    }
  }
};

const jsonParser = new Parser(
  jsonGrammar,
  [
    /"([^"\\]|\\[.\n])*"/,
    /\-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][\-+]?(0|[1-9][0-9]*))?/,
    /=>|@[\[\{<]|[,:\[\]\{\}\(\)>\?=]/,
    "/true|false|null/",
  ],
  /\s+/
);



export function straightenListSyntaxTree(syntaxTree, delimiterLexNum = 1) {
  syntaxTree.children = (syntaxTree.ruleInd === 0) ? [
    syntaxTree.children[0],
    ...syntaxTree.children[1 + delimiterLexNum].children,
  ] : [
    children[0]
  ];
}

export function becomeChild(syntaxTree, ind = 0) {
  Object.assign(syntaxTree, {
    ruleInd: null,
    ...syntaxTree.children[ind],
    prevSym: syntaxTree.sym,
  });
}

export function becomeChildExceptSym(syntaxTree, ind = 0) {
  Object.assign(syntaxTree, {
    ruleInd: null,
    ...syntaxTree.children[ind],
    sym: syntaxTree.sym,
  });
}


export function getLexemeArrayFromChildren(syntaxTree) {
  if (syntaxTree.lexeme) {
    return [syntaxTree.lexeme];
  } else {
    return [].concat(...syntaxTree.children.map(child => (
      getLexemeArrayFromChildren(child)
    )));
  }
}

export function makeChildrenIntoLexemeArray(syntaxTree) {
  syntaxTree.children = getLexemeArrayFromChildren(syntaxTree);
}




// We only overwrite some of the nonterminal symbols in the JSON grammar.
const rEntGrammar = {
  ...jsonGrammar,
  "literal": {
    rules: [
      ["ent-ref"],
      ["input-placeholder"],
      ["string"],
      ["number"],
      ["array"],
      ["object"],
      ["/_|true|false|null/"],
    ],
    process: (children, ruleInd) => {

    }
  },
  "string": {
    ...jsonGrammar["string"],
    process: (syntaxTree) => {
      let error = jsonGrammar["string"].process(syntaxTree);
      if (error) {
        return error;
      }

      let subSyntaxTree = rfEntStringParser.parse(stringLiteral);
      if (!subSyntaxTree.isSuccess) {
        return subSyntaxTree.error;
      }

      Object.assign(syntaxTree, subSyntaxTree);
    },
  },
  "ent-ref": {
    rules: [
      [/@\[/, "/0|[1-9][0-9]*/",  /\]/],
      [/@\[/, "path", /\]/],
    ],
    process: (syntaxTree) => {
      Object.assign(syntaxTree, {
        isTBD: (ruleInd === 1),
        entID: (ruleInd === 0) ? syntaxTree.children[1].lexeme : undefined,
        path:  (ruleInd === 1) ? syntaxTree.children[1].lexeme : undefined,
      });
    }
  },
  "input-placeholder": {
    rules: [
      [/@\{/, "/[1-9][0-9]*/",    /\}/],
    ],
  },
  "path": {
    rules: [
      [/[^0-9\[\]@,;"][^\[\]@,;"]*/],
    ],
    process: (syntaxTree) => {
      syntaxTree.num = syntaxTree.children[1].lexeme;
    }
  },
};

export const rEntParser = new Parser(
  rEntGrammar,
  [
    /"([^"\\]|\\[.\n])*"/,
    /\-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][\-+]?(0|[1-9][0-9]*))?/,
    /=>|@[\[\{<]|[,:\[\]\{\}\(\)>\?=]/,
    // "/true|false|null/",
    /[^0-9\[\]@,;"][^\[\]@,;"]*/,
  ],
  /\s+/
);




const rfEntStringGrammar = {
  "string": {
    rules: [
      ['/"/', "string-part*", '/"/']
    ],
    process: (children) => {
      let contentArr = children[0].children;
      children = contentArr;
      return [children];
    },
  },
  "string-part": {
    rules: [
      ["ent-ref"],
      ["input-placeholder"],
      ["chars"],
    ],
  },
  // ...
};


export const rfEntStringParser = new Parser(
  rfEntStringGrammar,
  [
    '/"/',
    /@[\[\{<];?|@/,
    /([^@"\\]|\\[^@]|)+/,
  ],
  false
);




const fEntGrammar = {
  ...regEntGrammar,
  "function": {
    rules: [
      [
        "function-name", /\(/, "param-list", /\)/, "/=>/",  /\{/,
        "member-list", /\}/,
      ],
    ],
  },
  "param-list": {
    rules: [
      ["param", "/,/", "param-list"],
      ["param"],
    ],
    process: straightenListSyntaxTree,
  },
  "param": {
    rules: [
      ["string", "/\\?/?", "/:/", "type", "default-val-def?"],
    ],
  },
  "default-val-def": {
    rules: [
      ["/=/", "literal"],
    ],
  },
  "type": {
    rules: [
      ["type^(1)", "/\\?/"],
      ["type^(1)", "/=/", "literal"],
      ["type^(1)"],
    ],
  },
  "type^(1)": {
    rules: [
      [/\(/, "type-disjunction-list", /\)/],
      ["type^(2)"],
    ],
  },
  "type-disjunction-list": {
    rules: [
      ["string", "/:/", "type^(2)", /\|/, "type-disjunction-list"],
      ["string", "/:/", "type^(2)"],
    ],
  },
  "type^(2)": {
    rules: [
      [/\[/, "type^(3)-list", /\]/, "array-type-operator"],
      [/\[/, "type^(3)-list", /\]/],
      ["type^(3)"],
    ],
  },
  "array-type-operator": {
    rules: [
      [/\[/, "/[1-9][0-9]*/", /\]/],
      [/\[/, /\]/],
    ],
  },
  "type^(3)-list": {
    rules: [
      ["type^(3)", "/,/", "type^(3)-list"],
      ["type^(3)"],
    ],
    process: straightenListSyntaxTree,
  },
  "type^(3)": {
    rules: [
      ["ent-ref"], // A class.
      [/[tuafrjh8d]|string|bool|int|float/],
      [/array|object/], // User has to manually type in a parsable JS array/
      // object.
    ],
  },
};







const regularEntityParser = new Parser(
  regEntGrammar, "literal-list", funAndRegEntLexemePatternArr, false
);




















const doubleQuoteStringPattern =
  /"([^"\\]|\\[\s\S])*"/;
const xmlSpecialCharPattern =
  /[<>"'\\\/&;]/;

const xmlWSPattern = /\s+/;
const xmlLexemePatternArr = [
  doubleQuoteStringPattern,
  xmlSpecialCharPattern,
  nonSpecialCharsPattern,

];

const xmlGrammar = {
  "xml-text": {
    rules: [
      ["text-or-element*"],
    ],
    process: (children, ruleInd) => {
      let contentArr = children[0].children;
      children = contentArr;
      return [children];
    },
  },
  "text-or-element": {
    rules: [
      ["element"],
      [/[^&'"<>]+/],
      ["/&/", /[#\w]+/, "/;/"],
    ],
  },
  "element": {
    rules: [
      [
        "/</", /[_a-zA-Z][_a-zA-Z0-9\-\.]*/, "attr-member*", "/>/",
        "xml-text",
        "/</", /\//, "element-name", "/>/"
      ],
      [
        "/</", /[_a-zA-Z][_a-zA-Z0-9\-\.]*/, "attr-member*", /\//, "/>/",
      ]
    ],
    process: (children, ruleInd) => {
      let startTagName = children[1].lexeme;
      if (/^[xX][mM][lL]/.test(startTagName)) {
        return [null, "Element name cannot start with 'xml'"]
      }

      if (ruleInd === 0) {
        let endTagName = syntaxTree.children[7].lexeme;
        if (endTagName !== startTagName) {
          return [null,
            "End tag </" + endTagName + "> does not match start tag <" +
            startTagName + ">"
          ];
        }
      }

      children = {
        name: startTagName,
        attrMembers: syntaxTree.children[2].children,
        content: (ruleInd === 0) ? syntaxTree.children[4] : undefined,
        isSelfClosing: (ruleInd === 1),
      };
      return [children];
    },
  },
  "element-name": {
    rules: [
      [/[_a-zA-Z]+/, "/[_a-zA-Z0-9\\-\\.]+/*"],
    ],
    // (One could include a test() here to make sure it doesn't start with
    // /[xX][mM][lL]/.)
  },
  "attr-member": {
    rules: [
      ["attr-name", "/=/", "string"],
      ["attr-name", "/=/", "number"],
      ["attr-name", "/=/", "/true|false/"],
      ["attr-name"],
    ],
  },
  "attr-name": {
    rules: [
      // NOTE: This might very well be wrong. TODO: Correct.
      [/[_a-sA-Z]+/, "/[_a-sA-Z0-9\\-\\.]+/*"],
    ],
  },
  "string": {
    rules: [
      [doubleQuoteStringPattern],
    ],
    process: (children) => {
      // Test that the string is a valid JSON string.
      let stringLiteral = children[0].lexeme;
      try {
        JSON.parse(stringLiteral);
      } catch (error) {
        return [false, `Invalid JSON string: ${stringLiteral}`];
      }
      return [];
    },
  },
  "number": {
    rules: [
      [/\-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][\-+]?(0|[1-9][0-9]*))?/],
    ],
  },
}

export const xmlParser = new Parser(
  xmlGrammar, "xml-text", xmlLexemePatternArr, xmlWSPattern
);

// Tests:
xmlParser.log(xmlParser.parseAndProcess(
  `Hello, world!`
));
xmlParser.log(xmlParser.parseAndProcess(
  `Hello, <i>world</i>.`
));
xmlParser.log(xmlParser.parseAndProcess(
  `Hello, <i>world</wrong>.`
));
