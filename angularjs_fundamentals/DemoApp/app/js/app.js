(function(){
    "use strict";

    var eventsApp = angular.module("eventsApp", ["ngSanitize", "ngResource", "tmh.dynamicLocale"])
        .factory("myCache", function ($cacheFactory) {
            //return $cacheFactory("myCache");
            return $cacheFactory("myCache", { capacity: 3 });
        });

    eventsApp.config(function (tmhDynamicLocaleProvider) {
        tmhDynamicLocaleProvider.localeLocationPattern("/lib/angular-i18n/angular-locale_{{locale}}.js");
        //tmhDynamicLocaleProvider.localeLocationPattern("/lib/angular-i18n/angular-locale_{{locale}}.js")
        //.useCookieStorage();
    });

    /*
    eventsApp.config((localStorageServiceProvider: angular.dynamicLocale.tmhDynamicLocaleProvider) => 
    {
        localStorageServiceProvider
            .localeLocationPattern("app/angular-i18n/")
            .useCookieStorage();
    }
    */
}());


