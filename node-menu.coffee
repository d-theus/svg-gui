MenuHelpers = {}

MenuHelpers.fadeIn = (dur, timing, delay = 0)->
  setTimeout((->
    this.animate({
      opacity: 1,
      fillOpacity: 1,
      strokeOpacity: 1}, dur, timing)).bind(this)
  , delay)

MenuHelpers.circleSwell = (r, dur, timing, delay = 0)->
  setTimeout((->
    this.animate( { r: r}, dur, timing)).bind(this)
  , delay)

class window.Menu
  constructor: (parent, items, options = {})->

    parent.onclick = ((e)->
      this.open(e.clientX, e.clientY)).bind(this)

    options.nodes ||=  { attrs: {}}
    options.edges ||=  { attrs: {}}
    options.labels ||= { attrs: {}}
    options.animation ||= {}

    options.nodes.attrs.fill ||= 'white'
    options.nodes.attrs.stroke ||= 'black'
    options.nodes.attrs.strokeWidth ||= 2
    options.nodes.radius ||= 10

    options.edges.attrs.fill ||= 'none'
    options.edges.attrs.stroke ||= 'black'
    options.edges.attrs.strokeWidth ||= 2

    options.labels.attrs.fill ||= 'black'

    options.animation.time ||= 75
    options.animation.delay ||= 75
    options.animation.function ||= mina.easein

    @w = items.reduce((max, item)->
      cur = item.label
      r = (cur > max) ? cur : max
      return r
    , 0)
    @h = items.length * 32

    Snap.plugin (Snap, Element, Paper, global, Fragment) ->
      Element.prototype.fadeIn = MenuHelpers.fadeIn
    @s = Snap(@w, @h)
    @s.attr({id: @s.id})
    @s.addClass('menu')

    @options = options
    @items = items
    @origin = {}

  open: (x,y)->
    this.close()
    this.moveSVG(x, y)
    @origin.x = @options.nodes.radius
    @origin.y = @options.nodes.radius

    @items.forEach((v, i)->
      p = @s.path("M#{@origin.x},#{@origin.y}\
      S#{@origin.x},#{this.yoff(i)},#{this.xoff(i)},#{this.yoff(i)}")
      p.attr(@options.edges.attrs)
      p.attr('stroke-opacity', 0)
      p.fadeIn(
        @options.animation.time,
        @options.animation.function,
        @options.animation.delay * i)

      n = @s.circle(this.xoff(i), this.yoff(i), 0)
      n.attr(@options.nodes.attrs)
      MenuHelpers.circleSwell.bind(n)(
        @options.nodes.radius,
        @options.animation.time
        @options.animation.function,
        @options.animation.delay * i + 15)

      l = @s.text(
        this.xoff(i) + 2*@options.nodes.radius,
        this.yoff(i) + 0.5 * @options.nodes.radius,
        v.label)
      l.attr(@options.labels.attrs)
      l.attr('fill-opacity', 0)
      l.fadeIn(
        @options.animation.time,
        @options.animation.function,
        @options.animation.delay * i + 30)
      l.attr('cursor', 'pointer')

      item = @s.g(n,l)
      item.op = @options
      item.hover(()->
        this[0].animate(
          { fill: 'black' },
          item.op.animation.time)
      ,()->
        this[0].animate(
          { fill: item.op.nodes.attrs.fill },
          item.op.animation.time)
      )

      click = if v.url
        (e)->
          e.stopPropagation()
          window.location.href = v.url
      else if v.onclick
        (e)->
          e.stopPropagation()
          v.onclick()
      else
        (e)->
          e.stopPropagation()
      item.click(click)

    , this)
    @s.circle(@origin.x, @origin.y, @options.nodes.radius)

  close: ()->
    @s.paper.clear()

  moveSVG: (x,y)->
    svg = document.getElementById(@s.id)
    svg.style.position = 'absolute'
    svg.style.top = "#{y - @options.nodes.radius}px"
    svg.style.left = "#{x - @options.nodes.radius}px"

  xoff: ()->
    60
  yoff: (n)->
    ((n + 1) / @items.length) * (@h - 2 * @options.nodes.radius)
