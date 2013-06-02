define(["jQuery", "underscore", "Backbone"], function($, _, Backbone) {
  var EPS, Scroller;

  EPS = 10;
  Scroller = (function(__super__) {
    return __super__.extend({
      el: "[data-js-scrollmenu]",
      $panel: $(),
      events: {
        "click a[href^='#']": "event_click",
        "click a[href^='#'] > *": "event_click_hack"
      },
      delay: null,
      stepAnimation: 0,
      parralax: {},
      parralaxItems: $(),
      initialize: function() {
        $(window).scroll(_.bind(this.event_windowScroll, this));
        $(window).resize(_.bind(this.event_windowResize, this));
        this.$panel = $("[data-js-scrollmenu-panel]", this.$el);
        this.event_windowResize();
        return this.autoScroll();
      },
      event_windowResize: function() {
        var $links, normHeigth, prev,
          _this = this;

        this.parralax = {};
        $links = _.chain($("a[href^='#']", this.$el)).uniq(function(item) {
          return $(item).attr("href");
        }).sortBy(function(item) {
          var href;

          href = $(item).attr("href");
          return $(href).position().top;
        }).value();
        prev = 0;
        normHeigth = $(document).height() / (1.0 + $links.length);
        _.each($links, function(link) {
          var $anchor, from, to, _ref;

          _ref = _this.getAnchorPos($(link).attr("href")), to = _ref[0], $anchor = _ref[1];
          from = parseInt(prev);
          to = parseInt(to);
          _this.parralax[to] = {
            from: from,
            to: to,
            move: to - from,
            call: function(p) {
              var x;

              x = Math.PI * (p - this.from) / this.move;
              return (this.move / normHeigth) * Math.sin(x);
            }
          };
          return prev = to;
        });
        this.parralaxItems = $("[data-parralax]");
        _.each(this.parralaxItems, function(item) {
          var mTop;

          mTop = parseInt($(item).css("marginTop").replace("px", ""));
          return $(item).data('parralax-top', mTop);
        });
        return this.autoScroll();
      },
      scroll: function(options) {
        var $anchor, duration, from, menuFrom, menuMove, menuTo, move, to, _ref,
          _this = this;

        from = parseInt(options.from);
        to = parseInt(options.to);
        duration = (_ref = options.duration) != null ? _ref : 2000;
        $anchor = options.$anchor;
        _this = this;
        move = to - from;
        if (Math.abs(move) < EPS) {
          return;
        }
        this.$el.stop(true, false);
        this.$el.prop("scroll", from);
        menuFrom = this.getMenuCurPos();
        menuTo = this.getMenuPosItem(to, $anchor);
        menuMove = menuTo - menuFrom;
        this.$el.prop("menuMargin", menuFrom);
        return this.$el.animate({
          scroll: "+=" + move,
          menuMargin: "+=" + menuMove
        }, {
          duration: duration,
          step: function(now, tween) {
            if (tween.prop === "scroll") {
              _this.stepAnimation += 1;
              return window.scrollTo(0, now);
            } else if (tween.prop === "menuMargin") {
              return _this.$panel.css("marginTop", "" + now + "px");
            }
          },
          complete: function() {}
        });
      },
      autoScroll: function() {
        var $anchor, duration, from, marginTop, move, to,
          _this = this;

        from = from = $(window).scrollTop();
        $anchor = $();
        move = _.reduce(this.$el.find("a[href^='#']"), (function(memo, a) {
          var $_anchor, delta, href, top, _ref;

          href = $(a).attr("href");
          _ref = _this.getAnchorPos(href), top = _ref[0], $_anchor = _ref[1];
          if (top == null) {
            return memo;
          }
          delta = top - from;
          if (Math.abs(delta) < Math.abs(memo)) {
            $anchor = $_anchor;
            return delta;
          } else {
            return memo;
          }
        }), $(document).height());
        if (!(Math.abs(move) < EPS)) {
          to = from + move;
          duration = 1000;
          return this.scroll({
            from: from,
            to: to,
            duration: duration,
            $anchor: $anchor
          });
        } else {
          to = this.getAnchorPosItem($anchor);
          marginTop = this.getMenuPosItem(to, $anchor);
          return this.$panel.css("marginTop", "" + marginTop + "px");
        }
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
        }), 1000);
      },
      getMenuCurPos: function() {
        var marginTop;

        marginTop = parseFloat(this.$panel.css("marginTop").replace("px", ""));
        return marginTop;
      },
      getMenuPosItem: function(pos, $anchor) {
        var offset, top;

        top = $anchor.offset().top;
        offset = 18;
        if (top < pos) {
          return offset;
        } else {
          return (top - pos) + offset;
        }
      },
      getAnchorPos: function(href) {
        var $anchor, pos;

        if (!/^#.+/.test(href)) {
          return [null, $anchor];
        }
        $anchor = $(href);
        if ($anchor.length !== 1) {
          return [null, $anchor];
        }
        pos = this.getAnchorPosItem($anchor);
        return [pos, $anchor];
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
        var $anchor, from, href, to, _ref;

        href = $link.attr("href");
        from = $(window).scrollTop();
        _ref = this.getAnchorPos(href), to = _ref[0], $anchor = _ref[1];
        if (to == null) {
          return;
        }
        return this.scroll({
          from: from,
          to: to,
          $anchor: $anchor
        });
      }
    });
  })(Backbone.View);
  return Scroller;
});
