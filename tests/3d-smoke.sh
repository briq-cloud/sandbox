#!/bin/sh
# All artifacts are produced in a fresh directory, never reused from a previous run.
set -eu
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
cad-python /opt/3d/examples/plate.py
QT_QPA_PLATFORM=offscreen openscad -o part.stl /opt/3d/examples/part.scad
freecad-python /opt/3d/examples/freecad.py
blender -b --factory-startup --disable-autoexec --python-exit-code 1 -t 2 --python /opt/3d/examples/scene.py
freecad-python - <<'PYFC'
import FreeCAD as App
import Part
doc = App.openDocument('freecad.FCStd')
assert doc.getObject('Plate').Shape.isValid()
App.closeDocument(doc.Name)
PYFC
blender -b scene.blend --disable-autoexec --python-exit-code 1 --python-expr 'import bpy; assert any(o.type == "MESH" for o in bpy.context.scene.objects)'
cad-python - <<'PY'
from pathlib import Path
import cadquery as cq
import numpy as np
import trimesh
from PIL import Image
for name in ('plate.step', 'plate.stl', 'part.stl', 'freecad.step', 'freecad.FCStd', 'scene.blend', 'scene.glb', 'scene.png'):
    assert Path(name).stat().st_size > 0, name
for name in ('plate.stl', 'part.stl'):
    mesh = trimesh.load(name, force='mesh')
    assert mesh.is_watertight and mesh.is_volume, name
    assert np.allclose(mesh.extents, [60, 40, 6], atol=0.01), (name, mesh.extents)
for name in ('plate.step', 'freecad.step'):
    solid = cq.importers.importStep(name).val()
    assert solid.isValid(), name
    box = solid.BoundingBox()
    assert np.allclose([box.xlen, box.ylen, box.zlen], [60, 40, 6]), name
image = Image.open('scene.png')
assert image.size == (128, 128)
assert np.asarray(image).std() > 1
assert len(trimesh.load('scene.glb').geometry) > 0
PY
# These commands must fail for a script error, rather than produce false successful jobs.
printf 'raise RuntimeError("expected smoke failure")\n' > failure.py
if blender -b --python-exit-code 1 --python failure.py > /dev/null 2>&1; then
  echo 'Blender swallowed a script failure' >&2; exit 1
fi
if freecad-python -c 'import FreeCAD, Part; raise RuntimeError("expected smoke failure")' > /dev/null 2>&1; then
  echo 'FreeCAD Python swallowed a script failure' >&2; exit 1
fi
echo '3D smoke passed: CAD geometry, mesh exports and CPU render'
