require [
  "jQuery"
  "Backbone"
  "underscore"
  "lib/jquery.scrollpage"
],($, Backbone, _)->

  getRotationDegrees = (obj) ->
    matrix = obj.css("-webkit-transform") or obj.css("-moz-transform") or obj.css("-ms-transform") or obj.css("-o-transform") or obj.css("transform")
    if matrix isnt "none"
      values = matrix.split("(")[1].split(")")[0].split(",")
      a = values[0]
      b = values[1]
      angle = Math.round(Math.atan2(b, a) * (180 / Math.PI))
    else
      angle = 0
    (if (angle < 0) then angle += 360 else angle)

  Preloader = do(
    __super__ = Backbone.View
  )-> __super__.extend
    el:"[data-js-preloader]:first"
    render:->
      $original = @$el.find "[data-js-preloader-original]"
      $shadow = @$el.find "[data-js-preloader-shadow]"

      return if $shadow.length <= 0 or $original.length <= 0
      $shadow.animate {
        left:"+=#{$original.width()}"
      }, {
        duration: 2000
        complete: =>
          $shadow.parent("[data-js-preloader]").fadeOut(400)
          @options?.next()
      }
      __super__::render.apply this, arguments

  Car = do(
    __super__ = Backbone.View
  )-> __super__.extend
    el:"[data-js-car]"
    movement:500
    duration: 4000

    isVisible:->
      wTop = $(window).scrollTop()
      wBottom = wTop + $(window).height()
      top = @$el.position().top
      bottom = top + @$el.height()
      (wTop <= top and top <= wBottom) or (wTop <= bottom and bottom <= wBottom)

    initialize:->
      @movement = @options.movement ? @movement
      @duration = @options.duration ? @duration

    render:->
      if @isVisible()
        $wheels = $("[data-js-car-wheel]", @$el)

        prevMove = 0
        @$el.animate {
          left:"+=#{@movement}"
        },{
          duration: @duration
          step:(now, tween)->
            move = tween.start - tween.now
            delta = move - prevMove
            prevMove = move

            _.each $wheels, (wheel)->
              $wheel = $(wheel)
              r = $wheel.height()/2
              L = (2*Math.PI*r)
              deltaDeg = -delta * 360 / L
              curDeg = getRotationDegrees $wheel
              deg = deltaDeg + curDeg
              degRotate = "rotate(#{deg.toFixed(2)}deg)"
              $wheel.css "transform", degRotate
          complete:=>
            @movement = -@movement
            @render()
        }
      else
        setTimeout (=> @render()), 1000


  $(document).ready ->
    $("[data-js-scrollmenu] a").scrollPage()
    $("[data-js-audio-change]").click (e)->
      e.preventDefault()
      $item = $(e.target)

      src = $item.attr("src")
      change = $item.data("js-audio-change")
      $item.attr("src", change)
      $item.data("js-audio-change", src)

    preloader = (new Preloader
      next:->
    ).render()

    $car = $("[data-js-car]:first")
    data = $car.data("js-car") ? {}
    car = (new Car
      el:$car
      movement:data.movement
      duration:data.duration
    ).render()


