(function () {
    "use strict";

    var eventsApp = angular.module("eventsApp");


    eventsApp.directive("gravatar", function (gravatarUrlBuilder) {
        
        return {
            restrict: "E",
            replace: true,
            template: "<img />",
            link: linkAction
        };

        function linkAction(scope, element, attrs, controller) {

            attrs.$observe("email", function (newValue, oldValue) {
                if (newValue != oldValue) {
                    attrs.$set("src", gravatarUrlBuilder.buildGravatarUrl(newValue));
                }
            });
        };

    });


}());