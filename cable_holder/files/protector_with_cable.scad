// ZAV cable holder

$fn = 100;

wall_thikness = 1.5;

echo(version=version());

module fillet(r, h) {
    translate([r / 2, r / 2, 0])
        difference() {
            cube([r + 0.01, r + 0.01, h], center = true);

            translate([r/2, r/2, 0])
                cylinder(r = r, h = h + 1, center = true);

        }
}

module plate(width, height, th) {
    difference() {
        cube([width, height, th]);

        fillet(height / 4, -0.1 + th * 5);
        translate([0,height,0]) rotate(a=[0,0,270]) fillet(height / 4, -0.1 + th * 5);
    }
}

module central_part(width, height, gap) {
    union() {
        plate(width, height, wall_thikness);
        translate([0, 0, gap + wall_thikness])
            plate(width, height, wall_thikness);
        
        translate([wall_thikness, height/4, 0]) 
            cube([width - wall_thikness, height/2, gap + wall_thikness]);
    }
}

module wire_gap(width, height, thikness) {
    radius = height/8;
    union() {
        translate([height/4 + wall_thikness, height / 2, -0.5 * thikness]) hull() { 
            translate([width - 3 * wall_thikness - 2 * radius, 0, 0]) 
                cylinder (h = 2 * thikness, r=radius);
            cylinder (h = 2 * thikness, r=radius);
        }

        translate([width/4, height/2, -0.5 * thikness]) cube([5, 20, 2 * thikness]);
    }
}
module protector(width, height, acril_thickness) {
    translate([width, height/2, 0])  rotate([0,0,180])
    difference() {
        central_part(width, height, acril_thickness);

        wire_gap(width, height, acril_thickness + 2 * wall_thikness);
    }
}

module tor_element(height, radius) {
    translate([0, 0, height]) rotate([90, 180, 0]) rotate_extrude(angle = 90) {
        union() {
            translate([height, 0, 0]) circle(radius);
            translate([0, -radius, 0]) square([height, 2 * radius]);
        }
    }
}

module cable_channel(height, radius) {
    angle = 90;
    union() {
        difference() {
            translate([0, 0, 0]) rotate([0,angle,0])
                difference() {
                    union() {
                       // tor element
                       translate([0, 0, radius]) tor_element(2 * radius, radius);
                        
                       // cable channel
                       translate([-2 * radius, 0, 3 * radius])
                            cylinder (h = height - 3 * radius, r=radius);
                           
                       //base
                       translate([-2 * radius, 0, 0]) rotate([0,90-angle,0])
                            cylinder(radius * 5, r1=radius * 2.5,  r2=radius);
                    }
                    
                    // internal space of the tor element
                    translate([0, 0, radius/2 + 2 * wall_thikness])
                        tor_element(2 * radius, radius - wall_thikness);
                
                    //internal side of the cable channel
                    translate([-2 * radius, 0, 2 * radius]) 
                        cylinder (h = height + wall_thikness,
                                  r = radius - wall_thikness);
                    
                    
                    // back gap for a wire
                    translate([ 0, 0, height / 2 + 2 * radius + wall_thikness]) minkowski() {
                        rotate([90, 0, 0]) cylinder(r = 2 * radius - wall_thikness,
                                                    h = radius / 2 - 2 * wall_thikness);
                        
                        cube ([radius, 2 * radius - 4 * wall_thikness,
                                height + wall_thikness], center = true);
                    }
                }

           // external limitters
           translate([-height, -height, -2 * height])
                cube([2 * height, 2 * height, 2 * height]);
           translate([-height, -height / 2, -height])
                cube([height, height, 2 * height]);
           translate([-radius, -height, 3.2 * radius])
                cube([2 * height, 2 * height, 2 * height]);

        }
    }
}


rotate([0, -90, 0]) {
    acril_thickness = 5;
    cable_challel_radius = 6;
    
    union() {
        protector(45, 15, acril_thickness);
        translate([0, 0, acril_thickness + wall_thikness])
            cable_channel(70, cable_challel_radius + wall_thikness);
    }
}

