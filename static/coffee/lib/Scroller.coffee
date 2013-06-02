define ["jQuery","underscore","Backbone"],($, _, Backbone)->
  EPS = 10

  Scroller = do(
    __super__ = Backbone.View
  )-> __super__.extend
    el:"[data-js-scrollmenu]"
    $panel:$()
    events:
      "click a[href^='#']":"event_click"
      "click a[href^='#'] > *":"event_click_hack"
    delay:null
    stepAnimation:0
    parralax:{}
    parralaxItems:$()

    initialize:->
      $(window).scroll _.bind(@event_windowScroll,this)
      $(window).resize _.bind(@event_windowResize, this)
      @$panel = $("[data-js-scrollmenu-panel]", @$el)
      @event_windowResize()
      @autoScroll()

    event_windowResize:->
      @parralax = {}

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
      normHeigth = $(document).height() / (1.0+$links.length)
      _.each $links, (link)=>

        [to, $anchor] = @getAnchorPos $(link).attr("href")
        from = parseInt prev
        to = parseInt to
        @parralax[to] = {
          from, to,
          move: to - from
          call: (p)->
            x = Math.PI * (p - @from) / @move
            (@move/normHeigth)* Math.sin x
        }
        prev = to
      @parralaxItems = $("[data-parralax]")
      _.each @parralaxItems,(item)->
        mTop = parseInt $(item).css("marginTop").replace("px","")
        $(item).data('parralax-top', mTop)
      @autoScroll()

    scroll:(options)->
      from = parseInt options.from
      to = parseInt options.to
      duration = options.duration ? 2000
      $anchor = options.$anchor

      _this = this
      move = to - from
      return if Math.abs(move) < EPS
      @$el.stop true, false
      @$el.prop "scroll", from

      menuFrom = @getMenuCurPos()
      menuTo = @getMenuPosItem(to, $anchor)
      menuMove = menuTo - menuFrom
      @$el.prop "menuMargin", menuFrom


      @$el.animate {
        scroll:"+=#{move}"
        menuMargin: "+=#{menuMove}"
      },{
        duration
        step:(now, tween)=>
          if tween.prop is "scroll"
            _this.stepAnimation += 1
            window.scrollTo 0, now
          else if tween.prop is "menuMargin"
            @$panel.css "marginTop", "#{now}px"
        complete:=>

      }

    autoScroll:->      
      from = from = $(window).scrollTop()
      $anchor = $()
      move = _.reduce @$el.find("a[href^='#']"), ((memo,a)=>
        href = $(a).attr("href")
        [top, $_anchor] = @getAnchorPos href
        return memo unless top?
        delta = top-from
        if Math.abs(delta) < Math.abs(memo)
          $anchor = $_anchor
          delta
        else
          memo
      ), $(document).height()
      unless Math.abs(move) < EPS
        to = from + move
        duration = 1000
        @scroll {from, to, duration, $anchor}
      else
        to = @getAnchorPosItem $anchor
        marginTop = @getMenuPosItem to, $anchor
        @$panel.css "marginTop", "#{marginTop}px"

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
      ), 1000

    getMenuCurPos:->
      marginTop = parseFloat @$panel.css("marginTop").replace("px","")
      marginTop

    getMenuPosItem:(pos, $anchor )->
      top = $anchor.offset().top
      offset = 18
      if top < pos then offset else (top - pos) + offset

    getAnchorPos:(href)->
      return [null, $anchor] unless /^#.+/.test(href)
      $anchor = $(href)
      return [null, $anchor] unless $anchor.length == 1
      pos = @getAnchorPosItem $anchor
      return [pos, $anchor]

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
      [to, $anchor] = @getAnchorPos href
      return unless to?
      @scroll {from, to, $anchor}

  Scroller