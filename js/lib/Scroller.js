define(["jQuery", "underscore", "Backbone"], function($, _, Backbone) {
  var Scroller;

  Scroller = (function(__super__) {
    return __super__.extend({
      el: "[data-js-scrollmenu]",
      events: {
        "click a": "event_click",
        "click a > *": "event_click_hack"
      },
      delay: null,
      initialize: function() {
        $(window).scroll(_.bind(this.event_windowScroll, this));
        return this.autoScroll();
      },
      scroll: function(from, to, duration) {
        var _this = this;

        if (duration == null) {
          duration = 2000;
        }
        if (from === to) {
          return;
        }
        this.$el.stop(true, false);
        this.$el.prop("scroll", from);
        return this.$el.animate({
          scroll: "+=" + (to - from)
        }, {
          duration: duration,
          step: function(now) {
            return window.scrollTo(0, now);
          }
        });
      },
      autoScroll: function() {
        var from, move,
          _this = this;

        from = from = $(window).scrollTop();
        move = _.reduce(this.$el.find("a"), (function(memo, a) {
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
        if (Math.abs(move) < 5) {
          return;
        }
        return this.scroll(from, from + move, 1000);
      },
      event_windowScroll: function(e) {
        var _this = this;

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
        return $anchor.offset().top;
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
