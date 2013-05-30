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
        var $links, prev,
          _this = this;

        $(window).scroll(_.bind(this.event_windowScroll, this));
        this.autoScroll();
        $links = _.chain($("a[href^='#']", this.$el)).uniq(function(item) {
          return $(item).attr("href");
        }).sortBy(function(item) {
          var href;

          href = $(item).attr("href");
          return $(href).position().top;
        }).value();
        prev = 0;
        _.each($links, function(link) {
          var from, to;

          to = _this.getAnchorPos($(link).attr("href"));
          from = parseInt(prev);
          to = parseInt(to);
          _this.parralax[to] = {
            from: from,
            to: to,
            call: function(p) {
              var x;

              x = Math.PI * (p - this.from) / (this.to - this.from);
              return Math.sin(x);
            }
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
        var eff, i, mapKey, now, val, _i, _len, _ref,
          _this = this;

        if (this.stepAnimation === 0) {
          this.$el.stop(true, false);
        }
        this.stepAnimation = 0;
        now = $(window).scrollTop();
        mapKey = null;
        _ref = _.keys(this.parralax);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          val = parseFloat(i);
          if (now > val) {
            continue;
          }
          if (mapKey === null) {
            mapKey = val;
          } else if (mapKey > now && mapKey > val) {
            mapKey = val;
          }
        }
        if (mapKey != null) {
          eff = this.parralax[mapKey].call(now);
          if (Math.abs(eff) < 0.01) {
            eff = 0;
          }
          _.each(this.parralaxItems, function(item) {
            var baseTop, k, marginTop;

            k = eff * parseFloat($(item).data("parralax"));
            baseTop = $(item).data("parralax-top");
            marginTop = baseTop + k;
            return $(item).css("marginTop", "" + marginTop + "px");
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
        var $anchor;

        if (!/^#.+/.test(href)) {
          return;
        }
        $anchor = $(href);
        if ($anchor.length !== 1) {
          return;
        }
        return this.getAnchorPosItem($anchor);
      },
      getAnchorPosItem: function($anchor) {
        var heigth, move, result, top, wHeigth;

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
