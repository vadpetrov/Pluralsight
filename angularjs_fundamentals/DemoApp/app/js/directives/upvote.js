(function () {
    "use strict";

    var eventsApp = angular.module("eventsApp");


    eventsApp.directive("upvote", function () {

        //directive with model bindning
        return {
            restrict: "E",
            replace: true, //will replace event-thumbnail tag with template html instead of append
            templateUrl: "/templates/directives/upvote.html",
            scope: {
                upvote: "&upVote",
                downvote: "&downVote",
                votecount: "=voteCount"
            }
        };

        //directive without model bindning
        //return {
        //    restrict: "E",
        //    replace: true, //will replace event-thumbnail tag with template html instead of append
        //    templateUrl: "/templates/directives/eventThumbnail.html"
        //};

    });

}());