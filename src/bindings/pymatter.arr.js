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
};
