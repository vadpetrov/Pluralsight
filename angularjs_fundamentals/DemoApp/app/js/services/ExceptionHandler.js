(function () {

    "use strict";

    var module = angular.module("eventsApp");
    module.factory("$exceptionHandler", errorHandler);
    ////////////////////////////////////////////////////////////////////////////  

    function errorHandler() {
        return function (exception) {
            console.log("exception handled:" + exception.message);
        };
    };

}());