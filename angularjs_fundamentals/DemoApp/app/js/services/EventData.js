(function () {

    "use strict";

    var module = angular.module("eventsApp");
    module.factory("eventData", repo);    
    ////////////////////////////////////////////////////////////////////////////   

    function repo($http, $log, $resource) {

        var resource = $resource("/data/event/:id", { id: "@id" });
        //var resource = $resource("/data/event/:id", { id: "@id" }, { "getAll": { method: "GET", isArray: true, params: { something: "foo" } } });
        
        return {
            event: getData(),            
            getEvent: getEvent,
            getEvent1: getEvent1,
            getEvent2: getEvent2,
            getEvent3: getEvent3,
            save: saveEvent,
            getAllEvents: getAllEvents
        };

        function getAllEvents() {
            return resource.query();
        };

        function saveEvent(event) {
            event.id = 999;
            return resource.save(event);
        };

        function getEvent3(eventId) {
            return resource.get({ id: eventId });
            //return $resource("/data/event/:id", {id:"@id"}).get({id:1});
        };
        ///////////////////////////////////////////////
        function getEvent2() {
            return $http.get("/data/event/1");
        };
        ///////////////////////////////////////////////
        function getEvent1() {

            return $http.get("/data/event/1")
                .then(function (response) {
                    return response.data;
                });
        };
        ///////////////////////////////////////////////
        function getEvent(successCB) {

            $http.get("/data/event/1")
                .success(function (data, status, headers, config) {
                    successCB(data);//callback function
                })
                .error(function (data, status, headers, config) {
                    $log.warn("get event error");
                    $log.warn(data, status, headers(), config);
                });
        };
        ///////////////////////////////////////////////
        function getData() {

            return {
                divShowBorder: false,
                divBorder: "border:1px solid white;",
                name: "Angular Boot Camp",
                date: "1/1/2013",
                jsdate: new Date("1/1/2013"),
                time: "10:30 am",
                location: {
                    address: 'Google Headquarters',
                    city: 'Mountain View',
                    province: 'CA'
                },
                imageUrl: '/img/angularjs-logo.png',
                sessions: [
                      {
                          name: 'Directives Masterclass',
                          creatorName: 'Bob Smith',
                          duration: 1,
                          level: 'Advanced',
                          abstract: 'In this session you will learn the ins and outs of directives!',
                          upVoteCount: 0
                      },
                      {
                          name: 'Scopes for fun and profit',
                          creatorName: 'John Doe',
                          duration: 2,
                          level: 'Introductory',
                          abstract: 'This session will take a closer look at scopes. Learn what they do, how they do it, and how to get them to do it for you.',
                          upVoteCount: 0
                      },
                      {
                          name: 'Well Behaved Controllers',
                          creatorName: 'Jane Doe',
                          duration: 4,
                          level: 'Intermediate',
                          abstract: 'Controllers are the beginning of everything Angular does. Learn how to craft controllers that will win the respect of your friends and neighbors',
                          upVoteCount: 0
                      }
                ]
            };
        };
    };

}());