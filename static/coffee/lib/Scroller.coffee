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
    animateScroll:false
    lastScrollTop: 0
    scrollDirection:""

    initialize:->
      @lastScrollTop = $(window).scrollTop()
      $(window).scroll _.bind(@event_windowScroll,this)
      @autoScroll()

    scroll:(from, to, duration = 2000)->
      from = parseInt from
      to = parseInt to
      @scrollDirection = "" #clean scroll direction
      move = to - from
      return if Math.abs(move) < EPS
      @$el.stop true, false
      @$el.prop "scroll", from
      @animateScroll = true
      @$el.animate {
        scroll:"+=#{move}"
      },{
        duration
        step:(now)=>
          window.scrollTo 0, now
        complete:->
          @animateScroll = false
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
      curScrollTop = $(window).scrollTop()
      sDirection = if curScrollTop > @lastScrollTop then "down" else "up"
      @lastScrollTop = curScrollTop
      #if direction change and the last was defined stop previous animation
      if @scrollDirection != "" and sDirection != @scrollDirection
        @$el.stop true, false
      @scrollDirection = sDirection

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