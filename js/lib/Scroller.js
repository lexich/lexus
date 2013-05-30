define(["jQuery", "underscore", "Backbone"], function($, _, Backbone) {
  var EPS, Scroller;

  EPS = 10;
  Scroller = (function(__super__) {
    return __super__.extend({
      el: "[data-js-scrollmenu]",
      events: {
        "click a[href^='#']": "event_click",
        "click a[href^='#'] > *": "event_click_hack"
      },
      delay: null,
      stepAnimation: 0,
      parralax: {},
      parralaxItems: $(),
      initialize: function() {
        var prev, result,
          _this = this;

        $(window).scroll(_.bind(this.event_windowScroll, this));
        this.autoScroll();
        result = [];
        _.each($("a[href^='#']", this.$el), function(item) {
          var href;

          href = $(item).attr("href");
          if ($(href).length === 1) {
            return result.push($(href).position().top);
          }
        });
        _.sortBy(result, function(x) {
          return x;
        });
        prev = 0;
        _.each(result, function(to) {
          var from;

          from = prev;
          _this.parralax[to] = function(p) {
            return (from - p) * Math.PI / (from - to);
          };
          return prev = to;
        });
        this.parralaxItems = $("[data-parralax]");
        return _.each(this.parralaxItems, function(item) {
          var mTop;

          mTop = parseInt($(item).css("marginTop").replace("px", ""));
          return $(item).data('parralax-top', mTop);
        });
      },
      scroll: function(from, to, duration) {
        var move,
          _this = this;

        if (duration == null) {
          duration = 2000;
        }
        from = parseInt(from);
        to = parseInt(to);
        _this = this;
        move = to - from;
        if (Math.abs(move) < EPS) {
          return;
        }
        this.$el.stop(true, false);
        this.$el.prop("scroll", from);
        return this.$el.animate({
          scroll: "+=" + move
        }, {
          duration: duration,
          step: function(now) {
            _this.stepAnimation += 1;
            return window.scrollTo(0, now);
          },
          complete: function() {}
        });
      },
      autoScroll: function() {
        var from, move,
          _this = this;

        from = from = $(window).scrollTop();
        move = _.reduce(this.$el.find("a[href^='#']"), (function(memo, a) {
          var delta, href, top;

          href = $(a).attr("href");
          top = _this.getAnchorPos(href);
          if (top == null) {
            return memo;
          }
          delta = top - from;
          if (Math.abs(delta) < Math.abs(memo)) {
            return delta;
          } else {
            return memo;
          }
        }), $(document).height());
        if (Math.abs(move) < EPS) {
          return;
        }
        return this.scroll(from, from + move, 1000);
      },
      event_windowScroll: function(e) {
        var eff, i, mapKey, now, _i, _len, _ref,
          _this = this;

        if (this.stepAnimation === 0) {
          this.$el.stop(true, false);
        }
        this.stepAnimation = 0;
        now = $(window).scrollTop();
        _ref = _.keys(this.parralax);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (now < i) {
            mapKey = i;
          }
        }
        if (mapKey != null) {
          eff = this.parralax[mapKey](now);
          if (Math.abs(eff) < 0.000001) {
            eff = 0;
          }
          _.each(this.parralaxItems, function(item) {
            var k, mTop;

            k = eff * parseFloat($(item).data("parralax"));
            mTop = $(item).data("parralax-top");
            return $(item).css("marginTop", "" + (k * eff + mTop) + "px");
          });
        }
        if (this.delay != null) {
          clearTimeout(this.delay);
          this.delay = null;
        }
        return this.delay = setTimeout((function() {
          _this.autoScroll();
          return _this.delay = null;
        }), 500);
      },
      getAnchorPos: function(href) {
        var $anchor, heigth, move, result, top, wHeigth;

        if (!/^#.+/.test(href)) {
          return;
        }
        $anchor = $(href);
        if ($anchor.length !== 1) {
          return;
        }
        top = $anchor.offset().top;
        wHeigth = $(window).height();
        heigth = $anchor.height();
        move = (wHeigth - heigth) / 2;
        if (move > 0) {
          result = top - move;
          if (result < 0) {
            result = 0;
          }
          return result;
        } else {
          return top;
        }
      },
      event_click_hack: function(e) {
        return this.click_link($(e.target).parent("a"));
      },
      event_click: function(e) {
        e.preventDefault();
        return this.click_link($(e.target));
      },
      click_link: function($link) {
        var from, href, to;

        href = $link.attr("href");
        from = $(window).scrollTop();
        to = this.getAnchorPos(href);
        if (to == null) {
          return;
        }
        return this.scroll(from, to);
      }
    });
  })(Backbone.View);
  return Scroller;
});
