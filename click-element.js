var clicked = false;
// prettier-ignore
var element = document.querySelector('<<selector>>');
if (element) {
  var event = new MouseEvent("click", {
    view: window,
    bubbles: true,
    cancelable: true,
  });
  // element.click();
  element.dispatchEvent(event);
  clicked = true;
}
clicked;
