$(document).on("shiny:connected", function(e) {
  Shiny.onInputChange("scatterBoxWidth", $("#scatterBox").width());
});

$(window).resize(function(e) {
  Shiny.onInputChange("scatterBoxWidth", $("#scatterBox").width());
});