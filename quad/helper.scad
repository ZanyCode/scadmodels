module line(start, end, thickness = 1) {
    hull() {
        translate(start) sphere(thickness);
        translate(end) sphere(thickness);
    }
}

// Cotangent, Cosecant, Secant. Why the fuck are these not included by default?
function cot(alpha)=cos(alpha)/sin(alpha);
function csc(alpha)=1/sin(alpha);
function sec(alpha)=1/cos(alpha);

// Returns a vector translating an object by the given distance towards the given direction
function translation_vector(angle, distance) = [cos(angle), sin(angle), 0]*distance;

// Calculate the difference between right/left boundary of the arm where they intersect the base plate
function side_length_diff(w, xa, xb, ya, yb, alpha) = 
            (0.5*w*cos(alpha)+(xa-xb)) / sin(alpha) - (0.5*w*sin(alpha)+(ya-yb)) / cos(alpha);

// First order derivative w.r.t. alpha of side_length_diff()
function side_length_diff1(width, xa, xb, ya, yb, alpha) = 
            let(w=0.5*width, a=xb-xa, b=yb-ya)
                -2*w - (a + w*cos(alpha))*cot(alpha)*csc(alpha) - sec(alpha)*(b + w*sin(alpha))*tan(alpha);

// Recursively determine for which angle the length of both arm border lines are identical using Newton's method. 
function calculateArmAngle(base_size, outer_size, arm_width, desired_precision, start_alpha=1) = 
    let(w=arm_width, xa=outer_size[0], xb=base_size[0], ya=outer_size[1], yb=base_size[1], a=start_alpha) 
        side_length_diff(w, xa, xb, ya, yb, a) < desired_precision ? a :
        calculateArmAngle(
            base_size, outer_size, arm_width, desired_precision,
            a + side_length_diff(w, xa, xb, ya, yb, a) /
                side_length_diff1(w, xa, xb, ya, yb, a));    
     