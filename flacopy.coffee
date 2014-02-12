class Bird
  constructor: (scene, @fill='#000000')->
    @acceleration = 1800 
    @thrust = -660
    @x = scene.width * .1
    @y = scene.height * .4
    @height = @width = scene.height / 20
    @ySpeed = @thrust
    @lastTime = 0

  draw: (ctx)->
    ctx.beginPath()
    ctx.rect @x, @y, @width, @height
    ctx.fillStyle = @fill
    ctx.fill()

  advanceFrame: (thisTime)->
    time = (thisTime - @lastTime) / 1000
    bird.ySpeed += @acceleration * time
    bird.y += bird.ySpeed * time
    @lastTime = thisTime

class Scene
  constructor: (canvas)->
    @width = canvas.width
    @horizon = canvas.height * .95
    @xSpeed = 100

    @pipeThickness = 50
    @pipeGap = 200
    # list of coordinates of the top left corner of the gap
    @pipes = [{x: @width, y: 200}]

    @lastTime = 0

  draw: (ctx)->
    for _, topLeft of @pipes
      ctx.fillStyle = 'red'
      ctx.beginPath()
      ctx.rect topLeft.x, 0, @pipeThickness, topLeft.y
      ctx.fill()
      ctx.rect topLeft.x, topLeft.y + @pipeGap, @pipeThickness, @horizon
      ctx.fill()

  advanceFrame: (thisTime)->
    for i of @pipes
      @pipes[i].x -= (thisTime - @lastTime) / 1000 * @xSpeed
    if (@width - @pipes[@pipes.length - 1].x) > @pipeThickness * 5.5
      @pipes.push {x: @width, y: (@horizon - @pipeGap) * Math.random()}
    if @pipes[0].x + @pipeThickness < 0
      @pipes.splice(0, 1)
    @lastTime = thisTime

canvas = document.getElementById 'canvas'
context = canvas.getContext '2d'
started = false

scene = new Scene canvas
bird = new Bird canvas

render = ->
  context.clearRect 0, 0, canvas.width, canvas.height
  bird.draw context
  scene.draw context
  window.requestAnimationFrame render

render()

animateFrame = ->
  thisTime = new Date().getTime()
  bird.advanceFrame thisTime
  scene.advanceFrame thisTime
  if bird.y < scene.horizon
    requestAnimationFrame animateFrame

document.body.addEventListener 'keydown', (e) ->
  if started
    bird.ySpeed = bird.thrust
  else
    started = true
    startTime = new Date().getTime()
    bird.lastTime = startTime
    scene.lastTime = startTime
    animateFrame()
