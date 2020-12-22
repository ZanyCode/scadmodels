$fa=.1;
$fs=.1;
outer_diameter=71;
inner_diameter=37;
height=60;

difference(){
    union() {
        cylinder(height, outer_diameter/2, outer_diameter/2, center=true);
        translate([0, 0, -height/2+0.45]) cylinder(0.9, outer_diameter, outer_diameter, true);
    }
    cylinder(height, inner_diameter/2, inner_diameter/2, center=true);
}

