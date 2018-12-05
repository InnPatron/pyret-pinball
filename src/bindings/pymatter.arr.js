var MATTER = require('matter-js');


module.exports = {
  'create-engine': function() {
    return MATTER.Engine.create();
  },

  'create-runner': function() {
    return MATTER.Runner.create();
  },

  'rectangle': function(x, y, width, height, staticBody) {
    return MATTER.Bodies.rectangle(x, y, width, height, { isStatic: staticBody });
  },

  'circle': function(x, y, radius, staticBody) {
    return MATTER.Bodies.circle(x, y, radius, { isStatic: staticBody });
  },

  'set-restitution': function(body, restitution) {
    body.restitution = restitution;
  },

  'add-to-world': function(engine, bodies) {
    MATTER.World.add(engine.world, bodies);
  },

  'run-engine': function(runner, engine) {
    MATTER.Runner.run(runner, engine);
  },

  'start-runner': function(runner) {
    // Equivalent to run-engine()
    MATTER.Runner.start(runner);
  },

  'stop-runner': function(runner) {
    MATTER.Runner.stop(runner);
  },

  'get-pos': function(body) {
    return MATTER.Vector.clone(body.position);
  },

  'get-pos-x': function(body) {
    return body.position.x;
  },

  'get-pos-y': function(body) {
    return body.position.y;
  },

  'set-pos': function(body, x, y) {
    return MATTER.Body.setPosition(body, { x: x, y: y });
  },

  'set-pos-x': function(body, x) {
    return MATTER.Body.setPosition(body, { x: x, y: body.position.y });
  },

  'set-pos-y': function(body, y) {
    return MATTER.Body.setPosition(body, { x: body.position.x, y: y });
  },

  'set-velocity': function(body, x, y) {
    MATTER.Body.setVelocity(body, { x: x, y: y });
  }
};
