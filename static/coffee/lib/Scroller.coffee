define ["jQuery","underscore","Backbone"],($, _, Backbone)->
  EPS = 10
  Scroller = do(
    __super__ = Backbone.View
  )-> __super__.extend
    el:"[data-js-scrollmenu]"
    events:
      "click a":"event_click"
      "click a > *":"event_click_hack"
    delay:null
    stepAnimation:0

    initialize:->
      $(window).scroll _.bind(@event_windowScroll,this)
      @autoScroll()

    scroll:(from, to, duration = 2000)->
      from = parseInt from
      to = parseInt to
      _this = this
      move = to - from
      return if Math.abs(move) < EPS
      @$el.stop true, false
      @$el.prop "scroll", from

      @$el.animate {
        scroll:"+=#{move}"
      },{
        duration
        step:(now)=>
          _this.stepAnimation += 1
          window.scrollTo 0, now
        complete:->

      }

    autoScroll:->      
      from = from = $(window).scrollTop()
      move = _.reduce @$el.find("a"), ((memo,a)=>
        href = $(a).attr("href")
        top = @getAnchorPos href
        return memo unless top?
        delta = top-from
        if Math.abs(delta) < Math.abs(memo) then delta else memo
      ), $(document).height()
      return if Math.abs(move) < EPS
      @scroll from, from + move, 1000

    event_windowScroll:(e)->

      if @stepAnimation == 0
        @$el.stop true, false
      @stepAnimation = 0

      if @delay?
        clearTimeout(@delay)
        @delay = null
      @delay = setTimeout (=>
        @autoScroll()
        @delay = null
      ), 500

    getAnchorPos:(href)->
      return unless /^#.+/.test(href)
      $anchor = $(href)
      return unless $anchor.length == 1
      $anchor.offset().top

    event_click_hack:(e)->
      @click_link $(e.target).parent("a")

    event_click:(e)->
      e.preventDefault()
      @click_link $(e.target)

    click_link:($link)->
      href = $link.attr("href")
      from = $(window).scrollTop()
      to = @getAnchorPos href
      return unless to?
      @scroll(from, to)

  Scroller