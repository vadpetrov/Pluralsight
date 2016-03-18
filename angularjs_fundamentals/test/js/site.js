(function () {

    "use strict";
       

    //alert(angular);

}());


(function () {

    angular.module("app", [])
        .controller("helloWorldController", hwController);

    function hwController($scope) {

        $scope.helloMessage = "Hello Vadim 1";
    };
}());


(function () {

    var module = angular.module("app");
    module.controller("helloWorldController1", hwController);

    function hwController() {

        var vm = this;
        vm.helloMessage = "Hello Vadim 2";
    };

}());