canvas = document.getElementById 'canvas'
context = canvas.getContext '2d'
reqAnim = window.requestAnimationFrame;
env =
  horizon: 500
  acceleration: 100 
velocity = 0
hero =
  'x': 50
  'y': 50
  'width': 50
  'height': 50
  'fill': '#000000'
render = ->
  context.clearRect 0, 0, canvas.width, canvas.height
  context.beginPath()
  context.rect hero.x, hero.y, hero.width, hero.height
  context.fillStyle = hero.fill
  context.fill()
  reqAnim(render);
render()

beginTime = lastTime = new Date().getTime()
animStep = ->
  thisTime = new Date().getTime()
  time = (thisTime - lastTime) / 1000
  velocity += env.acceleration * time
  hero.y += velocity * time
  lastTime = thisTime
  if hero.y < env.horizon
    requestAnimationFrame animStep

animStep()
setTimeout((->
  velocity = -200), 500)
