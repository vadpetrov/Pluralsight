/// <reference path="_all.ts" />
var TestApp;
(function (TestApp) {
    var UserModel = (function () {
        function UserModel(lastName, firstName, dateB) {
            this.lastName = lastName;
            this.firstName = firstName;
            this.dateB = dateB;
        }
        return UserModel;
    }());
    TestApp.UserModel = UserModel;
})(TestApp || (TestApp = {}));
//# sourceMappingURL=model.js.map