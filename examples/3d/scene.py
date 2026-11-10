"""blender -b --python-exit-code 1 -t 2 --python /opt/3d/examples/scene.py"""
import math
import bpy

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 1))
material = bpy.data.materials.new("Blue")
material.diffuse_color = (0.08, 0.3, 0.8, 1)
bpy.context.object.data.materials.append(material)
bpy.ops.object.light_add(type="AREA", location=(2, -3, 5))
bpy.context.object.data.energy = 500
bpy.context.object.data.size = 4
bpy.ops.object.camera_add(location=(5, -7, 5))
camera = bpy.context.object
from mathutils import Vector
camera.rotation_euler = (Vector((0, 0, 1)) - camera.location).to_track_quat("-Z", "Y").to_euler()
scene = bpy.context.scene
scene.camera = camera
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 8
scene.render.resolution_x = 128
scene.render.resolution_y = 128
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = "scene.png"
bpy.ops.wm.save_as_mainfile(filepath="scene.blend")
bpy.ops.export_scene.gltf(filepath="scene.glb", export_format="GLB")
bpy.ops.render.render(write_still=True)
