(function () {


    "use strict";

    var module = angular.module("eventsApp");
    module.controller("TimeoutSampleController", TimeoutSampleController);


    function TimeoutSampleController($scope, $timeout) {

        var promise = $timeout(function () {
            $scope.name = "John Doe";
        }, 3000);

        //setTimeout(function () {
        //    $scope.name = "John Doe";
        //}, 3000);

        $scope.cancel = function () {
            $timeout.cancel(promise);
        }


        var a;
        Test1(a, -1).then(
            function (a) { console.log(a); },
            function (a) { console.log(a); }
            );
        /////////////////////////////////////////
        Test1(10, 31)
        .then(function (a) {
            console.log(a);
        })
        .catch(
        function (a) {
            console.log(a);
        });

        function Test1(a, b) {            
            return new Promise(function (success, error) {

                try {
                    if ((a + b) >= 10) {
                        success("TADA");
                    }
                    else {
                        error("Failed");
                    }
                }
                catch (er)
                {
                    error(er);
                }
            });
        };
    };
}());