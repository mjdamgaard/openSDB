
// AsyncManipulator is basically like a special case JS Promise class.
// Usage: Make an asyncManipulator instance, then push some callbacks, together
// with a key, that all ultimately ends in a call to either
// asyncManipulator.resolve(key) or asyncManipulator.resolve(reject). Then
// call asyncManipulator.executeThen(finalCallback) to fire off the callbacks.
// When all callbacks are resolved, a call to finalCallback("success") is made.
// But if one is rejected a call to finalCallback("failure", key) is made
// instead, where key is the key of the failed callback.
export class AsyncManipulator {
  constructor() {
    this.callbackObj = [];
    this.isReadyObj = [];
  }

  resolve(key) {
    this.isReadyObj[key] = true;
    let isReady = this.isReadyArr.reduce((acc, val) => acc && val);
    if (isReady) {
      this.finalCallback("success");
    }
  }

  reject(key) {
    this.finalCallback("failure", key);
  }

  push(key, callback) {
    this.callbackObj[key] = callback;
  }

  executeThen(finalCallback) {
    this.isReadyArr = this.callbackArr.map(() => true);
    this.callbackArr.forEach(callback => {
      callback();
    });

  }

}

