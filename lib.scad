module latch(width, lever_length, hook_length, inner_axis_radius, hinge_outer_radius, lever_angle=0, hook_angle=0, lever_hinge_distance=3, lever_elevation=3, tolerance=0.3) {
    base_width = width - inner_axis_radius*3 - tolerance*4; 
    base_to_latch_hinge_ratio = 2 / 1;
    echo(hinge_outer_radius);
    base_hinge_width = base_width / base_to_latch_hinge_ratio - tolerance*2;
    latch_hinge_width = (base_width - base_hinge_width) / 2 - tolerance;

    module base() {
        cube([hinge_outer_radius, base_width, lever_elevation]);

        module lever_anchor() {
            difference() {
                union() {           
                translate([hinge_outer_radius, (base_width - base_hinge_width) / 2, hinge_outer_radius]) rotate([-90, 0, 0]) 
                        cylinder(base_hinge_width, hinge_outer_radius, hinge_outer_radius);
                    translate([0,  (base_width - base_hinge_width) / 2, 0])
                        cube([hinge_outer_radius, base_hinge_width, hinge_outer_radius]);      
                };

                translate([hinge_outer_radius, (base_width - base_hinge_width) / 2 - 1, hinge_outer_radius]) rotate([-90, 0, 0]) 
                    cylinder(base_hinge_width+2, inner_axis_radius + tolerance, inner_axis_radius+tolerance);
            }
        }

        translate([0, 0, lever_elevation])
            lever_anchor();
    }

    module lever() {
        rotate([-90, 0, 0]) 
            cylinder(base_width, inner_axis_radius, inner_axis_radius);
        cube([lever_length, latch_hinge_width, inner_axis_radius]);

        translate([0, base_width-latch_hinge_width, 0])    
            cube([lever_length, latch_hinge_width, inner_axis_radius]);
        
        translate([hinge_outer_radius+tolerance, 0, 0])    
            cube([lever_length-hinge_outer_radius-tolerance, base_width, inner_axis_radius]);

        difference () {
            union() {
                translate([lever_hinge_distance, -(inner_axis_radius+tolerance*2), 0])
                    rotate([-90, 0, 0]) 
                    cylinder(base_width + inner_axis_radius*2 + tolerance*4, inner_axis_radius, inner_axis_radius);   

                 translate([lever_hinge_distance, -(inner_axis_radius+tolerance*2+inner_axis_radius/2), 0])
                    rotate([-90, 0, 0]) 
                    cylinder(inner_axis_radius/2, hinge_outer_radius, hinge_outer_radius);   
                
                  translate([lever_hinge_distance, base_width+inner_axis_radius+tolerance*2, 0])
                    rotate([-90, 0, 0]) 
                    cylinder(inner_axis_radius/2, hinge_outer_radius, hinge_outer_radius);   
            }
                
            translate([0, (base_width-(base_hinge_width+tolerance*2))/2, 0])
                rotate([-90, 0, 0]) 
                cylinder(base_hinge_width+tolerance*2, hinge_outer_radius+tolerance, hinge_outer_radius+tolerance);         
        }
    }    

    module hook() {
        module side_cylinder() {            
            rotate([-90, 0, 0])
            cylinder(inner_axis_radius, hinge_outer_radius, hinge_outer_radius);
        }  

        module side_rod() {
             translate([0, 0, -inner_axis_radius/2])
                    cube([hook_length, inner_axis_radius, inner_axis_radius]);
        }

        difference() {
            union() {
                translate([0, 0, 0]){
                    side_cylinder();
                    side_rod();
                }

                translate([0, inner_axis_radius+tolerance*2+base_width, 0]) {
                    side_cylinder();
                    side_rod();
                }
            }

            translate([0, -1, 0])
                rotate([-90, 0, 0])
                cylinder(base_width + inner_axis_radius*2 + tolerance*2 + 2, inner_axis_radius+tolerance, inner_axis_radius+tolerance);
        }

        translate([hook_length-inner_axis_radius, 0, -inner_axis_radius/2])
            cube([inner_axis_radius, base_width+inner_axis_radius*2+tolerance*2, inner_axis_radius]);
    }

    translate([0, inner_axis_radius*1.5+tolerance*2, 0]) {
        base();
        translate([hinge_outer_radius, 0, lever_elevation+hinge_outer_radius]) 
            rotate([0, lever_angle*-1, 0])
                lever();

        hook_origin_x = hinge_outer_radius+cos(lever_angle)*lever_hinge_distance;
        hook_origin_z = hinge_outer_radius+lever_elevation+sin(lever_angle)*lever_hinge_distance;

        translate([hook_origin_x, -(inner_axis_radius+tolerance), hook_origin_z])
            rotate([0, hook_angle*-1, 0])
            hook();
    }   


}

$fs=.1;
$fa=.1;
cube([40, 20, 3.6]);
translate([15, 0, 3.6])
    latch(20, 20, 22, 3, 4.5, lever_angle=0, hook_angle=0, lever_elevation=1, tolerance=0.4);
translate([3.5,5.5,3])
    cube([5, 9, 7]);