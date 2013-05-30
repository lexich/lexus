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

      result = []
      _.each $("a[href^='#']", @$el), (item)->
        href = $(item).attr("href")
        if $(href).length == 1
          result.push $(href).position().top
      _.sortBy result, (x)-> x
      prev = 0
      _.each result, (to)=>
        from = prev
        @parralax[to] = (p)-> (from-p)*Math.PI / (from-to)
        prev = to
      @parralaxItems = $("[data-parralax]")
      _.each @parralaxItems,(item)->
        mTop = parseInt $(item).css("marginTop").replace("px","")
        $(item).data('parralax-top', mTop)


    scroll:(from, to, duration = 10000)->
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

      for i in _.keys(@parralax)
        if now < i
          mapKey = i

      if mapKey?
        eff = @parralax[mapKey](now)
        if Math.abs(eff) < 0.000001 then eff = 0
        _.each @parralaxItems, (item)->
          k = eff * parseFloat $(item).data("parralax")
          mTop = $(item).data("parralax-top")
          $(item).css "marginTop", "#{k*eff + mTop}px"


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