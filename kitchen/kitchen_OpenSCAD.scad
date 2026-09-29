module faucet(){
 union(){
  translate([0,0,75])
   cylinder(h=150, d=20, center=true);
  translate([0, -40, 150])
   rotate([90,0,90])
    rotate_extrude(angle=180)
     translate([40, 0])
      circle(10);
  translate([10,0,40])
   rotate([0,90,0]) {
    cylinder(h=60, d=40, center=true);
     translate([-33,0,20])
      rotate([0,90,0])
       cylinder(h=30,d=10, center=true);
   }
 }
}

module sink(diameter, lip_outer_dia, lip_height, drain_hole_dia){
 difference(){
  union(){
   sphere(d=diameter);
   translate([0, 0, lip_height / 2])
    cylinder(h=lip_height, d=lip_outer_dia, center=true);
  }
  sphere(d=diameter - 20);
  cylinder(h=diameter, d=drain_hole_dia, center=true);
  translate([0, 0, lip_outer_dia / 2 + lip_height])
  cube(size=lip_outer_dia, center=true);
 }
}

module handle(length, height, dia){
 union(){
  translate([-length/2 + dia/2, -(height-(dia/2))/2, 0])
   rotate([90, 0, 0])
    cylinder(h = height - dia/2, d = dia, center=true);
  translate([length/2 - dia/2, -height/2, 0])
   rotate([90, 0, 0])
    cylinder(h = height - dia/2, d = dia, center=true);
  translate([0, -height + dia/2, 0 ])
   rotate([0, 90, 0])
    cylinder(h = length + dia, d = dia, center=true);
 }
}

module countertop_30mm(width, depth, height = 30){
 assert(height == 30, "height must be 30mm");
 cube([width, depth, height], center=true);
}

module countertop_30mm_circular_sink(width, depth, sink_dia, sink_x, sink_y){
 height = 30;
 sink_z = height / 2;
 sink_outer_dia = sink_dia + 30;
 assert(-width/2 < sink_x - sink_outer_dia/2, "sink exceeds countertop dimensions (x-axis)");
 assert( width/2 > sink_x + sink_outer_dia/2, "sink exceeds countertop dimensions (x-axis)");
 assert(-depth/2 < sink_y - sink_outer_dia/2, "sink exceeds countertop dimensions (y-axis)");
 assert( depth/2 > sink_y + sink_outer_dia/2, "sink exceeds countertop dimensions (y-axis)");
 union(){
  difference() {
   countertop_30mm(width, depth);
   translate([sink_x, sink_y, 0])
    cylinder(h=height, d=sink_dia, center=true);
  }
  translate([sink_x, sink_y, sink_z])
   sink(sink_dia, sink_outer_dia, 5, 35);
  translate([sink_x, sink_dia/2 + 40, sink_z])
   faucet();
 }
}

module panel_18mm(l, w){
 thickness = 18;
 cube([l, w, thickness], center=true);
}

module door_18mm(w, h){
 thickness = 18;
 rotate([90, 0, 0])
  panel_18mm(w, h);
 translate([w/2 - 50, -thickness/2, h/2-150])
  rotate([0, 90, 0])
   handle(length=150, height=35, dia=10);
}

module unit_box(width, height, depth){
 panel_thickness = 18;
 back_space = 75;
 inner_width = width-(2 * panel_thickness);
 inner_height = height-(2 * panel_thickness);
 inner_depth = depth-back_space-panel_thickness;
 translate([-inner_width/2-(panel_thickness/2), 0, 0])
  rotate([0, 90, 0])
   panel_18mm(height, depth);
 translate([inner_width/2+(panel_thickness/2), 0, 0])
  rotate([0, 90, 0])
   panel_18mm(l=height, w=depth);
 translate([0, 0, height/2-(panel_thickness/2)])
  panel_18mm(l=inner_width, w=depth);
 translate([0, 0, -height/2+(panel_thickness/2)])
  panel_18mm(l=inner_width, w=depth);
 translate([0, depth/2-(panel_thickness/2)-back_space, 0])
  rotate([90, 0, 0])
   panel_18mm(l=inner_width, w=inner_height);
}

module drawer(width, height, depth){
 panel_thickness = 18;
 inner_width = width - (2*panel_thickness);
 inner_height = height - panel_thickness;
 front_height = height + (2*panel_thickness);
 front_width = width + (2*panel_thickness);
  union(){
   translate([-inner_width/2-(panel_thickness/2), 0, 0])
    rotate([0, 90, 0])
     panel_18mm(l=height, w=depth);
   translate([inner_width/2+(panel_thickness/2), 0, 0])
    rotate([0, 90, 0])
     panel_18mm(l=height, w=depth);
   translate([0, 0, -height/2+(panel_thickness/2)])
    panel_18mm(l=inner_width, w=depth);
   translate([0, depth/2-(panel_thickness/2), (panel_thickness/2)])
    rotate([90, 0, 0])
     panel_18mm(l=inner_width, w=inner_height);
   translate([0, -depth/2+(panel_thickness/2), (panel_thickness/2)])
    rotate([90, 0, 0])
     panel_18mm(l=inner_width, w=inner_height);
   translate([0, -depth/2-(panel_thickness/2), 0])
    rotate([90, 0, 0])
     panel_18mm(l=front_width, w=front_height);
   translate([0, -depth/2-(panel_thickness/2)-5, 0]) //-5 because dia=10
    handle(length=150, height=35, dia=10);
 }
}

module door_unit(width, height, depth){
 clearance = 4;
 panel_thickness=18;
 unit_box(width, height, depth);
 translate([0, -depth/2-(panel_thickness/2), 0])
  door_18mm(w=width-2*clearance, h=height-2*clearance);
}

module drawer_unit(width, height, depth, nr_of_drawers, clearance_lr, clearance_tb) {
 assert(nr_of_drawers >= 1, "nr-of-drawers must be >= 1");
 //derived box dim
 box_panel_thickness = 18;
 box_back_space = 75;
 box_inner_width = width-(2 * box_panel_thickness);
 box_inner_height = height-(2 * box_panel_thickness);
 box_inner_depth = depth - box_back_space - box_panel_thickness;
 drawer_depth = box_inner_depth-10;
 drawer_front_height = (height-(nr_of_drawers+1)*clearance_tb)/nr_of_drawers;
 drawer_y = (depth/-2) + (drawer_depth/2);
 union(){
  unit_box(width, height, depth);
  for (i = [0:nr_of_drawers-1])
   translate([0, drawer_y, -height/2+clearance_tb+drawer_front_height/2+i*(drawer_front_height+clearance_tb)])
    drawer(width=box_inner_width-2*clearance_lr,
           height=drawer_front_height-36,
           depth=drawer_depth);
 }
}

module door_unit_sink(width, height, depth){
 box_panel_thickness = 18;
 box_back_space = 75;
 box_inner_width = width - 2 * box_panel_thickness;
 box_inner_depth = depth - box_back_space - box_panel_thickness;
 sink_max_width = box_inner_width - 50;
 sink_max_depth = box_inner_depth - 100;
 difference() {
  door_unit(width, height, depth);
  translate([0, 0, height/2 - box_panel_thickness/2])
  cube([sink_max_width, sink_max_depth, box_panel_thickness], center=true);
 }
}

module kickboard(width, height, depth) {
 panel_thickness = 18;
 nr_of_side_panels = ceil(width/depth);
 begin_x = -width/2 + panel_thickness/2;
 end_x = width/2 - panel_thickness/2;
 delta_x = (end_x - begin_x)/ (nr_of_side_panels-1);
 union(){
  translate([0, -depth/2+(panel_thickness/2), 0])
   rotate([90, 0, 0])
    panel_18mm(l=width, w=height);
  translate([0, depth/2-(panel_thickness/2), 0])
   rotate([90, 0, 0])
    panel_18mm(l=width, w=height);
  for (i = [0:nr_of_side_panels-1])
   translate([begin_x + delta_x * i, 0, 0])
    rotate([0, 90, 0])
     panel_18mm(l=height, w=depth-2*panel_thickness);
 }
}

module kitchen(counter_height, unit_w, depth, countertop_overhang, sink_diameter){
 kickboard_height = 120;
 countertop_height = 30;
 unit_height=counter_height - kickboard_height - countertop_height;
    translate([unit_w/2, 0, kickboard_height+unit_height/2])
        door_unit(width=unit_w, height=unit_height, depth=depth);
    translate([unit_w/2+unit_w, 0, kickboard_height+unit_height/2])
        door_unit_sink(width=unit_w, height=unit_height, depth=depth);
    translate([unit_w/2+2*unit_w ,0, kickboard_height+unit_height/2])
        drawer_unit(width=unit_w, height=unit_height, depth=depth, nr_of_drawers=3, clearance_lr=18, clearance_tb=4);
    translate([unit_w/2+3*unit_w ,0, kickboard_height+1200/2])
        door_unit(width=unit_w, height=1200, depth=depth);
    translate([unit_w/2+3*unit_w ,0, kickboard_height+1200/2])
        door_unit(width=unit_w, height=1200, depth=depth);
    translate([unit_w/2+3*unit_w ,0, kickboard_height+1200+500/2])
        door_unit(width=unit_w, height=500, depth=depth);
    translate([(4*unit_w)/2 ,0, kickboard_height/2])
        kickboard(width=4*unit_w, height=120, depth=depth);
    translate([(3*unit_w-countertop_overhang)/2, countertop_overhang/-2, counter_height - countertop_height/2])
        countertop_30mm_circular_sink(width=(3*unit_w + countertop_overhang), 
                                      depth=depth+countertop_overhang,
                                      sink_dia=sink_diameter,
                                      sink_x=unit_w/2 + unit_w - (3*unit_w - countertop_overhang)/2,
                                      sink_y=countertop_overhang/2);
}

kitchen(counter_height = 880, unit_w=600, depth=560, countertop_overhang=18, sink_diameter=350);