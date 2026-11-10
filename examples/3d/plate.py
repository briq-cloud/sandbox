"""cad-python /opt/3d/examples/plate.py: a 60 x 40 x 6 mm plate with an 8 mm hole."""
import cadquery as cq

plate = cq.Workplane("XY").box(60, 40, 6).faces(">Z").workplane().hole(8)
assert plate.val().isValid()
box = plate.val().BoundingBox()
assert all(abs(a - b) < 1e-6 for a, b in zip((box.xlen, box.ylen, box.zlen), (60, 40, 6)))
cq.exporters.export(plate, "plate.step")
cq.exporters.export(plate, "plate.stl")
