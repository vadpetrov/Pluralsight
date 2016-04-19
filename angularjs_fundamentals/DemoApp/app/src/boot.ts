/// <reference path="_all.ts" />

//let a = [1, 2, 3];
//let b = [...a, 4, 5, 6,7];

//for (var i of b) {
//    i++;
//}


//tsc.cmd -watch

module ContactManagerApp {
    angular.module("contactManagerApp", ["ngMaterial", "ngMdIcons", "ngMessages"])
        .service("userService", UserService)
        .controller("mainController", MainController)
        .config(($mdIconProvider: angular.material.IIconProvider,
                $mdThemingProvider: angular.material.IThemingProvider) => {

            $mdIconProvider
                .defaultIconSet("/svg/avatars.svg", 128)
                .icon("google_plus", "/svg/google_plus.svg", 512)
                .icon("hangouts", "/svg/hangouts.svg", 512)
                .icon("twitter", "/svg/twitter.svg", 512)
                .icon("phone", "/svg/phone.svg", 512)
                .icon("menu", "/svg/menu.svg", 24);

            $mdThemingProvider.theme("default")
                .primaryPalette("blue")
                .accentPalette("red");//.dark();

        });
}