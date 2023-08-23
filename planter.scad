// planter.scad

// User parameters

// Dimensions
pot_bottom_diameter = 210;      // Outer diameter
pot_top_diameter = 255;
pot_height = 240;
wall_thickness = 2.4;

// Appearance
flutes = 7;
flute_spacing = 20; // gap between flutes
flute_depth = 15;

$fn = 50;

// End of user adjustable parameters

module pot_shape (bottom_diameter, top_diameter, flute_space)
{
    difference()
    {
        circle(d=bottom_diameter);
        
        bottom_radius = bottom_diameter / 2;
        bottom_circumference = PI*bottom_diameter;
        flute_cl = (bottom_circumference / flutes) - flute_space;    // length of circumference occupied by the flute
        flute_arc_angle = 360 * flute_cl / bottom_circumference;
        //flute_length = sqrt(2*pow(bottom_radius,2) - 2*bottom_radius * cos(flute_arc_angle));
        flute_length = (bottom_radius * sin(flute_arc_angle)) / sin((180-flute_arc_angle)/2);
        
        flute_radius = flute_depth/2 + pow(flute_length,2) / (8*flute_depth);
        flute_offset = flute_radius - flute_depth;
        
        side_degrees = 360 / flutes;
        
        for (angle = [0: side_degrees: side_degrees*flutes])
        {
            rotate([0,0,angle])
                translate([bottom_diameter/2 + flute_offset,0,0])
                    circle(r=flute_radius);
        }
    }
    
}


module pot (bottom_diameter, top_diameter, flute_space)
{
    linear_extrude(height=pot_height, center=false, twist = 360 / flutes, scale=top_diameter/bottom_diameter, convexity=10)
    //linear_extrude(height=pot_height, center=false, twist = 0, scale=top_diameter/bottom_diameter, convexity=10)
        pot_shape(bottom_diameter, top_diameter, flute_space);
}


module slot (width, length)
{
    hull()
    {
        circle(d=width);
        translate([length,0,0])
            circle(d=width);
    }
}




//color("steelblue",0.8)
difference()
{
    union()
    {
        side_degrees = 360 / flutes;    
        
        // Main pot body
        difference()
        {
            pot(pot_bottom_diameter, pot_top_diameter, flute_spacing);
            
            translate([0,0,wall_thickness])
                pot(pot_bottom_diameter - 2*wall_thickness, pot_top_diameter - 2*wall_thickness, flute_spacing - 2*wall_thickness);
        
            offset = -side_degrees/5;
            
            // cut out holes to allow excess water to evaporate
            for (angle = [offset: side_degrees: side_degrees*flutes + offset])
            {
                rotate([0,90,angle])
                    rotate([0,0,(360 / flutes) / 6])
                        translate([-pot_height/3+wall_thickness,0,0])
                            cylinder(h=pot_bottom_diameter, d=(pot_bottom_diameter / flutes) / 3, center=false);
            }          
            }

        // Inner drainage wall
        intersection()
        {
            pot(pot_bottom_diameter, pot_top_diameter, flute_spacing);
            difference()
            {
                pot(pot_bottom_diameter*0.7, pot_top_diameter*1.6, flute_spacing);
                
                translate([0,0,wall_thickness])
                    pot(pot_bottom_diameter*0.7 - 2*wall_thickness, pot_top_diameter*1.6 - 2*wall_thickness, flute_spacing - 2*wall_thickness);
                

                slot_width = (PI*pot_bottom_diameter / flutes) / 10;
                
                // cut out slots to let water flow into overflow area
                for (angle = [0: side_degrees: side_degrees*flutes])
                {
                    rotate([0,90,angle])
                        rotate([0,0,(360 / flutes) / 6])
                            translate([-slot_width,0,0])
                                linear_extrude(height=pot_bottom_diameter/2, center=false)
                                    slot(slot_width,2*slot_width);
                }            
            }
            
        }    
    }


    *translate([0,-pot_bottom_diameter,-1])
        cube(pot_bottom_diameter*2);
}