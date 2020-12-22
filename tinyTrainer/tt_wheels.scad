include <../lib.scad>

$fn=200;

battery_tolerance=2;
plane_width = 52;
battery_size = [71.2, 22.7, 33.7];
strength = 1.8;
hook_height = 20;
hole_radius = 1.5;
distance_to_ground=35;

wheel_tolerance=.8;
wheel_radius = 15;
axle_radius = 2;
wheel_frame_width = 20;
wheel_width = 5;
wheel_span_width = 30;

latch_hook_width = 10;

hook_size = [battery_size[0]+strength*2, hook_height, plane_width+strength*2];

module plane_hook(){
    difference (){
        cube(hook_size, true);
        translate([0, strength, 0]) cube([hook_size[0], hook_height, plane_width], true);
        translate([0, strength, 0]) cube([hook_size[0]/2, hook_height, hook_size[2]], true);
        translate([hook_size[0] * 0.375, hook_height / 4, 0]) cylinder(hook_size[2], hole_radius, hole_radius, center=true);
        translate([hook_size[0] * -0.375, hook_height / 4, 0]) cylinder(hook_size[2], hole_radius, hole_radius, center=true);
    }
}

case_size = battery_size+[strength*0.5+battery_tolerance*0.5, battery_tolerance+strength, battery_tolerance+strength]*2;
module battery_case() {
    difference() {
        cube(case_size, true);
        translate([strength/2, 0, 0]) cube(battery_size+[battery_tolerance*0.5, battery_tolerance, battery_tolerance]*2, true);
        translate([-case_size[0]/2, -case_size[1]/2, case_size[2]/4]) cube([case_size[0]/4, case_size[1], case_size[2]/4]);
        translate([-case_size[0]/2, -case_size[1]/2, -case_size[2]/2]) cube([case_size[0]/4, case_size[1], case_size[2]/4]);
    }

    translate([case_size[0]/2, -case_size[1]/4, case_size[2]/2-strength]) cube([strength+wheel_tolerance, case_size[1]/2, strength]);
    translate([case_size[0]/2+strength+wheel_tolerance+strength, -case_size[1]/4, case_size[2]/2+strength]) 
        rotate([0, 180, 0]) cube([strength, case_size[1]/2, strength*3]);  

    translate([case_size[0]/2, -case_size[1]/4, -case_size[2]/2]) cube([strength+wheel_tolerance, case_size[1]/2, strength]);
    translate([case_size[0]/2+strength+wheel_tolerance+strength, -case_size[1]/4, -case_size[2]/2+strength]) 
        rotate([0, 180, 0]) cube([strength, case_size[1]/2, strength*2]);
}

wheel_segment_height = (distance_to_ground - wheel_radius - wheel_tolerance) / 2;
module wheel() {
    translate([0, -strength, -wheel_span_width]) cube([wheel_frame_width, strength, wheel_span_width]);
    translate([0, -wheel_segment_height, -wheel_segment_height-wheel_span_width]) {
        rotate([45, 0, 0]) cube([wheel_frame_width, sqrt(wheel_segment_height*wheel_segment_height*2), strength]);    
        translate([0, -wheel_segment_height, 0]) cube([wheel_frame_width, wheel_segment_height, strength]);

        lateral_frame_width = wheel_width+strength*2+wheel_tolerance*2;
        translate([0, -wheel_segment_height, -lateral_frame_width/2+strength/2]) cube([wheel_frame_width, strength, lateral_frame_width]);
        
        wheel_clamp_height = (wheel_radius+wheel_tolerance)*1.5;
        difference() {
            union() {
                translate([0, -wheel_clamp_height-wheel_segment_height, lateral_frame_width/2-strength/2]) cube([wheel_frame_width, wheel_clamp_height, strength]);    
                translate([0, -wheel_clamp_height-wheel_segment_height, -lateral_frame_width/2+strength/2]) cube([wheel_frame_width, wheel_clamp_height, strength]);
            }

            translate([wheel_frame_width/2, -wheel_segment_height-wheel_radius-wheel_tolerance, -lateral_frame_width/2+strength/2])
                cylinder(lateral_frame_width, axle_radius+wheel_tolerance, axle_radius+wheel_tolerance);        
        }

        translate([wheel_frame_width/2, -wheel_segment_height-wheel_radius-wheel_tolerance, -(wheel_width-strength)/2]) 
                cylinder(wheel_width, wheel_radius, wheel_radius);
        
        translate([wheel_frame_width/2, -wheel_segment_height-wheel_radius-wheel_tolerance, -lateral_frame_width/2+strength/2])
                cylinder(lateral_frame_width, axle_radius, axle_radius);  
    }
}

module lid(){
    difference() {
        cube([strength, case_size[1], case_size[2]+strength*2]);
        translate([0, case_size[1]/4-wheel_tolerance, strength*2]) 
            cube([strength, case_size[1]/2+wheel_tolerance*2, strength*2+wheel_tolerance*2]);
         translate([0,0, case_size[2]+strength]) 
            cube([strength, case_size[1], strength]);
          translate([0, 0, case_size[2]-10+strength*2]) 
            cube([strength*2, 5, 10]);
        translate([0, case_size[1]-5, case_size[2]-10+strength*2]) 
            cube([strength*2, 5, 10]);
        
    }    

    translate([strength, 0, 32])
        rotate([0, 90, 0])
        latch(case_size[1], 20, 22, 2, 4.5, lever_angle=90, hook_angle=90, lever_elevation=1, tolerance=0.5);    
}

// plane_hook();
// translate([0, -hook_height/2-case_size[1]/2+strength, 0]) battery_case();
// translate([-case_size[0]/2, -case_size[1]-hook_height/2+strength*2, -case_size[2]/4])
//     wheel();
// translate([-case_size[0]/2+wheel_frame_width, -case_size[1]-hook_height/2+strength*2, case_size[2]/4])
//     rotate([0, 180, 0]) 
//     wheel();
translate([case_size[0]/2 + wheel_tolerance/2, -hook_height/2-case_size[1]+strength, -case_size[2]/2-strength*2]) lid();



// diff() {
//     cube(battery_size + [strength, strength, strength], true);
//     cube(battery_size)
// }

