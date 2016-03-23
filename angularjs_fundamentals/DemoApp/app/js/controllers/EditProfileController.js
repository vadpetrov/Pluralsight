(function () {


    "use strict";

    var module = angular.module("eventsApp");
    module.controller("EditProfileController", EditProfileController);



    function EditProfileController(gravatarUrlBuilder) {

        var vm = this;
        vm.user = {};
        vm.getGravatarUrl = getGravatarUrl;
                

        function getGravatarUrl(email) {

            return gravatarUrlBuilder.buildGravatarUrl(email);
        };
    };

}());