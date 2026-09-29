module coaster(dia){
 h = 3;
 cylinder(h = h, d = dia, center = true);
}

module cup_dia_h(dia, h){
 inner_dia = dia - 4;
 inner_h = h - 2;
 difference() {
  cylinder(h = h, d = dia, center = true);
  translate([0, 0, (h - inner_h) / 2])
   cylinder(h = inner_h, d = inner_dia, center = true);
  }
}

module cup_h_vol(h, vol){
 inner_h = h - 2;
 inner_dia = sqrt(vol / PI / inner_h) * 2;
 dia = inner_dia + 4;
 difference(){
  cylinder(h = h, d = dia, center = true);
  translate([0, 0, (h - inner_h) / 2])
   cylinder(h = inner_h, d = inner_dia, center = true);
  }
}

module cup_on_coaster(h, vol) {
 coaster_h = 3;
 inner_h   = h - 2;
 inner_dia = sqrt(vol / PI / inner_h) * 2;
 cup_dia   = inner_dia + 4;
 coaster_dia = cup_dia + 20;
 cup_h_vol(h, vol);
 translate([0, 0, (-h / 2) - (coaster_h / 2)])
  coaster(coaster_dia);
}

cup_on_coaster(h=70, vol=200000);
