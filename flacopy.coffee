class Bird
  constructor: (scene, @fill='red')->
    @acceleration = 1800 
    @thrust = -660
    @x = scene.width * .1
    @y = scene.height * .4
    @height = @width = scene.height / 20
    @ySpeed = @thrust
    @lastTime = 0
    @score = 0

  draw: (ctx)->
    ctx.beginPath()
    ctx.rect @x, @y, @width, @height
    ctx.fillStyle = @fill
    ctx.fill()
    #ctx.font = 'bold 24px'
    context.fillText @score, @x, @y - 2

  advanceFrame: (thisTime)->
    time = (thisTime - @lastTime) / 1000
    bird.ySpeed += @acceleration * time
    bird.y += bird.ySpeed * time
    @lastTime = thisTime

  flap: -> @ySpeed = @thrust

class Scene
  constructor: (canvas)->
    @width = canvas.width
    @horizon = canvas.height * .95
    @xSpeed = 100

    @pipeThickness = 50
    @pipeGap = 200
    # list of coordinates of the top left corner of the gap
    @pipes = [{x: @width, y: 200, cleared: false}]

    @lastTime = 0

  draw: (ctx)->
    for _, topLeft of @pipes
      ctx.fillStyle = 'black'
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

canvas = document.getElementById 'canvas'
context = canvas.getContext '2d'

started = false

scene = new Scene canvas
bird = new Bird canvas

render = ->
  context.clearRect 0, 0, canvas.width, canvas.height
  scene.draw context
  bird.draw context
  window.requestAnimationFrame render

render()

animateFrame = ->
  thisTime = new Date().getTime()
  scene.advanceFrame thisTime
  bird.advanceFrame thisTime
  if bird.y < scene.horizon and not scene.pipeCollision bird
    requestAnimationFrame animateFrame
  else

document.body.addEventListener 'keydown', (e) ->
  if started
    bird.flap()
  else
    started = true
    startTime = new Date().getTime()
    bird.lastTime = startTime
    scene.lastTime = startTime
    animateFrame()
