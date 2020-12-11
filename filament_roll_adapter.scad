$fn=500;
outer_diameter=71;
inner_diameter=37;
height=60;

difference(){
    cylinder(height, outer_diameter/2, outer_diameter/2, center=true);
    cylinder(height, inner_diameter/2, inner_diameter/2, center=true);
}