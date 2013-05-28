define(["jQuery", "underscore", "Backbone"], function($, _, Backbone) {
  var Preloader;

  Preloader = (function(__super__) {
    return __super__.extend({
      el: "[data-js-preloader]:first",
      render: function() {
        var $original, $shadow, duration, left, _ref,
          _this = this;

        $original = this.$el.find("[data-js-preloader-original]");
        $shadow = this.$el.find("[data-js-preloader-shadow]");
        $shadow.css({
          position: "absolute",
          top: $original.position().top,
          left: $original.position().left,
          width: $original.width(),
          height: $original.height()
        });
        if ($shadow.length <= 0 || $original.length <= 0) {
          return;
        }
        left = "+=" + ($original.width());
        duration = (_ref = this.options.duration) != null ? _ref : 2000;
        $shadow.animate({
          left: left
        }, {
          duration: duration,
          complete: function() {
            var _ref1, _ref2;

            $shadow.parent("[data-js-preloader]").fadeOut((_ref1 = _this.options.fadeout) != null ? _ref1 : 400);
            return (_ref2 = _this.options) != null ? typeof _ref2.next === "function" ? _ref2.next() : void 0 : void 0;
          }
        });
        return __super__.prototype.render.apply(this, arguments);
      }
    });
  })(Backbone.View);
  return Preloader;
});
