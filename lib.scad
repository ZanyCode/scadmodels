module latch(width, lever_length, hook_length, strength, lever_angle=0, hook_angle=0, lever_hinge_distance=3, lever_elevation=3, tolerance=0.3) {
    base_width = width - strength*3 - tolerance*4; 
    base_to_latch_hinge_ratio = 2 / 1;
    hinge_outer_radius = strength*1.5;
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
                    cylinder(base_hinge_width+2, strength + tolerance, strength+tolerance);
            }
        }

        translate([0, 0, lever_elevation])
            lever_anchor();
    }

    module lever() {
        rotate([-90, 0, 0]) 
            cylinder(base_width, strength, strength);
        cube([lever_length, latch_hinge_width, strength]);

        translate([0, base_width-latch_hinge_width, 0])    
            cube([lever_length, latch_hinge_width, strength]);
        
        translate([hinge_outer_radius+tolerance, 0, 0])    
            cube([lever_length-hinge_outer_radius-tolerance, base_width, strength]);

        difference () {
            union() {
                translate([lever_hinge_distance, -(strength+tolerance*2), 0])
                    rotate([-90, 0, 0]) 
                    cylinder(base_width + strength*2 + tolerance*4, strength, strength);   

                 translate([lever_hinge_distance, -(strength+tolerance*2+strength/2), 0])
                    rotate([-90, 0, 0]) 
                    cylinder(strength/2, hinge_outer_radius, hinge_outer_radius);   
                
                  translate([lever_hinge_distance, base_width+strength+tolerance*2, 0])
                    rotate([-90, 0, 0]) 
                    cylinder(strength/2, hinge_outer_radius, hinge_outer_radius);   
            }
                
            translate([0, (base_width-(base_hinge_width+tolerance*2))/2, 0])
                rotate([-90, 0, 0]) 
                cylinder(base_hinge_width+tolerance*2, hinge_outer_radius+tolerance, hinge_outer_radius+tolerance);         
        }
    }    

    module hook() {
        module side_cylinder() {            
            rotate([-90, 0, 0])
            cylinder(strength, hinge_outer_radius, hinge_outer_radius);
        }  

        module side_rod() {
             translate([0, 0, -strength/2])
                    cube([hook_length, strength, strength]);
        }

        difference() {
            union() {
                translate([0, 0, 0]){
                    side_cylinder();
                    side_rod();
                }

                translate([0, strength+tolerance*2+base_width, 0]) {
                    side_cylinder();
                    side_rod();
                }
            }

            translate([0, -1, 0])
                rotate([-90, 0, 0])
                cylinder(base_width + strength*2 + tolerance*2 + 2, strength+tolerance, strength+tolerance);
        }

        translate([hook_length-strength, 0, -strength/2])
            cube([strength, base_width+strength*2+tolerance*2, strength]);
    }

    translate([0, strength*1.5+tolerance*2, 0]) {
        base();
        translate([hinge_outer_radius, 0, lever_elevation+hinge_outer_radius]) 
            rotate([0, lever_angle*-1, 0])
                lever();

        hook_origin_x = hinge_outer_radius+cos(lever_angle)*lever_hinge_distance;
        hook_origin_z = hinge_outer_radius+lever_elevation+sin(lever_angle)*lever_hinge_distance;

        translate([hook_origin_x, -(strength+tolerance), hook_origin_z])
            rotate([0, hook_angle*-1, 0])
            hook();
    }   


}

$fs=.1;
$fa=.1;
cube([40, 20, 3.6]);
translate([15, 0, 3.6])
    latch(20, 20, 22, 3, lever_angle=90, hook_angle=180, lever_elevation=1);
translate([4,5.5,3])
    cube([5, 9, 7]);