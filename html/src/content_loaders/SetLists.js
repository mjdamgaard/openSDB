
import {
    ContentLoader,
} from "/src/ContentLoader.js";
import {
    sdbInterfaceCL, dbReqManager,
} from "/src/content_loaders/SDBInterfaces.js";




export var setListCL = new ContentLoader(
    "SetList",
    /* Initial HTML template */
    '<div>' +
        '<<List data:wait>>' +
    '</div>',
    sdbInterfaceCL
);
setListCL.addCallback("data", function(data) {
    data.copyFromAncestor([
        "elemContentKey",
        "setGenerator",
        "initialNum",
        "incrementNum",
    ]);
    data.copyFromAncestor("combSet", 1);  // optional.
});
setListCL.addCallback(function($ci, data) {
    data.cl = setListCL.getRelatedCL(data.elemContentKey);
    $ci.one("load-initial-elements", function(event, set) {
        data.listElemDataArr = set.slice(0, data.initialNum).map(val => ({
            ratVal: val[0],
            entID: val[1],
        }));
        data.currentNum = data.initialNum;
        $ci.find('.CI.List').trigger("load");
        return false;
    });
    $ci.on("append-elements", function(event, set) {
        let currNum = data.currentNum;
        let newNum = currNum + data.incrementNum;
        data.listElemDataArr = set.slice(currNum, newNum).map(val => ({
            ratVal: val[0],
            entID: val[1],
        }));
        data.currentNum = newNum;
        setListCL.loadAppended($ci, "List", data);
        return false;
    });
    data.setGenerator.generateSet($ci, function($ci, set) {
        $ci.trigger("load-initial-elements", [set]);
    });
});


/* SetGenerator is just a completely abstract class */
export class SetGenerator {
    constructor() {
        // to be redefined by descendant classes.
    }

    // generateSet() queries and combines sets, then calls
    // callback(obj, set, callbackData).
    generateSet(obj, callbackData, callback) {
        // to be redefined by descendant classes.
    }

    // getSetPredicates() returns an array of all predicate IDs that are
    // important to the formation of the set (which we can then show on the
    // drop-down pages of the set elements).
    getSetPredicates() {
        // to be redefined by descendant classes.
    }

    // getFilterSpecs() returns an array of filter specs (or null), which
    // each consists of a predicate ID, threshold and a flag to denote either
    // the interval below or above the threshold for which all set elements
    // with a rating in that interval should collapse itself automatically (in
    // a future version of this web app).
    getFilterSpecs() {
        // can be redefined by descendant classes.
    }
}

/*
setData = {
    (predTmplID, predStr, | predID,)
    queryUserID,
    inputUserID?, // (This property is only part of a temporary solution.)
    num, ratingLo, ratingHi,
    offset?, isAscending?,
}
*/
export class SetQuerier extends SetGenerator {
    constructor(
        setData,
        set, replaceExistingSet, // optional.
    ) {
        super();
        this.setData = setData;
        setData.offset ??= 0;;
        setData.isAscending ??= 0;;
        this.set = set ?? [];
        this.replaceExistingSet = replaceExistingSet ?? false;
    }

    generateSet(obj, callbackData, callback) {
        if (!callback) {
            callback = callbackData;
            callbackData = undefined;
        }
        let setData = this.setData;
        if (setData.predID) {
            this.queryWithPredID(obj, callbackData, callback);
        } else {
            let reqData = {
                type: "entID",
                ty: "p",
                tm: setData.predTmplID,
                s: setData.predStr,
            };
            dbReqManager.query(this, reqData, function(sg, result) {
                setData.predID = (result[0] ?? [0])[0];
                sg.queryWithPredID(obj, callbackData, callback);

                // As a temporary solution for adding missing predicates, all
                // predicates are just automatically submitted to the database,
                // if they are missing in this query.
                if (setData.predID || !setData.inputUserID) {
                    return;
                }
                let reqData = {
                    type: "term",
                    u: setData.inputUserID,
                    ty: "p",
                    tm: setData.predTmplID,
                    s: setData.predStr,
                };
                dbReqManager.input(this, reqData, function() {});
            });
        }
    }

    queryWithPredID(obj, callbackData, callback) {
        if (!callback) {
            callback = callbackData;
            callbackData = undefined;
        }
        let setData = this.setData;
        let reqData = {
            type: "set",
            u: setData.queryUserID,
            p: setData.predID,
            rl: setData.ratingLo,
            rh: setData.ratingHi,
            n: setData.num,
            o: setData.offset,
            a: setData.isAscending,
        };
        dbReqManager.query(this, reqData, function(sg, result) {
            if (sg.replaceExistingSet) {
                sg.set = result;
            } else {
                sg.set = sg.set.concat(result);
            }
            let setData = sg.setData;
            setData.offset += setData.num; // default for a subsequent query.
            callback(obj, sg.set, callbackData);
        });
    }

    getSetPredicates() {
        // There is a race condition here, so take heed of it and try not to
        // call getSetPredicates() before the first entID queries.
        // TODO: Consider if this race condition should be eliminated somehow.
        return [this.setData.predID ?? null];
    }
}

/* SetCombiner is also an abstract class, as combineSets() needs implementing */
export class SetCombiner extends SetGenerator {
    constructor(
        setGeneratorArr,
        sortAscending, setArr, isReadyArr, // optional.
    ) {
        super();
        this.setGeneratorArr = setGeneratorArr ?? [];
        let setNum = this.setGeneratorArr.length;
        this.setArr = setArr ?? new Array(setNum);
        this.isReadyArr = isReadyArr ?? new Array(setNum).fill(false);
        this.sortAscending = sortAscending ?? 0;
    }

    generateSet(obj, callbackData, callback) {
        if (!callback) {
            callback = callbackData;
            callbackData = undefined;
        }
        let thisSG = this;
        this.setGeneratorArr.forEach(function(val, ind) {
            val.generateSet(thisSG, ind, function(sg, set, ind) {
                sg.setArr[ind] = (sg.transformSet(set) ?? set);
                sg.isReadyArr[ind] = true;
                sg.combineSetsIfReady(obj, callbackData, callback);
            });
        });
    }

    combineSetsIfReady(obj, callbackData, callback) {
        let isReady = this.isReadyArr.reduce(
            (acc, val) => acc && val, true
        );
        if (isReady) {
            let combSet = this.combineSets();
            callback(obj, combSet, callbackData);
        }
    }

    transformSet(set) {
        // can be redefined by descendant classes.
        // (transformSet() might also store additional data for combineSets().)
    }

    combineSets() {
        // to be redefined by descendant classes.
    }

    getSetPredicates() {
        let predIDArrArr = this.setGeneratorArr.map(
            val => val.getSetPredicates()
        );
        return [].concat(...predIDArrArr);
    }
}


/* An example of a class that implements SetCombiner */
export class MaxRatingSetCombiner extends SetCombiner {
    constructor(
        setGeneratorArr,
        sortAscending, setArr, isReadyArr, // optional.
    ) {
        super(
            setGeneratorArr,
            sortAscending, setArr, isReadyArr,
        );
    }

    combineSets() {
        // setArr is imploded into concatArr, which is then sorted by subjID.
        let concatSet = [].concat(...this.setArr).sort(
            (a, b) => a[1] - b[1]
        );
        // construct a return array by recording only the maximal rating for
        // each group of elements with the same subjID in the concatArr.
        let ret = new Array(concatSet.length);
        let retLen = 0;
        let currSubjID = 0;
        let row, maxRat, currRat;
        concatSet.forEach(function(val, ind) {
            if (val[1] !== currSubjID) {
                currSubjID = val[1];
                maxRat = val[0];
                ret[retLen] = (row = [maxRat, currSubjID]);
                retLen++;
            } else {
                currRat = val[0];
                if (currRat > maxRat) {
                    row[0] = (maxRat = currRat);
                }
            }
        });
        // delete the empty slots of ret.
        ret.length = retLen;
        // set and return this.combSet as ret sorted after the combRatVal.
        if (this.sortAscending) {
            return this.combSet = ret.sort((row1, row2) => row1[0] - row2[0]);
        } else {
            return this.combSet = ret.sort((row1, row2) => row2[0] - row1[0]);
        }
    }
}



// /*
// data.setDataArr = [setData, ...],
//     setData = {
//         predTmplID, predStr, objID,
//         predID?,
//         queryUserID,
//         // weight, queryParams, ratTransFun?,
//         set?,
//         concatWithExistingSet?,
//         isReady?,
//     },
//     queryParams = {num, ratingLo, ratingHi, offset?, isAscending}.
// */
//
// export class SetManager {
//     constructor(
//         setDataArr,
//         parentManager, childManagerArr,
//         sortAscending, combSet
//     ) {
//         this.setDataArr = setDataArr ?? [];
//         this.parentManager = parentManager;
//         this.childManagerArr = childManagerArr ?? [];
//         this.sortAscending = sortAscending ?? 0; // false;
//         // this.concatSet = concatSet;
//         this.combSet = combSet;
//     }
//
//     queryAndCombineSets(callbackData, callback) {
//         if (!callback) {
//             callback = callbackData;
//             callbackData = undefined;
//         }
//         let setNum = this.setDataArr.length;
//         for (let i = 0; i < setNum; i++) {
//             let setData = this.setDataArr[i];
//             if (!setData.set) {
//                 // if setData.predID is already known, query for the set
//                 // immediately.
//                 if (setData.predID) {
//                     this.querySetAndCombineIfReady(
//                         setData, i, callbackData, callback
//                     );
//                     continue;
//                 }
//                 // else, first query for the predID, and then the set.
//                 let reqData = {
//                     type: "entID",
//                     c: setData.predTmplID,
//                     s: setData.predStr,
//                     t: setData.objID,
//                 };
//                 dbReqManager.query(this, reqData, i, function(obj, result, i) {
//                     setData.predID = (result[0] ?? [0])[0];
//                     obj.querySetAndCombineIfReady(
//                         setData, i, callbackData, callback
//                     );
//                 });
//             } else if (!setData.isReady) {
//                 setData.set = this.transformSet(setData.set, setData, i);
//                 setData.isReady = true;
//             }
//         }
//         this.combineSetsIfReady(callbackData, callback);
//     }
//
//     querySetAndCombineIfReady(setData, i, callbackData, callback) {
//         let queryParams = setData.queryParams;
//         queryParams.offset ??= 0;;
//         queryParams.isAscending ??= 0;;
//         let reqData = {
//             type: "set",
//             u: setData.queryUserID,
//             p: setData.predID,
//             rl: queryParams.ratingLo,
//             rh: queryParams.ratingHi,
//             n: queryParams.num,
//             o: queryParams.offset,
//             a: queryParams.isAscending,
//         };
//         dbReqManager.query(this, reqData, i, function(obj, result, i) {
//             setData.set = obj.transformSet(result, setData, i);
//             setData.isReady = true;
//             obj.combineSetsIfReady(callbackData, callback);
//         });
//     }
//
//     transformSet(set, setData, i) {
//         let ratTransFun = setData.ratTransFun;
//         set.forEach(function(row) {
//             row[2] = ratTransFun(row[0]);
//             row[3] = i;
//         });
//         return set;
//     }
//
//     combineSetsIfReady(callbackData, callback) {
//         let isReady = this.setDataArr.reduce(
//             (acc, val) => acc && val.isReady, true
//         );
//         if (isReady) {
//             this.computeConcatenatedSet();
//             this.computeCombinedSet();
//             callback(this.combSet, callbackData);
//         }
//     }
//
//     computeConcatenatedSet() {
//         let setArr = this.setDataArr.map(val => val.set);
//         return this.concatSet = [].concat(...setArr).sort(
//             (a, b) => a[1] - b[1]
//         );
//     }
//
//     computeCombinedSet() {
//         let ret = new Array(this.concatSet.length);
//         let retLen = 0;
//         let weightArr = this.setDataArr.map(val => val.weight);
//         let currSubjID = 0;
//         let row, accWeight, currWeight, newWeight;
//         this.concatSet.forEach(function(val, ind) {
//             if (val[1] !== currSubjID) {
//                 currSubjID = val[1];
//                 ret[retLen] = (row = [val[2], val[1], ind]);
//                 retLen++;
//                 accWeight = weightArr[val[3]];
//             } else {
//                 currWeight = weightArr[val[3]];
//                 newWeight = accWeight + currWeight;
//                 row[0] = (row[0] * accWeight + val[2] * currWeight) / newWeight;
//                 accWeight = newWeight;
//             }
//         });
//         // delete the weight column of the last row and delete the empty slots.
//         if (retLen > 0) {
//             ret[retLen - 1].length = 3;
//         }
//         ret.length = retLen;
//         // set and return this.combSet as ret sorted after the combRatVal.
//         if (this.sortAscending) {
//             return this.combSet = ret.sort((row1, row2) => row1[0] - row2[0]);
//         } else {
//             return this.combSet = ret.sort((row1, row2) => row2[0] - row1[0]);
//         }
//     }
//
//
//
// }
