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

fun main-table():
  table-mat = THREE.simple-mesh-basic-mat(12632256)

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
