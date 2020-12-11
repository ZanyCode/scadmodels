$fn = 20;

hole_distance = 30.35;
base_size = 37.5;
distance_to_edge = (base_size-hole_distance) / 2;
spacer_height=7;
breadboard_height=1.75;
tolerance=0.5;

cube([base_size, base_size, 0.8]);
for (i=[0:1]) {
    for (j=[0:1]){
        translate([
            distance_to_edge + hole_distance*j,
            distance_to_edge + hole_distance*i,0])
            difference() {
                cylinder(spacer_height, 3.5, 3.5);
                cylinder(spacer_height, 2, 2);
            }
    }
}

module breadboard_clamp(){
    difference() {
        cube([8, 8, spacer_height+breadboard_height+tolerance+1.8]);
        translate([2, 2, spacer_height]) cube([6, 6, breadboard_height+tolerance]);
    }    
}

translate([-2, -2, 0]) breadboard_clamp();
translate([base_size+2, -2, 0]) rotate([0, 0, 90]) breadboard_clamp();

