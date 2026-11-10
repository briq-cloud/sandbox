"""/usr/bin/python3 /opt/3d/examples/freecad.py: headless native CAD and STEP."""
import sys

# Ubuntu's FreeCAD extension is built for the distro Python, not the uv interpreter.
sys.path.append("/usr/lib/freecad-python3/lib")
import FreeCAD as App
import Part

try:
    doc = App.newDocument("Plate")
    shape = Part.makeBox(60, 40, 6).cut(Part.makeCylinder(4, 6, App.Vector(30, 20, 0)))
    if not shape.isValid() or len(shape.Solids) != 1:
        raise RuntimeError("invalid solid")
    obj = doc.addObject("PartDesign::Feature", "Plate")
    obj.Shape = shape
    doc.recompute()
    Part.export([obj], "freecad.step")
    doc.saveAs("freecad.FCStd")
    App.closeDocument(doc.Name)
except Exception:
    # Let Python set a nonzero exit code; FreeCADCmd can swallow macro exceptions.
    raise
