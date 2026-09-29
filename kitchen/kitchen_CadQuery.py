import cadquery as cq
import math

def faucet():
    circ = cq.Workplane("XY").circle(10)
    profile = (cq.Workplane("YZ")
            .line(0, 150)
            .threePointArc((-40, 190), (-80, 150))
            .wire())
    s1 = circ.sweep(profile)
    bdy1 = cq.Workplane("XY").cylinder(60, 20, centered=True)
    bdy2 = (cq.Workplane("XY").cylinder(30, 5, centered=True)
            .rotate((0, 0, 0), (0, 1, 0), 90).translate((-33, 0, 20)))
    bdy = (bdy1.union(bdy2)).rotate((0, 0, 0), (0, 1, 0), 90).translate((10, 0, 40))
    return s1.union(bdy)

def sink(diameter, lip_outer_dia, lip_height, drain_hole_dia):
    c1 = cq.Workplane("XY").sphere(diameter/2, centered=True)
    c2 = cq.Workplane("XY").cylinder(lip_height, lip_outer_dia/2, centered=True).translate((0, 0, lip_height/2))
    c3 = cq.Workplane("XY").sphere((diameter-20)/2, centered=True)
    c4 = cq.Workplane("XY").cylinder(diameter, drain_hole_dia/2, centered=True)
    c5 = cq.Workplane("XY").box(lip_outer_dia, lip_outer_dia, lip_outer_dia, centered=True).translate((0, 0, (lip_outer_dia/2)+lip_height))
    return c1.union(c2).cut(c3).cut(c4).cut(c5)

def handle(length, height, dia):
    c1 = ( cq.Workplane("XY").cylinder(height - dia / 2, dia, centered=True)
           .rotate((0, 0, 0), (1, 0, 0), 90)
           .translate((-length/2 + dia/2, -(height - dia/2)/2)))
    c2 = ( cq.Workplane("XY").cylinder(height - dia / 2, dia, centered=True)
           .rotate((0, 0, 0), (1, 0, 0), 90)
           .translate((length / 2 - dia / 2, -height / 2)))
    c3 = ( cq.Workplane("XY").cylinder(length + dia, dia, centered=True)
           .rotate((0, 0, 0), (0, 1, 0), 90)
           .translate((0, -height + dia / 2)))
    return c1.union(c2).union(c3)

def countertop_30mm(width, depth):
    height = 30
    return cq.Workplane("XY").box(width, depth, height, centered=True)

def countertop_30mm_circular_sink(width, depth, sink_dia, sink_x, sink_y):
    height = 30
    sink_z = height / 2
    sink_outer_dia = sink_dia + 30
    if ((-width/2 >= sink_x-sink_outer_dia/2) or (width/2 <= sink_x+sink_outer_dia/2)):
        raise Exception("sink exceeds countertop dimensions (x-axis)")
    if ((-depth/2 >= sink_y-sink_outer_dia/2) or (depth/2 <= sink_y+sink_outer_dia/2)):
        raise Exception("sink exceeds countertop dimensions (y-axis)")
    ct = countertop_30mm(width, depth)
    sh = cq.Workplane("XY").cylinder(height, sink_dia/2, centered=True).translate((sink_x, sink_y, 0))
    ct_cut = ct.cut(sh)
    si = sink(sink_dia, sink_outer_dia, 5, 35)
    fc = faucet()
    assy = cq.Assembly()
    assy.add(ct_cut)
    assy.add(si, loc=cq.Location((sink_x, sink_y, sink_z)))
    assy.add(fc, loc=cq.Location((sink_x, (sink_dia/2)+40, sink_z)))
    return assy

#show_object(countertop_30mm_circular_sink(1800, 600, 400, 500, 0), "sinkske")

def panel_18mm(l, w):
    thickness = 18
    return cq.Workplane("XY").box(l, w, thickness, centered=True)

def door_18mm(w, h): # assembly kan geen rotatie en handle is een gewone part
    thickness = 18
    panel = panel_18mm(w, h).rotate((0, 0, 0), (1, 0, 0), 90)
    hnd = ( handle(length=150, height=35, dia=10)
            .rotate((0, 0, 0), (0, 1, 0), 90)
            .translate((w / 2 - 50, -thickness / 2, h / 2 - 150)))
    assy = cq.Assembly()
    assy.add(panel)
    assy.add(hnd)
    return assy

def unit_box(width, height, depth):
    panel_thickness = 18
    back_space = 75
    inner_width = width - (2 * panel_thickness)
    inner_height = height - (2 * panel_thickness)

    left_panel = panel_18mm(height, depth).rotate((0, 0, 0), (0, 1, 0), 90)
    right_panel = panel_18mm(height, depth).rotate((0, 0, 0), (0, 1, 0), 90)
    top_panel = panel_18mm(inner_width, depth)
    bottom_panel = panel_18mm(inner_width, depth)
    back_panel = ( panel_18mm(inner_width, inner_height).rotate((0, 0, 0), (1, 0, 0), 90))
    assy = cq.Assembly()
    assy.add(left_panel, loc=cq.Location((-inner_width / 2 - panel_thickness / 2, 0, 0)))
    assy.add(right_panel, loc=cq.Location((inner_width / 2 + panel_thickness / 2, 0, 0)))
    assy.add(top_panel, loc=cq.Location((0, 0, height / 2 - panel_thickness / 2)))
    assy.add(bottom_panel, loc=cq.Location((0, 0, -height / 2 + panel_thickness / 2)))
    assy.add(back_panel, loc=cq.Location((0, depth / 2 - panel_thickness / 2 - back_space, 0)))
    return assy

def drawer(width, height, depth):
    panel_thickness = 18
    inner_width = width - (2 * panel_thickness)
    inner_height = height - panel_thickness
    front_height = height + (2 * panel_thickness)
    front_width = width + (2 * panel_thickness)

    box_left = panel_18mm(height, depth).rotate((0, 0, 0), (0, 1, 0), 90)
    box_right = panel_18mm(height, depth).rotate((0, 0, 0), (0, 1, 0), 90)
    box_bottom = panel_18mm(inner_width, depth)
    box_back = panel_18mm(inner_width, inner_height).rotate((0, 0, 0), (1, 0, 0), 90)
    box_front = panel_18mm(inner_width, inner_height).rotate((0, 0, 0), (1, 0, 0), 90)
    drawer_front = panel_18mm(front_width, front_height).rotate((0, 0, 0), (1, 0, 0), 90)
    front_handle = handle(length=150, height=35, dia=10)
    assy = cq.Assembly()
    assy.add(box_left, loc=cq.Location((-inner_width/2 - panel_thickness/2, 0, 0)))
    assy.add(box_right, loc=cq.Location((inner_width/2 + panel_thickness/2, 0, 0)))
    assy.add(box_bottom, loc=cq.Location((0, 0, -height/2 + panel_thickness / 2)))
    assy.add(box_back, loc=cq.Location((0, depth/2 - panel_thickness/2, panel_thickness/2)))
    assy.add(box_front, loc=cq.Location((0, -depth/2 + panel_thickness/2, panel_thickness/2)))
    assy.add(drawer_front, loc=cq.Location((0, -depth/2 - panel_thickness/2, 0)))
    assy.add(front_handle, loc=cq.Location((0, -depth/2 - panel_thickness/2 -5, 0)))
    return assy

def drawer_unit(width, height, depth, nr_of_drawers, clearance_lr, clearance_tb):
    box_panel_thickness = 18
    box_back_space = 75
    box_inner_width = width - 2*box_panel_thickness
    box_inner_depth = depth - box_back_space - box_panel_thickness
    drawer_depth = box_inner_depth - 10
    drawer_front_height = ( height - (nr_of_drawers+1) * clearance_tb) / nr_of_drawers
    drawer_y = (-depth/2) + drawer_depth/2
    assy = cq.Assembly()
    assy.add(unit_box(width, height, depth))
    for i in range(nr_of_drawers):
        drawer_z = ( -height/2 + clearance_tb + drawer_front_height/2 + i * (drawer_front_height + clearance_tb))
        d = drawer(width=box_inner_width - 2*clearance_lr, height=drawer_front_height-36, depth=drawer_depth)
        assy.add(d, loc=cq.Location( (0, drawer_y, drawer_z)))
    return assy

def door_unit(width, height, depth):
    clearance = 4
    panel_thickness = 18
    box = unit_box(width, height, depth)
    door = door_18mm( w=width - 2*clearance, h=height - 2*clearance)
    assy = cq.Assembly()
    assy.add(box)
    assy.add(door,loc=cq.Location((0, -depth / 2 - panel_thickness / 2, 0)))
    return assy

def door_unit_sink(width, height, depth):
    box_panel_thickness = 18
    box_back_space = 75
    box_inner_width = width - (2 * box_panel_thickness)
    box_inner_depth = depth - box_back_space - box_panel_thickness
    sink_max_width = box_inner_width-50
    sink_max_depth = box_inner_depth-100
    du = door_unit(width, height, depth).toCompound()

    cutout = cq.Assembly()
    cutout.add(cq.Workplane("XY").box(sink_max_width, sink_max_depth, box_panel_thickness),
               loc=cq.Location((0, 0, (height/2)-box_panel_thickness/2)))
    assy = cq.Assembly()
    assy.add(du.cut(cutout.toCompound()))
    return assy

def kickboard(width, height, depth):
    panel_thickness = 18
    nr_of_side_panels = math.ceil(width / depth)
    begin_x = -width / 2 + panel_thickness / 2
    end_x = width / 2 - panel_thickness / 2
    delta_x = ((end_x - begin_x) / (nr_of_side_panels - 1))

    front_panel = panel_18mm(width, height).rotate((0, 0, 0), (1, 0, 0), 90)
    back_panel = panel_18mm(width, height).rotate((0, 0, 0), (1, 0, 0), 90)
    assy = cq.Assembly()
    assy.add(front_panel, loc=cq.Location((0, -depth/2 + panel_thickness/2, 0)))
    assy.add(back_panel, loc=cq.Location((0, depth/2 - panel_thickness/2, 0)))
    for i in range(nr_of_side_panels):
        x = begin_x + delta_x * i
        sp = (panel_18mm(height, depth - 2 * panel_thickness)
              .rotate((0, 0, 0), (0, 1, 0), 90))
        assy.add(sp, loc=cq.Location((x, 0, 0)))
    return assy

def kitchen(counter_height, unit_width, depth, countertop_overhang, sink_diameter):
    nr_of_units_next_to_each_other = 4
    kickboard_height = 120
    countertop_height = 30
    unit_height = counter_height - kickboard_height - countertop_height

    u1 = door_unit(width=unit_width, height=unit_height, depth=depth)
    u2 = door_unit_sink(width=unit_width, height=unit_height, depth=depth)
    u3 = drawer_unit(width=unit_width, height=unit_height, depth=depth,
                     nr_of_drawers=3, clearance_lr=4, clearance_tb=4)
    u4 = door_unit(width=unit_width, height=1200, depth=depth)
    u5 = door_unit(width=unit_width,height=500,depth=depth)
    kb = kickboard(width=4 * unit_width, height=120, depth=depth)
    ct = countertop_30mm_circular_sink( width=3 * unit_width + countertop_overhang,
                                         depth=depth + countertop_overhang,
                                         sink_dia=sink_diameter,
                                         sink_x=unit_width/2 + unit_width - (3*unit_width - countertop_overhang)/2,
                                         sink_y=countertop_overhang/2)
    assy = cq.Assembly()
    assy.add(u1, loc=cq.Location((unit_width/2, 0, kickboard_height + unit_height/2)))
    assy.add(u2, loc=cq.Location((unit_width/2 + unit_width, 0, kickboard_height + unit_height/2)))
    assy.add(u3, loc=cq.Location((unit_width/2 + 2*unit_width, 0, kickboard_height + unit_height/2)))
    assy.add(u4, loc=cq.Location((unit_width/2 + 3*unit_width, 0, kickboard_height+1200/2)))
    assy.add(u5, loc=cq.Location((unit_width/2 + 3*unit_width, 0, kickboard_height+1200+500/2)))
    assy.add(kb, loc=cq.Location(((nr_of_units_next_to_each_other*unit_width)/2, 0, kickboard_height/2)))
    assy.add(ct, loc=cq.Location(((3*unit_width - countertop_overhang)/2, -countertop_overhang/2, counter_height - countertop_height/2)))
    return assy

if __name__ == "__main__":
    (kitchen(counter_height=880,
            unit_width=600,
            depth=560,
            countertop_overhang=18,
            sink_diameter=350,)
     .export("kitchen.stl", "STL"))
