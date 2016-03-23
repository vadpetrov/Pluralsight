(function () {

    "use strict";

    var module = angular.module("eventsApp");
    ////////////////////////////////////////////////////////////
    module.filter("to_trusted", ["$sce", function ($sce) {
        return function (text) {
            return $sce.trustAsHtml(text);
        };
    }]);
    ///////////////////////////////////////////////////////////
    module.filter("durations", function () {
        return function (duration) {
            switch( duration)
            {
                case 1:
                    return "Half Hour";
                case 2:
                    return "1 Hour";
                case 3:
                    return "Half Day";
                case 4:
                    return "Full Day";
            }
        };
    });

}());