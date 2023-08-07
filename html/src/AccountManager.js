

export class AccountManager {
    constructor() {
        if (typeof(Storage) === "undefined") {
            alert(
                "This web application requires browser support for local " +
                "storage in order to function correctly. It seems that your " +
                "browser does not support local storage."
            );
            return;
        }
    }

    get session() {
        return localStorage.session ?? false;
    }
    get userID() {
        return this.session.userID;
    }
    get sesID() {
        return this.session.sesID;
    }
    get expTime() {
        return this.session.expTime;
    }

    get isLoggedIn() {
        return this.session && this.expTime + 10 < Date.now();
    }

    get inputUserID() {
        return this.isLoggedIn ? this.userID : false;
    }

    // TODO: Reimplement, first with initial_user changed for 5-baised mean bot,
    // and later on with other, user-specific, possibilities.
    get queryUserPriorityArr() {
        return [this.inputUserID, 9];
    }


    logout(obj, callbackData, callback) {
        if (!callback) {
            callback = callbackData ?? (x => void(0));
            callbackData = null;
        }
        if (!this.isLoggedIn) {
            callback(obj, false, callbackData);
            return;
        }
        let reqData = {
            u: this.inputUserID,
            sesID: this.sesID,
        };
        $.post("logout_handler.php", reqData, function(result) {
            callback(obj, result, callbackData);
        });
    }

    login(userNameOrID, password, obj, callbackData, callback) {
        if (!callback) {
            callback = callbackData ?? (x => void(0));
            callbackData = null;
        }
        let reqData = {
            u: userNameOrID,
            pw: password,
        };
        $.post("login_handler.php", reqData, function(result) {
            if (result.exitCode == 0) {
                localStorage.session = {
                    userID: result.outID,
                    sesID: result.sesID,
                    expTime: result.expTime,
                };
            }
            callback(obj, result, callbackData);
        });
    }

    // TODO: Consider making an update_session_handler and then an
    // updateSession() method here, such that users can in priciple stay logged
    // in if they keep visiting the site.

    createNewAccount(username, email, password, obj, callbackData, callback) {
        if (!callback) {
            callback = callbackData ?? (x => void(0));
            callbackData = null;
        }
        let reqData = {
            n: username,
            em: email,
            pw: password,
        };
        $.post("account_creation_handler.php", reqData, function(result) {
            if (result.exitCode == 0) {
                localStorage.session = {
                    userID: result.outID,
                    sesID: result.sesID,
                    expTime: result.expTime,
                };
            }
            callback(obj, result, callbackData);
        });
    }
}
