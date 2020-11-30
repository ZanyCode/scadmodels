include <helper.scad>

// General config
$fa=0.1;
$fs=0.1;
$tolerance = .2; // Specifies, how much space there should be left between parts.

// Common plate parameters
$base_strength = 1.8;
$screw_hole_diameter = 3.3;
$base_size = [80, 110, $base_strength];
$base_distance = 50; // Spacing between top/bottom base plates
$outer_size = [160, 160];    
         
// Arm Parameters
$arm_strength = 3;
$arm_hole_inner_edge_distance = 5;
$arm_hole_outer_edge_distance = 5;

// Motor Mount
$motor_hole_distance1 = 12.5;
$motor_hole_distance2 = 16.5;
$motor_center_hole_diameter = 6;
$motor_diameter = 24;
$motor_screw_hole_diameter=2.9;
$motor_mount_rotation=45; // rotation of mounted motor in degrees, useful for aligning cable

/****Module Definitions***/
module base_plate(fillet_width, fillet_angle_deg) {    
    dx = $base_size[0];
    dy = $base_size[1];
    dz = $base_size[2];
    a = fillet_angle_deg;
    
    module fillet_triangle() {
        intersection_a = [0, sin(fillet_angle_deg) * fillet_width];
        intersection_b = [cos(fillet_angle_deg) * fillet_width, 0];                      
        midpoint = (intersection_a + intersection_b) / 2;        
        intersection_vector = intersection_a - midpoint;
        intersection_orthogonal = [intersection_vector[1], -intersection_vector[0]];
        intersection_orthogonal_norm = intersection_orthogonal / norm(intersection_orthogonal);
        hole_distance = $arm_hole_inner_edge_distance + $screw_hole_diameter / 2;
                
        translate(intersection_orthogonal_norm * hole_distance + midpoint)
            cylinder(dz+2, $screw_hole_diameter / 2, $screw_hole_diameter / 2);        
        
        linear_extrude(height=dz + 2) // +1 to prevent flickering due to rounding errors
            polygon(points=[[-1, -1], intersection_a, intersection_b]);  
    }    
    
    difference() {        
        cube($base_size);    
        translate([dx, dy, -1]) rotate ([0,0,180]) fillet_triangle();
        translate([0, dy, -1]) mirror([1,0,0]) rotate ([0,0,180]) fillet_triangle();
        translate([0, 0, - 1]) fillet_triangle();
        translate([dx, 0, -1]) mirror([0,1,0]) rotate([0,0,180]) fillet_triangle();            
    }
   
}

module top_plate(fillet_width, fillet_angle_deg) {
    base_plate(fillet_width, fillet_angle_deg);
}


module bot_plate(fillet_width, fillet_angle_deg) {
    base_plate(fillet_width, fillet_angle_deg);
}

module arm() {
    plate_start = $arm_hole_inner_edge_distance + $screw_hole_diameter + $arm_hole_outer_edge_distance;      

    function getLength() = norm(
            // Midpoint of line where arm docks to plate
            ([cos(arm_angle)*$motor_diameter, 0, 0] + [0, sin(arm_angle)*$motor_diameter, 0]) / 2 + 
            // Shift of arm towards plate
            translation_vector(90 - arm_angle, plate_start) -
            // shift coordinate system such that origin is at outer diameter point
            ($base_size - $outer_size) / 2
    );

    function getScrewHolePosition() = 
            [$motor_diameter / 2, $arm_hole_outer_edge_distance + $screw_hole_diameter / 2, 0]; 
    
    module clamp(length) {
        cube([$motor_diameter, length, $arm_strength]);            
        translate([0, plate_start + $tolerance, -$base_size[2] - $tolerance]) 
            cube([$motor_diameter, $arm_strength, $base_size[2] + $tolerance]);
        translate([0, 0, -$base_size[2] - $tolerance - $arm_strength])
            cube([$motor_diameter, length, $arm_strength]);            
    }

    module wall(clamp_length, arm_length) {
        height = $base_distance + $base_size[2]*2 + $tolerance + $arm_strength;
        mirror([1, 0, 1])
        translate([0, 0, -$arm_strength])
        linear_extrude(height=$arm_strength) // +1 to prevent flickering due to rounding errors
            polygon(points=[[0, clamp_length], [0, clamp_length + arm_length / 2], [height, clamp_length]]);  
        
        color("green")
        translate([0, 0, -$base_size[2]-$base_distance+$arm_strength]) 
            cube([$arm_strength, clamp_length, $base_distance - $tolerance-$arm_strength*2]);
    }

    module motor_mount() {        
        difference() {
            union() {
                cylinder(r=$motor_diameter/2, h=$arm_strength, center=false);
                translate([-$motor_diameter/2,-$motor_diameter/2,0])
                    cube([$motor_diameter, $motor_diameter/2, $arm_strength]);
            }

            rotate([0,0,$motor_mount_rotation]) {
                translate([0,0,-1])
                    cylinder(r=$motor_center_hole_diameter/2, h=$arm_strength+2);
                translate([0, -$motor_hole_distance1/2, -1])
                    cylinder(r=$motor_screw_hole_diameter/2, h=$arm_strength+2);
                translate([0, $motor_hole_distance1/2, -1])
                    cylinder(r=$motor_screw_hole_diameter/2, h=$arm_strength+2);
                translate([-$motor_hole_distance2/2, 0, -1])
                    cylinder(r=$motor_screw_hole_diameter/2, h=$arm_strength+2);
                translate([$motor_hole_distance2/2, 0, -1])
                    cylinder(r=$motor_screw_hole_diameter/2, h=$arm_strength+2);
            }
        }
    }

    arm_length = getLength();    
    echo("Total arm length");
    echo(arm_length + $motor_diameter / 2);
    screw_hole = getScrewHolePosition();
    clamp_length = plate_start + $tolerance + $arm_strength;
    total_height = $tolerance+$base_size[2]*2+$base_distance+$arm_strength*2;
    
    difference() {
        union() {
            clamp(clamp_length);    
            translate([0, 0, -$base_distance - $base_strength])
                clamp(clamp_length);
            translate([0, clamp_length, 0])
                cube([$motor_diameter, arm_length-clamp_length-$motor_diameter/2, $arm_strength]);     
            wall(clamp_length, arm_length);
            translate([$motor_diameter/2, arm_length, 0])                
                motor_mount();
        }
        translate(screw_hole + [0, 0, -total_height+$arm_strength-1]) cylinder(r=$screw_hole_diameter / 2, h=total_height+2, center=false);
    } 


}

arm_angle = calculateArmAngle($base_size, $outer_size, $motor_diameter, 0.001);
t_arm_inward = $arm_hole_inner_edge_distance + $screw_hole_diameter + $arm_hole_outer_edge_distance;
t_arm_upward = $base_size[2] + $tolerance / 2;

// Move origin from base plate to arm
translate(($outer_size-$base_size) / 2) {
    /***Objects****/
    color("green") top_plate($motor_diameter, arm_angle);
    color("red") translate([0, 0, -$base_distance - $base_strength]) bot_plate($motor_diameter, arm_angle);

    // Base Plates
    translate([($base_size[0] - $outer_size[0])/ 2, ($base_size[1] - $outer_size[1]) / 2,-$base_distance-20]) %cube([$outer_size[0], $outer_size[1], 5]);

    translate([cos(arm_angle)*$motor_diameter, 0, t_arm_upward] + translation_vector(90-arm_angle, t_arm_inward))
    rotate([0, 0, 180-arm_angle])
    arm();

    translate([$base_size[0], sin(arm_angle)*$motor_diameter, t_arm_upward] + translation_vector(90+arm_angle, t_arm_inward))
    rotate([0, 0, 180+arm_angle])
    arm();

    translate([$base_size[0] - cos(arm_angle)*$motor_diameter, $base_size[1], t_arm_upward] - translation_vector(90 - arm_angle, t_arm_inward))
    rotate([0, 0, -arm_angle])
    arm();

    translate([0, $base_size[1] - sin(arm_angle)*$motor_diameter, t_arm_upward] - translation_vector(90+arm_angle, t_arm_inward))
    rotate([0, 0, arm_angle])
    arm();
}
