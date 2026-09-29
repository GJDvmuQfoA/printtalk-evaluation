import math
import cadquery as cq

def coaster(dia):
    h = 3
    return cq.Workplane().cylinder(h, dia/2, centered=(True, True, True))

def cup_dia_h(dia, h):
    inner_dia = dia-4
    inner_h = h-2
    outer = cq.Workplane().cylinder(h, dia/2, centered=(True, True, True))
    inner = cq.Workplane().cylinder(inner_h, inner_dia/2, centered=(True, True, True)).translate([0, 0, (h-inner_h)/2])
    return outer.cut(inner)

def cup_h_vol(h, vol):
    inner_h = h - 2
    inner_dia = math.sqrt(vol/math.pi/inner_h)*2
    dia = inner_dia+4
    outer = cq.Workplane().cylinder(h, dia/2, centered=(True, True, True))
    inner = cq.Workplane().cylinder(inner_h, inner_dia/2, centered=(True, True, True)).translate([0, 0, (h-inner_h)/2])
    return outer.cut(inner)

def cup_on_coaster(h, vol):
    coaster_h = 3
    cup_inner_h = h - 2
    cup_inner_dia = math.sqrt(vol/math.pi/cup_inner_h)*2
    cup_dia = cup_inner_dia+4
    coaster_dia = cup_dia+20
    cp = cup_h_vol(h, vol)
    cr = coaster(coaster_dia).translate([0, 0, (h / -2) - (coaster_h / 2)])
    assy = cq.Assembly()
    assy.add(cp)
    assy.add(cr)
    return assy

if __name__ == "__main__":
    cup_on_coaster(h=70, vol=200000).export("cup_on_coaster.stl", "STL")