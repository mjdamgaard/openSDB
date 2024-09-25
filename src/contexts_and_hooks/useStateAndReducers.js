import {
  useState, useEffect, useLayoutEffect, useRef
} from "react";




/**
  This useSessionState() hook is a wrapper around the normal useState hook,
  which also backs up the state of the component in sessionStorage for as
  long as it is mounted, meaning that navigation to and back from another
  website will restore the state.
  Returns:
  useSessionState() returns the state like normal, but returns a dispatch()
  function (with more possibilities) instead of the normal setState(). More on
  dispatch() below.
  Lastly, it returns a passData() function, which has to wrap around any
  returned (JSX) element of the component if the children includes any session-
  stateful components. passData() then serves to pass the keys that allows
  useSessionState() to construct its own tree of DOM nodes.
  The order of the returns are: [state, passData, dispatch].
  Inputs:
  First input is the initial state, just like for useState().
  Second input is the props of the component, which is used both to get the
  relevant keys from the passData() called by the parent component, and is
  also used in the dispatch() function, meaning that the outcome of dispatch()
  can depend on props. Furthermore, it can also depend on the component's
  contexts, but this require the user to pass [props, context] in place of
  the props input.
  Third input is the reducers to change the state (by calls to the dispatch()
  function). reducers, if provided, is an object always starting with a key
  property, which allows descendant components to access the components
  reducers as well. And from there, each member is of the form
  {action: reducer, ...}, where action is a unique string that selects the
  given reducer, and the reducer is a pure function that takes [state, props,
  contexts] as its first input, as well as an optional second input (passed to
  dispatch()), and returns a new state of the component. Reducers can can also
  take an optional third input, dispatch, which can be used to run other
  reducers right after execution, including those of the component's ancestors.
  If a reducer returns a nullish value, the state is unchanged.
  Access these reducers in order to change the state of this component by
  calling dispatch("self", action, input), where action is the key of the
  specific reducer in the reducers object, and input is the aforementioned
  second input that gets passed to the reducer. As mentioned, the reducers can
  also be accessed by any descendants by calling dispatch(key, action, input),
  where key is the aforementioned one defined in the reducers object.
  Fourth input, rootID, should only be set if you want the state to act as a
  root in the session state tree. Each rootID of the app must be unique (and
  also deterministic between hard refreshes/reboots of the entire app).
  And lastly, the fifth input, backUpAndRemove, is a flag that when set as
  true, removes all descendants of the component (making passData() return a
  React fragment for good measure), but backs them up in sessionStorage such
  that they are restored if backUpAndRemove is set as something falsy again.
**/


export const useStateAndReducers = (initState, reducers, props, contexts) => {
  reducers ??= {};

  // Call the useState() hook on initState.
  const [state, setState] = useState(initState);

  const ref = useRef();

  const dispatch = (key, action, input) => {
    dispatchFromRef(
      ref, reducers, setState, props, contexts, key, action, input
    );
  };

  useEffect(() => {
    AddOrReplaceReduceStateEventListener(ref, reducers, dispatch);
  });


  return [state, dispatch, ref];
};




export const useDispatch = (reducers, props, contexts) => {
  reducers ??= {};

  const ref = useRef();

  const dispatch = (key, action, input) => {
    dispatchFromRef(
      ref, reducers, (y) => {y()}, props, contexts, key, action, input
    );
  };

  useEffect(() => {
    AddOrReplaceReduceStateEventListener(ref, reducers, dispatch);
  });

  const modDispatch = getModifiedDispatch2(dispatch);
  return [modDispatch, ref];
};





function AddOrReplaceReduceStateEventListener(ref, reducers, dispatch) {
  if (ref.current) {
    let listener = (e) => {
      reduceStateEventHandler(e, ref, reducers, dispatch);
    };
    let prevListener = ref.current.getAttribute("data-reduce-state-listener");
    if (prevListener) {debugger;
      ref.current.removeEventListener("reduce-state", prevListener);
    }
    ref.current.addEventListener("reduce-state", listener);
    ref.current.setAttribute("data-reduce-state-listener", listener);
  }
}







function throwMissingAction(key, action, ref) {
  let error = (
    'dispatch(): No action of ' + JSON.stringify(action) + ' was found in ' +
    'reducers of key ' + JSON.stringify(key) + '. (See console.log for ' +
    'the ref of caller.)' 
  )
  console.error(error);
  console.log(ref);
  throw error;
}


function dispatchFromRef(
  ref, reducers, setState, props, contexts, key, action, input
) {
  if (!ref.current) {
    return;
  }
  // If key = "self", call one of this state's own reducers.
  if (key === "self" || key === null) {
    // If action is setState, call setState(input) with 'this' bound to
    // reducers if input is a function, and not just a constant state.
    if (action === "setState") {
      if (input instanceof Function) {
        input.bind(reducers);
      }
      setState(input);
    }
    // Else find the right reducer in reducers, with 'this' bound to reducers,
    // and setState with that.
    else {
      if (!(reducers[action] instanceof Function)) {
        return throwMissingAction(key, action, ref);
      }
      let reducer = reducers[action].bind(reducers);
      let modDispatch = getModifiedDispatch1((key, action, input) => (
        dispatchToAncestor(ref, key, action, input)
      ));
      setState(state => (
        reducer([state, props, contexts], input, modDispatch)
      ));
    }
  }
  // Else dispatch a event that bubble up to the first ancestor that has
  // called useStateAndReducers() or useDispatch(), and on from there if key
  // doesn't match that ancestor's reducer key.
  else {
    dispatchToAncestor(ref, key, action, input);
  }
}


function dispatchToAncestor(ref, key, action, input) {
  ref.current.parentElement.dispatchEvent(
    new CustomEvent("reduce-state", {
      bubbles: true,
      detail: [key, action, input],
    })
  );
}



function getModifiedDispatch1(dispatch) {
  return (key, action, input) => {
    if (key === "self") {
      throw (
        'useStateAndReducers: dispatch(): don\'t call "self" from ' +
        'within a reducer. Call this.MY_ACTION instead.'
      );
    }
    else return dispatch(key, action, input);
  };
}

function getModifiedDispatch2(dispatch) {
  return (key, action, input) => {
    if (key === "self") {
      throw (
        'useDispatch(): dispatch(): don\'t call "self" from ' +
        'a component that uses useDispatch() rather than ' +
        'useStateAndReducers().'
      );
    }
    else return dispatch(key, action, input);
  };
}






function reduceStateEventHandler(e, ref, reducers, dispatch) {
  let [key, action, input] = e.detail;
  // If key is an array, treat it as [key, skip] instead, where skip is
  // the number of ancestors to skip.
  let skip = 0;
  if (Array.isArray(key)) {
    [key, skip] = key;
    skip = parseInt(skip);
  }

  // If key doesn't match the reducer key, let the event bubble up
  // further.
  if (reducers.key !== key) {
    return true;
  }
  // Else handle the event.
  else {
    // Stop the event from going further.
    e.stopPropagation();
    // If skip > 0, replace the event with one where skip is decremented
    // by one, and let that bubble up instead.
    if (skip > 0) {
      ref.current.parentElement.dispatchEvent(
        new CustomEvent("reduce-state", {
          bubbles: true,
          detail: [[key, skip - 1], action, input],
        })
      );
    }
    // Else reduce the state of this component.
    else {
      dispatch("self", action, input);
    }
  }
  return false;
}








