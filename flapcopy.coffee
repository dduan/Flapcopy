class Bird
  constructor: (scene, @highest=0, @fill='red')->
    @acceleration = 3 * scene.height 
    @thrust = -(1.1 * scene.height)
    @x = scene.width * .1
    @y = scene.height * .4
    @height = @width =  Math.min(scene.width, scene.height) / 20
    @ySpeed = @thrust
    @lastTime = 0
    @score = 0

  draw: (ctx)->
    ctx.beginPath()
    ctx.rect @x, @y, @width, @height
    ctx.fillStyle = @fill
    ctx.fill()
    ctx.fillText "#{@score}/#{@highest}", @x, @y - 2

  advanceFrame: (thisTime)->
    time = (thisTime - @lastTime) / 1000
    @ySpeed += @acceleration * time
    @y += @ySpeed * time
    @lastTime = thisTime

  flap: -> @ySpeed = @thrust

class Scene
  constructor: (canvas)->
    @width = canvas.width
    @horizon = canvas.height * .95
    @xSpeed = canvas.width * 0.1584

    @pipeThickness = canvas.width * .0651
    @pipeGap = canvas.height * .3
    # list of coordinates of the top left corner of the gap
    @pipes = [{x: @width, y: 200, cleared: false}]

    @lastTime = 0

  draw: (ctx)->
    for _, topLeft of @pipes
      ctx.fillStyle = 'grey'
      ctx.beginPath()
      ctx.rect topLeft.x, 0, @pipeThickness, topLeft.y
      ctx.fill()
      ctx.rect topLeft.x, topLeft.y + @pipeGap, @pipeThickness, @horizon
      ctx.fill()

  advanceFrame: (thisTime)->
    for i of @pipes
      @pipes[i].x -= (thisTime - @lastTime) / 1000 * @xSpeed
    if (@width - @pipes[@pipes.length - 1].x) > @pipeThickness * 5.5
      @pipes.push {x: @width, y: (@horizon - @pipeGap) * Math.random(), cleared: false}
    if @pipes[0].x + @pipeThickness < 0
      @pipes.splice(0, 1)
    @lastTime = thisTime

  pipeCollision: (box)->
    for i, pipe of @pipes
      boxMaxX = box.x + box.width
      boxMaxY = box.y + box.height
      pipeMaxX = pipe.x + @pipeThickness
      clearsLeft = boxMaxX > pipe.x and box.x < pipe.x
      if clearsLeft and not pipe.cleared
        @pipes[i].cleared = true
        box.score += 1
      if (box.y < pipe.y or boxMaxY > pipe.y + @pipeGap) and (clearsLeft or box.x < pipeMaxX and boxMaxX > pipeMaxX or box.x > pipe.x and boxMaxX < pipeMaxX)
        return true
      if pipe.x > boxMaxX
        return false

class Game
  constructor: (canvasId)->
    @highest = 0
    @canvas = document.getElementById canvasId
    if window.innerWidth < 768
      @canvas.width = window.innerWidth
      @canvas.height = window.innerHeight
    @context = canvas.getContext '2d'
    @reset()
  reset: ->
    @started = false
    @over = false
    @scene = new Scene @canvas
    @bird = new Bird @canvas, @highest
    @render()
  render: =>
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    @scene.draw @context
    @bird.draw @context
    @context.fillStyle = 'white'
    if not @started
      @say 'Press any key to start.'
    if @over
      @say 'Press any key to restart.'
    window.requestAnimationFrame @render
  animateFrame: =>
    thisTime = new Date().getTime()
    @scene.advanceFrame thisTime
    @bird.advanceFrame thisTime
    if @bird.y < @scene.horizon and not @scene.pipeCollision @bird
      requestAnimationFrame @animateFrame
    else
      @highest = @bird.score if @bird.score > @highest
      @over = true
  start: ->
    @started = true
    startTime = new Date().getTime()
    @bird.lastTime = startTime
    @scene.lastTime = startTime
    @animateFrame()
  say: (message, color)->
    @context.fillStyle = color
    @context.fillText message, 2, 10

changeState = (e)->
  e.preventDefault()
  if game.started and not game.over
    game.bird.flap()
  else if game.over
    game.reset()
  else
    game.start()

game = new Game 'canvas'

document.body.addEventListener 'keydown', changeState
document.body.addEventListener 'touchstart', changeState
