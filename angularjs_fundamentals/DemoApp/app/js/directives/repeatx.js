(function () {
    "use strict";

    var eventsApp = angular.module("eventsApp");


    eventsApp.directive("repeatX", function ($compile) {
        
        return {
            restrict: "A",

            //link: linkAction,

            //scope does not exist for compile
            compile: compileAction
        };
        

        function compileAction(element, attributes) {

            for (var i = 0; i < Number(attributes.repeatX) - 1 ; i++) {

                element.after(element.clone().attr("repeat-x", 0));
            }

            return function (scope, element, attributes, controller) {

                attributes.$observe("text", function (newValue) {

                    if (newValue === "Hello World") {
                        element.css("color", "red");
                    }
                });

            };
        };


        function linkAction(scope, element, attrs, controller) {
                        
            for (var i = 0; i < Number(attrs.repeatX)-1 ; i++){

                element.after($compile(element.clone().attr("repeat-x",0))(scope));
            }
        };
    });


}());