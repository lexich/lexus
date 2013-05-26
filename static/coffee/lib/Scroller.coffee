define ["jQuery","underscore","Backbone"],($, _, Backbone)->

  Scroller = do(
    __super__ = Backbone.View
  )-> __super__.extend
    el:"[data-js-scrollmenu]"
    events:
      "click a":"event_click"
      "click a > *":"event_click_hack"
    delay:null

    initialize:->
      $(window).scroll _.bind(@event_windowScroll,this)
      @autoScroll()


    scroll:(from, to, duration = 2000)->
      return if from == to
      @$el.prop "scroll", from
      @$el.animate {
        scroll:"+=#{to - from}"
      },{
        duration
        step:(now)=>
          window.scrollTo 0, now
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
      return if move < 5
      @scroll from, from + move, 1000

    event_windowScroll:(e)->
      if @delay?
        clearTimeout(@delay)
        @delay = null

      @delay = setTimeout (=>
        @autoScroll()
        @delay = null
      ), 1000

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