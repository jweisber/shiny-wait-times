$(document).on("shiny:connected", function(e) {
  Shiny.onInputChange("scatterBoxWidth", $("#scatterBox").width());
});

var resizeTimer;

$(window).resize(function(e) {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(function() {
    Shiny.onInputChange("scatterBoxWidth", $("#scatterBox").width());
  }, 500);
});