import {useState, useMemo, useContext, useCallback} from "react";
import {useDispatch} from "../../../../hooks/useDispatch";

import {basicEntIDs} from "../../../../entity_ids/basic_entity_ids.js";

import {SubpagesWithTabs} from "./SubpagesWithTabs.js";
import {EntityList} from "../../../entity_lists/EntityList.js";
import {ScaleReference} from "../../../entity_refs/EntityReference.js";

/* Placeholders */
const TabHeader = () => <template></template>;


export const ClassSubpage = ({entID}) => {

  const getPageCompFromID = useCallback(tabID => {
    if (tabID == entID) {
      return [AllMembersPage, {entID: entID}];
    }
    return [ClassSubpage, {entID: tabID}];
  }, [entID]);

  const initTabsJSON = JSON.stringify([
    [entID, "All"],
  ]);
  const tabScaleKeysJSON = JSON.stringify([
    [entID, basicEntIDs["relations/subclasses"]],
  ]);

  return (
    <SubpagesWithTabs
      initTabsJSON={[initTabsJSON]}
      getPageCompFromID={getPageCompFromID}
      getTabTitleFromID="Name"
      tabScaleKeysJSON={tabScaleKeysJSON}
      tabBarHeader={<ScaleReference
        objID={entID} relID={basicEntIDs["relations/subclasses"]}
      />}
    />
  );
};



export const AllMembersPage = ({entID}) => {
  return (
    <EntityList
      scaleKeyJSON={JSON.stringify(
        [entID, basicEntIDs["relations/members"]]
      )}
      lo={5}
    />
  );
};
