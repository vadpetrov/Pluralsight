(function () {
    "use strict";

    var eventsApp = angular.module("eventsApp");


    eventsApp.directive("dateKeys", function () {
                
        return {
            restrict: "A",
            link: function (scope, element, attrs, controller) {

                element.on("keydown", function (e) {
                    if (isNumericKeyCode(e.keyCode)
                        || isForwardSlashKeyCode(e.keyCode)
                        || isNavigationKeycode(e.keyCode)){

                        return true;
                    }
                    return false;
                });
            }
        };
    });
        
    function isNumericKeyCode(keyCode) {
        return (event.keyCode >= 48 && event.keyCode <= 57)
            || (event.keyCode >= 96 && event.keyCode <= 105);
    };
    function isForwardSlashKeyCode(keycode) {
        return event.keyCode === 191;
    };
    function isNavigationKeycode(keyCode) {
        switch (keyCode) {
            case 8: //backspace
            case 35: //end
            case 36: //home
            case 37: //left
            case 38: //up
            case 39: //right
            case 40: //down
            case 45: //ins
            case 46: //del
                return true;
            default:
                return false;
        }
    };

}());