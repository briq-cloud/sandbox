// Millimetres; render with: openscad -o part.stl /opt/3d/examples/part.scad
$fn = 64;
difference() {
    cube([60, 40, 6], center=true);
    cylinder(h=8, d=8, center=true);
}
