(function () {
    "use strict";

    var eventsApp = angular.module("eventsApp");
    
    eventsApp.directive("greeting", function () {

        return {
            restrict: "E",
            replace: true,
            //priority: -1,

            //for nested directives (works only on container type elements. example:div)
            transclude: true,
            template: "<div><button class='btn btn-default' ng-click='sayHello()'>Say Hello</button><div ng-transclude ><div></div>",


            //template: "<button class='btn btn-default' ng-click='sayHello()'>Say Hello</button>",


            /*
            controller: "@",
            name: "ctrl"
            */
            //controller: "GreetingController"
            controller: function ($scope) {

                var greetings = ["Hellllllllo"];

                $scope.sayHello = function () {
                    alert(greetings.join());
                };

                this.addGreeting = function (newGreeting) {
                    greetings.push(newGreeting);
                };
            }
        };
    })
    .directive("finnish", function () {
        return {
            restrict: "A",

            //must be on same level with directive
            //require: "greeting",

            //must be inside directive (nested directives) and transclude must be emplemented on primary directive
            require: "^greeting",

            //execution priority, order
            //priority: -1,

            //prevent directives execution with lower priority
            //terminal:true,

            //allows to use the controller from another directive
            
            link: function (scope, element, attrs, controller) {
                controller.addGreeting("hei");
            }
        };
    })
    .directive("hindi", function () {
        return {
            restrict: "A",
            require: "^greeting",

            //priority: -2,            
            link: function (scope, element, attrs, controller) {
                controller.addGreeting("namaste");
            }
        };
    });



    eventsApp.controller("GreetingController", GreetingControllerFN);

    function GreetingControllerFN($scope) {

        $scope.sayHello = function () { alert("Hello 2"); };
    };

}());