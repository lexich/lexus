require(["jQuery", "underscore", "lib/Car", "lib/Preloader", "lib/Scroller"], function($, _, Car, Preloader, Scroller) {
  return $(document).ready(function() {
    var $car, car, data, preloader, scroller, _ref;

    $("[data-js-audio-change]").click(function(e) {
      var $item, change, src;

      e.preventDefault();
      $item = $(e.target);
      src = $item.attr("src");
      change = $item.data("js-audio-change");
      $item.attr("src", change);
      return $item.data("js-audio-change", src);
    });
    preloader = new Preloader;
    preloader.render();
    $car = $("[data-js-car]:first");
    data = (_ref = $car.data("js-car")) != null ? _ref : {};
    car = new Car({
      el: $car,
      movement: data.movement,
      duration: data.duration
    });
    car.render();
    return scroller = new Scroller();
  });
});
