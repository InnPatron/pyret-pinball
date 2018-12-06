import list as L

import js-file("bindings/pythree") as THREE
import js-file("bindings/pymatter") as MATTER
import js-file("ecs/component-store") as CS
import js-file("ecs/uuid") as U
import js-file("animate") as A

# Constants
ball-radius = 15
sphere-segments = 15

main-table-vertical-width = 20
main-table-vertical-height = 800
main-table-vertical-x = 300
main-table-vertical-y = 0

main-table-horizontal-width = 2 * main-table-vertical-x
main-table-horizontal-height = main-table-vertical-width
main-table-horizontal-x = 0
main-table-horizontal-y = main-table-vertical-height / 2

separator-width = 16
separator-height = main-table-vertical-height * (4 / 5)
separator-x = main-table-vertical-x - 50
separator-y = main-table-vertical-y - (main-table-vertical-height  * (1 / 10))

table-depth = 1

launch-speed = 35

bumper-radius = 20
bumper-bounce = 8 / 5
bumper-buffer = 20
bumper-space = (main-table-horizontal-width - separator-x - separator-width)  / 3

bumper-color = 1671168
bumper-y = 250

# World init
scene = THREE.scene()
camera = THREE.perspective-camera-default()
renderer = THREE.web-gl-renderer-default()

THREE.set-pos-z(camera, 600)

engine = MATTER.create-engine()
runner = MATTER.create-runner()

# Constructor functions
fun ball():
  ball-collider = MATTER.circle(0, 0, ball-radius, false)
  ball-geom = THREE.sphere-geom(ball-radius, sphere-segments, sphere-segments)
  ball-mat = THREE.simple-mesh-basic-mat(33023)

  ball-vis = THREE.mesh(ball-geom, ball-mat)

  block: 
    THREE.scene-add(scene, ball-vis)
    MATTER.add-to-world(engine, [L.list: ball-collider])

    { 
      vis: ball-vis,
      col: ball-collider 
    }
  end
end

fun launch-ball(shadow ball):
  collider = ball.col
  launch-x = main-table-vertical-x - (main-table-vertical-width / 2) - ball-radius
  launch-y = main-table-horizontal-y - (main-table-horizontal-height) - ball-radius

  block: 
    MATTER.set-pos(collider, launch-x, launch-y)
    MATTER.set-velocity(collider, 0, 0 - launch-speed)
  end
end

fun bouncer(table-mat):

  bouncer-shift = 10
  bouncer-width = 15
  bouncer-height = 50
  
  radians = THREE.deg-to-rad(30)

  bouncer-collider = MATTER.rectangle(0, 0, bouncer-width, bouncer-height, true)

  bouncer-geom = THREE.box-geom(bouncer-width, bouncer-height, table-depth)
  bouncer-vis = THREE.mesh(bouncer-geom, table-mat)

  block: 
    THREE.set-pos(
      bouncer-vis, 
      (main-table-vertical-x - bouncer-width) + bouncer-shift, 
      (main-table-vertical-height / 2) - (bouncer-height / 2),
      0
    )
    THREE.set-rot-z(bouncer-vis, radians)

    MATTER.set-pos(
      bouncer-collider, 
      (main-table-vertical-x - bouncer-width) + bouncer-shift,
      0 - ((main-table-vertical-height / 2) - (bouncer-height / 2))
    ) 
    MATTER.set-angle(bouncer-collider, 0 - radians)

    THREE.scene-add(scene, bouncer-vis)
    MATTER.add-to-world(engine, [L.list: bouncer-collider])
  end
end

fun bumper(x, y, bumper-mat):

  collider = MATTER.circle(x, 0 - y, bumper-radius, true)
  bumper-geom = THREE.sphere-geom(bumper-radius, sphere-segments, sphere-segments)

  bumper-vis = THREE.mesh(bumper-geom, bumper-mat)

  block: 
    THREE.set-pos-x(bumper-vis, x)
    THREE.set-pos-y(bumper-vis, y)

    MATTER.set-restitution(collider, bumper-bounce)

    THREE.scene-add(scene, bumper-vis)
    MATTER.add-to-world(engine, [L.list: collider])
  end
end

fun funnels(table-mat):
  radians = THREE.deg-to-rad(90)

  funnel-length = 120

  left-collider = MATTER.trapezoid(
    (0 - main-table-vertical-x) + (funnel-length / 2), 
    0,
    funnel-length,
    funnel-length,
    1 / 2,
    true
  )

  right-collider = MATTER.trapezoid(
    separator-x - (funnel-length / 2), 
    0,
    funnel-length,
    funnel-length,
    1 / 2,
    true
  )

  block: 

    funnel-shape = THREE.shape()
    THREE.shape-move-to(funnel-shape, 0 - (funnel-length / 2), 0 - (funnel-length / 2))
    THREE.shape-line-to(funnel-shape, funnel-length / 2, 0 - (funnel-length / 2))
    THREE.shape-line-to(funnel-shape, 3 * (funnel-length / 4), funnel-length / 2)
    THREE.shape-line-to(funnel-shape, 0 - (3 * (funnel-length / 4)), funnel-length / 2)
    THREE.shape-line-to(funnel-shape, 0 - (funnel-length / 2), 0 - (funnel-length / 2))

    funnel-geom = THREE.shape-geom(funnel-shape)

    left-vis = THREE.mesh(funnel-geom, table-mat)
    right-vis = THREE.mesh(funnel-geom, table-mat)
    
    THREE.set-pos(left-vis, (0 - main-table-vertical-x) + (funnel-length / 2), 0, 0)
    THREE.set-pos(right-vis, separator-x - (funnel-length / 2), 0, 0)

    THREE.set-rot-z(left-vis, radians)
    THREE.set-rot-z(right-vis, 0 - radians)

    MATTER.set-restitution(left-collider, 111 / 110)
    MATTER.set-restitution(right-collider, 111 / 110)
    MATTER.set-angle(left-collider, radians)
    MATTER.set-angle(right-collider, 0 - radians)

    MATTER.add-to-world(engine, [L.list: left-collider, right-collider])

    THREE.scene-add(scene, left-vis)
    THREE.scene-add(scene, right-vis)

  end
end

fun main-table():
  table-mat = THREE.simple-mesh-basic-mat(12632256)
  bumper-mat = THREE.simple-mesh-basic-mat(bumper-color)

  left-collider = 
    MATTER.rectangle(
      0 - main-table-vertical-x, 
      main-table-vertical-y,
      main-table-vertical-width,
      main-table-vertical-height,
      true
    )

  right-collider = 
    MATTER.rectangle(
      main-table-vertical-x, 
      main-table-vertical-y,
      main-table-vertical-width,
      main-table-vertical-height,
      true
    )

  bottom-collider = 
    MATTER.rectangle(
      main-table-horizontal-x, 
      main-table-horizontal-y,    # Positive coordinates go down visually
      main-table-horizontal-width,
      main-table-horizontal-height,
      true
    )

  top-collider = 
    MATTER.rectangle(
      main-table-horizontal-x, 
      0 - main-table-horizontal-y,    # Positive coordinates go down visually
      main-table-horizontal-width,
      main-table-horizontal-height,
      true
    )

  vertical-geom = 
    THREE.box-geom(
      main-table-vertical-width,
      main-table-vertical-height,
      table-depth
    )

  horizontal-geom = 
    THREE.box-geom(
      main-table-horizontal-width,
      main-table-horizontal-height,
      table-depth
    )

  separator-geom =
    THREE.box-geom(
      separator-width,
      separator-height,
      table-depth
    )

  separator-collider = 
    MATTER.rectangle(
      separator-x,
      0 - separator-y,
      separator-width,
      separator-height,
      true)
  
  left-vis = THREE.mesh(vertical-geom, table-mat)
  right-vis = THREE.mesh(vertical-geom, table-mat)

  top-vis = THREE.mesh(horizontal-geom, table-mat)
  bottom-vis = THREE.mesh(horizontal-geom, table-mat)

  separator-vis = THREE.mesh(separator-geom, table-mat)

  collider-list = [L.list:
    left-collider,
    right-collider,
    top-collider,
    bottom-collider,
    separator-collider
  ]

  block:
    THREE.set-pos-x(left-vis, 0 - main-table-vertical-x)
    THREE.set-pos-x(right-vis, main-table-vertical-x)
    THREE.scene-add(scene, left-vis)
    THREE.scene-add(scene, right-vis)

    THREE.set-pos-y(top-vis, main-table-horizontal-y)
    THREE.set-pos-y(bottom-vis, 0 - main-table-horizontal-y)
    THREE.scene-add(scene, top-vis)
    THREE.scene-add(scene, bottom-vis)

    THREE.set-pos-x(separator-vis, separator-x)
    THREE.set-pos-y(separator-vis, separator-y)
    THREE.scene-add(scene, separator-vis)

    MATTER.add-to-world(engine, collider-list)

    bouncer(table-mat)

    bumper(0, bumper-y, bumper-mat)
    bumper(bumper-space, bumper-y, bumper-mat)
    bumper(0 - bumper-space, bumper-y, bumper-mat)

    funnels(table-mat)

    nothing
  end
end

shadow ball = ball()
main-table()

context = {
  to-update: [L.list: ball]
}

animator = lam(shadow context):
  block:

    for L.map(u from context.to-update):

      block:
        new-pos = MATTER.get-pos(u.col)
        THREE.set-pos-x(u.vis, new-pos.x)
        THREE.set-pos-y(u.vis, 0 - new-pos.y)

        u
      end

    end

  end

end

launch-ball(ball)

MATTER.run-engine(runner, engine)

A.animate(renderer, scene, camera, animator, context)
