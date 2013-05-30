define(["jQuery", "underscore", "Backbone"], function($, _, Backbone) {
  var Car, getRotationDegrees;

  getRotationDegrees = function(obj) {
    var a, angle, b, matrix, values;

    matrix = obj.css("-webkit-transform") || obj.css("-moz-transform") || obj.css("-ms-transform") || obj.css("-o-transform") || obj.css("transform");
    if (matrix !== "none") {
      values = matrix.split("(")[1].split(")")[0].split(",");
      a = values[0];
      b = values[1];
      angle = Math.round(Math.atan2(b, a) * (180 / Math.PI));
    } else {
      angle = 0;
    }
    if (angle < 0) {
      return angle += 360;
    } else {
      return angle;
    }
  };
  Car = (function(__super__) {
    return __super__.extend({
      el: "[data-js-car]",
      movement: 500,
      duration: 4000,
      isVisible: function() {
        var bottom, top, wBottom, wTop;

        wTop = $(window).scrollTop();
        wBottom = wTop + $(window).height();
        top = this.$el.position().top;
        bottom = top + this.$el.height();
        return (wTop <= top && top <= wBottom) || (wTop <= bottom && bottom <= wBottom);
      },
      initialize: function() {
        var _ref, _ref1;

        this.movement = (_ref = this.options.movement) != null ? _ref : this.movement;
        this.duration = (_ref1 = this.options.duration) != null ? _ref1 : this.duration;
        return this.initMenu();
      },
      initMenu: function() {
        var $links,
          _this = this;

        $links = $("a[data-js-carmenu-color]");
        $links.click(function(e) {
          var $car, path;

          e.preventDefault();
          $links.parent("li").removeClass("active");
          $(e.target).parent("li").addClass("active");
          path = $(e.target).data("js-carmenu-color");
          if (path == null) {
            return;
          }
          $car = _this.$el.find("[data-js-carcolor-change]");
          $car.attr("class", "");
          return $car.addClass(path);
        });
        return setTimeout((function() {
          var content;

          content = _.map($links, function(link) {
            return "<div class='" + ($(link).data("js-carmenu-color")) + "'></div>";
          });
          return $("body").append($("<div>").css({
            width: 0,
            height: 0,
            opacity: 0,
            overflow: "hidden"
          }).html(content));
        }), 2000);
      },
      render: function() {
        var $wheels, prevMove,
          _this = this;

        if (this.isVisible()) {
          $wheels = $("[data-js-car-wheel]", this.$el);
          prevMove = 0;
          return this.$el.animate({
            left: "+=" + this.movement
          }, {
            duration: this.duration,
            step: function(now, tween) {
              var delta, move;

              move = tween.start - tween.now;
              delta = move - prevMove;
              prevMove = move;
              return _.each($wheels, function(wheel) {
                var $wheel, L, curDeg, deg, degRotate, deltaDeg, r;

                $wheel = $(wheel);
                r = $wheel.height() / 2;
                L = 2 * Math.PI * r;
                deltaDeg = -delta * 360 / L;
                curDeg = getRotationDegrees($wheel);
                deg = deltaDeg + curDeg;
                degRotate = "rotate(" + (deg.toFixed(2)) + "deg)";
                return $wheel.css("transform", degRotate);
              });
            },
            complete: function() {
              _this.movement = -_this.movement;
              return _this.render();
            }
          });
        } else {
          return setTimeout((function() {
            return _this.render();
          }), 1000);
        }
      }
    });
  })(Backbone.View);
  return Car;
});
