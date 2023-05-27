var now = new Date();
var closest;
var closestDiff = Infinity;

var divs = document.querySelectorAll('div[data-begin-time]');

divs.forEach(function(div) {
    // Assuming the time is in milliseconds since the Unix Epoch
    var time = new Date(Number(div.getAttribute('data-begin-time')));

    var diff = Math.abs(now - time);

    if(diff < closestDiff) {
        closest = div;
        closestDiff = diff;
    }
});

if(closest) {
    closest.click(); // Perform a click event on the closest time div
}
