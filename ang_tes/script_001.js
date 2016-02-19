var work = function () {
    console.log("working hard!")

};

var doWork = function (f) {

    console.log("starting")

    try {
        f();
    } catch (ex) {
        console.log(ex);
    }

    console.log("end1")
};

doWork(work);
////////////////////////////////////
var createWorker100 = function () {

    return {
        job1: function () { console.log("job1"); },
        job2: function () { console.log("job2"); }
    }

};

var worker100 = createWorker100();

worker100.job1();
worker100.job2();
////////////////////////////////////
var createWorker101 = function () {

    var workCount = 0;

    var task1 = function () {
        workCount += 1;
        console.log("task1 " + workCount);
    };
    var task2 = function () {
        workCount += 1;
        console.log("task2 " + workCount);
    };

    return {
        job1: task1,
        job2: task2
    };
};

var worker101 = createWorker101();

worker101.job1();
worker101.job2();
////////////////////////////////////
(function () {
    //no global variables. big PLUS
    console.log("Immediately invoked function expression(IIFE)");
    console.log("Pronounced IFFY");
}());
////////////////////////////////////
