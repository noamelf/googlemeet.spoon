var now = new Date();

var divs = document.querySelectorAll("div[data-begin-time]");
var clicked = false;

divs.forEach(function (div) {
  // Assuming the time is in milliseconds since the Unix Epoch
  var time = new Date(Number(div.getAttribute("data-begin-time")));

  var diff = Math.abs(now - time);
  if (diff < 60 * 1000) {
    div.click();
    clicked = true;
  }
});

clicked;
