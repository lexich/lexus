define ["jQuery","underscore","Backbone"],($, _, Backbone)->
  EPS = 10

  Scroller = do(
    __super__ = Backbone.View
  )-> __super__.extend
    el:"[data-js-scrollmenu]"
    events:
      "click a[href^='#']":"event_click"
      "click a[href^='#'] > *":"event_click_hack"
    delay:null
    stepAnimation:0
    parralax:{}
    parralaxItems:$()

    initialize:->
      $(window).scroll _.bind(@event_windowScroll,this)
      @autoScroll()

      $links = _.chain(
        $("a[href^='#']", @$el)
      ).uniq(
        (item)-> $(item).attr("href")
      ).sortBy(
        (item)->
          href = $(item).attr("href")
          $(href).position().top
      ).value()
      prev = 0
      _.each $links, (link)=>
        to = @getAnchorPos $(link).attr("href")
        from = parseInt prev
        to = parseInt to
        @parralax[to] = {
          from, to
          call: (p)->
            x = Math.PI * (p - @from) / (@to-@from)
            Math.sin x
        }
        prev = to
      @parralaxItems = $("[data-parralax]")
      _.each @parralaxItems,(item)->
        mTop = parseInt $(item).css("marginTop").replace("px","")
        $(item).data('parralax-top', mTop)


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
      move = _.reduce @$el.find("a[href^='#']"), ((memo,a)=>
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

      now = $(window).scrollTop()
      mapKey = null
      for i in _.keys(@parralax)
        val = parseFloat i
        if now > val then continue
        if mapKey is null
          mapKey = val
        else if mapKey > now and mapKey > val
          mapKey = val

      if mapKey?
        eff = @parralax[mapKey].call(now)
        if Math.abs(eff) < 0.01 then eff = 0
        _.each @parralaxItems, (item)->
          k = eff * parseFloat $(item).data("parralax")
          baseTop = $(item).data("parralax-top")
          marginTop = baseTop + k
          $(item).css "marginTop", "#{marginTop}px"

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
      @getAnchorPosItem $anchor

    getAnchorPosItem:($anchor)->
      top = $anchor.offset().top
      wHeigth = $(window).height()
      heigth = $anchor.height()
      move = (wHeigth-heigth)/2

      if move > 0
        result = top - move
        result = 0 if result < 0
        result
      else
        top


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