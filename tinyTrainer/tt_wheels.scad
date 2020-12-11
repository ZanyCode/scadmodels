battery_tolerance=2;
plane_width = 35;
battery_size = [50, 25, 35];
strength = 1.8;
hook_height = 20;
hole_radius = 1.5;
distance_to_ground=35;

wheel_tolerance=.8;
wheel_radius = 15;
axle_radius = 2;
wheel_frame_width = 20;
wheel_width = 5;

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
    }
}

wheel_segment_height = (distance_to_ground - wheel_radius - wheel_tolerance) / 2;
module wheel() {
    translate([0, wheel_segment_height-wheel_frame_width/2, wheel_segment_height]) cube([wheel_frame_width, wheel_frame_width, strength]);
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

plane_hook();
translate([0, -hook_height/2-case_size[1]/2+strength, 0]) battery_case();
translate([0, -hook_height/2-case_size[1]/2+strength-wheel_segment_height, -case_size[2]/2-wheel_segment_height-strength])
    wheel();
translate([wheel_frame_width, -hook_height/2-case_size[1]/2+strength-wheel_segment_height, case_size[2]/2+wheel_segment_height+strength]) 
    rotate([0, 180, 0]) wheel();


// diff() {
//     cube(battery_size + [strength, strength, strength], true);
//     cube(battery_size)
// }

