(shape: tap ()
 (script:
  (sweep:
   (circle #:d 20)
   (turtle:
    (up 90)
    (forward 150)
    (down 90)
    (right 90)
    (arc 80 0 -40 190)))
   ((shape: () (script:
                (cylinder #:diameter 40 #:height 60)
                (cylinder #:diameter 10 #:height 30 #:x -33 #:z 20 #:rot-y 90)))
    #:x 10 #:z 40 #:rot-y 90)))

(shape: sink (diameter lip-outer-dia lip-height drain-hole-dia)
 (script:
  (sphere #:diameter diameter)
  (cylinder #:diameter lip-outer-dia #:height lip-height #:z (/ lip-height 2))
  (cut: (sphere #:diameter (- diameter 20)))
  (cut: (cylinder #:diameter drain-hole-dia #:height diameter))
  (cut: (cube #:size lip-outer-dia #:z (+ (/ lip-outer-dia 2) lip-height)))))

(shape: handle (length height dia)
 (script:
  (cylinder #:height (- height (/ dia 2)) #:diameter dia #:x (+ (/ length -2) (/ dia 2)) #:y (/ (- height (/ dia 2)) -2) #:rot-x 90)
  (cylinder #:height (- height (/ dia 2)) #:diameter dia #:x (- (/ length 2) (/ dia 2)) #:y (/ (- height (/ dia 2)) -2) #:rot-x 90)
  (cylinder #:height (+ length dia) #:diameter dia #:y (+ (* height -1) (/ dia 2)) #:rot-y 90)))

(shape: countertop-30mm (width depth height)
 (script:
  (cuboid #:length width #:width depth #:height height))
 (constraints:
  (assert: (= height 30))))

(shape: countertop-30mm-circular-sink (width depth height sink-dia sink-x sink-y sink-z)
 (script:
  (named: ct (countertop-30mm #:width width #:depth depth #:height height))
  (cut: (cylinder #:diameter sink-dia #:height height #:x sink-x #:y sink-y))
  (named: si (sink #:diameter sink-dia #:lip-outer-dia (+ sink-dia 30) #:lip-height 5 #:drain-hole-dia 35
                   #:x sink-x #:y sink-y #:z sink-z))
  (named: fc (tap #:x sink-x #:y (+ (/ sink-dia 2) 40) #:z sink-z)))
 (constraints:
  (assert: (< (- ct.x (/ ct.width 2)) (- sink-x (/ si.lip-outer-dia 2))))
  (assert: (> (+ ct.x (/ ct.width 2)) (+ sink-x (/ si.lip-outer-dia 2))))
  (assert: (< (- ct.y (/ ct.depth 2)) (- sink-y (/ si.lip-outer-dia 2))))
  (assert: (> (+ ct.y (/ ct.depth 2)) (+ sink-y (/ si.lip-outer-dia 2) 50)))
  (assert: (= sink-z (/ height 2)))))

(shape: panel-18mm (l w thickness)
 (script:
  (cuboid #:length l #:width w #:height thickness))
 (constraints:
  (assert: (= thickness 18))))

(shape: door-18mm (w h thickness)
 (script:
  (panel-18mm #:l w #:w h #:thickness thickness #:x 0 #:y 0 #:z 0 #:rot-x 90)
  (handle #:length 150 #:height 35 #:dia 10 #:x (- (/ w 2) 50) #:y (/ thickness -2) #:z (- (/ h 2) 150) #:rot-y 90)))

(shape: unit-box (width height depth inner-width inner-height inner-depth back-space)
 (script:
  (named: left-panel (panel-18mm #:l height #:w depth #:rot-y 90))
  (named: right-panel (panel-18mm #:l height #:w depth #:rot-y 90))
  (named: top-panel (panel-18mm #:l inner-width #:w depth))
  (named: bottom-panel (panel-18mm #:l inner-width #:w depth))
  (named: back-panel (panel-18mm #:l inner-width #:w inner-height #:rot-x 90)))
 (constraints:
  (assert: (= back-space 75))
  (assert: (= inner-width (- width (+ left-panel.thickness right-panel.thickness))))
  (assert: (= inner-height (- height top-panel.thickness bottom-panel.thickness)))
  (assert: (= inner-depth (- depth back-space back-panel.thickness)))
  (assert: (= left-panel.x (- (/ inner-width -2) (/ left-panel.thickness 2))))
  (assert: (= right-panel.x (+ (/ inner-width 2) (/ left-panel.thickness 2))))
  (assert: (= top-panel.z (- (/ height 2) (/ top-panel.thickness 2))))
  (assert: (= bottom-panel.z (+ (/ height -2) (/ bottom-panel.thickness 2))))
  (assert: (= back-panel.y (- (/ depth 2) (/ back-panel.thickness 2) back-space)))))

(shape: drawer (width height depth front-width front-height inner-width inner-height inner-depth)
 (script:
  (named: box-left (panel-18mm #:l height #:w depth #:rot-y 90))
  (named: box-right (panel-18mm #:l height #:w depth #:rot-y 90))
  (named: box-bottom (panel-18mm #:l inner-width #:w depth))
  (named: box-back (panel-18mm #:l inner-width #:w inner-height #:z (/ box-bottom.thickness 2) #:rot-x 90))
  (named: box-front (panel-18mm #:l inner-width #:w inner-height #:z (/ box-bottom.thickness 2) #:rot-x 90))
  (named: drawer-front (panel-18mm #:l front-width #:w front-height #:rot-x 90))
  (handle #:length 150 #:height 35 #:dia 10 #:y (- drawer-front.y (/ drawer-front.thickness -2))))
 (constraints:
  (assert: (= inner-width (- width (+ box-left.thickness box-right.thickness))))
  (assert: (= inner-height (- height box-bottom.thickness)))
  (assert: (= front-height (+ height (* 2 box-bottom.thickness))))
  (assert: (= box-left.x (- (/ inner-width -2) (/ box-left.thickness 2))))
  (assert: (= box-right.x (+ (/ inner-width 2) (/ box-right.thickness 2))))
  (assert: (= box-bottom.z (+ (/ height -2) (/ box-bottom.thickness 2))))
  (assert: (= box-back.y (- (/ depth 2) (/ box-back.thickness 2))))
  (assert: (= box-front.y (+ (/ depth -2) (/ box-front.thickness 2))))
  (assert: (= drawer-front.y (- (/ depth -2) (/ drawer-front.thickness 2))))))

(shape: drawer-unit (width height depth nr-of-drawers inner-width inner-height inner-depth drawer-depth drawer-front-height drawer-y clearance-lr clearance-tb)
 (script:
  (named: box (unit-box #:width width #:height height #:depth depth #:inner-width inner-width
                        #:inner-height inner-height #:inner-depth inner-depth))
  (named: drawers ((shape: ()
                    (script:
                     (for i in (range nr-of-drawers)
                       (drawer #:width  (- inner-width (* 2 clearance-lr))
                               #:depth drawer-depth
                               #:front-width (- width (* 2 clearance-tb))
                               #:front-height (/ (- height (* (+ nr-of-drawers 1) clearance-tb)) nr-of-drawers)
                               #:y drawer-y)))))))
 (constraints:
  (assert: (>= nr-of-drawers 1))
  (assert: (= drawer-depth (- inner-depth 10)))
  (assert: (= drawer-front-height (/ (- height (* (+ nr-of-drawers 1) clearance-tb)) nr-of-drawers)))
  (assert: (= (/ box.depth -2) (- drawer-y (/ drawer-depth 2))))
  (assert: (linear #:shapes drawers #:z0 (+ (/ height -2) clearance-tb (/ drawer-front-height 2))
                                    #:zn (- (/ height 2) clearance-tb (/ drawer-front-height 2))))))

(shape: door-unit (width height depth inner-width inner-height inner-depth clearance)
 (script:
  (named: box (unit-box #:width width #:height height #:depth depth #:inner-width inner-width
                        #:inner-height inner-height #:inner-depth inner-depth))
  (named: door (door-18mm #:w (- width (* 2 clearance)) #:h (- height (* 2 clearance)))))
 (constraints:
  (assert: (>= clearance 4))
  (assert: (= door.y (- (/ box.depth -2) (/ door.thickness 2))))))

(shape: door-unit-sink (width height depth inner-width inner-height inner-depth clearance sink-max-width sink-max-depth)
 (script:
  (named: box (unit-box #:width width #:height height #:depth depth #:inner-width inner-width
                        #:inner-height inner-height #:inner-depth inner-depth))
  (cut: (cuboid #:length sink-max-width
                #:width sink-max-depth
                #:height box.top-panel.thickness
                #:z (- (/ box.height 2) (/ box.top-panel.thickness 2))))
  (named: door (door-18mm #:w (- width (* 2 clearance)) #:h (- height (* 2 clearance)))))
 (constraints:
  (assert: (= sink-max-width (- box.inner-width 50)))
  (assert: (= sink-max-depth (- box.inner-depth 50)))
  (assert: (>= clearance 4))
  (assert: (= door.y (- (/ box.depth -2) (/ door.thickness 2))))))

(shape: kickboard (width height depth)
 (script:
  (named: front-panel (panel-18mm #:l width #:w height #:rot-x 90))
  (named: back-panel (panel-18mm #:l width #:w height #:rot-x 90))
  (named: side-panels ((shape: (nr-of-side-panels thickness dx)
                        (script:
                         (for i in (range nr-of-side-panels)
                          (panel-18mm #:l height #:w (- depth front-panel.thickness back-panel.thickness) #:rot-y 90)))
                        (constraints:
                         (assert: (= thickness front-panel.thickness)))))))
 (constraints:
  (assert: (>= side-panels.nr-of-side-panels 2))
  (assert: (<= (/ width side-panels.nr-of-side-panels) depth))
  (assert: (= back-panel.y (- (/ depth 2) (/ back-panel.thickness 2))))
  (assert: (= front-panel.y (+ (/ depth -2) (/ front-panel.thickness 2))))
  (assert: (linear #:shapes side-panels #:x0 (+ (/ width -2) (/ side-panels.thickness 2)) #:xn (- (/ width 2) (/ side-panels.thickness 2)) #:dx side-panels.dx))))

(constraint: on-top-of (top bottom)
 (assert: (= (- top.z (/ top.height 2))
             (+ bottom.z (/ bottom.height 2)))))

(constraint: beside (left right)
 (assert: (= (- right.x (/ right.width 2))
             (+ left.x (/ left.width 2)))))

(constraint: align-left (item1 item2)
 (assert: (= (- item1.x (/ item1.width 2))
             (- item2.x (/ item2.width 2)))))

(constraint: align-right (item1 item2)
 (assert: (= (+ item1.x (/ item1.width 2))
             (+ item2.x (/ item2.width 2)))))

(constraint: align-back (item1 item2)
 (assert: (= (+ item1.y (/ item1.depth 2))
             (+ item2.y (/ item2.depth 2)))))

(constraint: align-bottom (item1 item2)
 (assert: (= (- item1.z (/ item1.height 2))
             (- item2.z (/ item2.height 2)))))

(shape: kitchen (counter-height unit-h unit-w depth countertop-overhang sink-diameter)
 (script:
  (named: u1 (door-unit #:width unit-w #:height unit-h #:depth depth #:clearance 4))
  (named: u2 (door-unit-sink #:width unit-w #:height unit-h #:depth depth #:clearance 4))
  (named: u3 (drawer-unit #:width unit-w #:height unit-h #:depth depth #:nr-of-drawers 3 #:clearance-lr 4 #:clearance-tb 4))
  (named: u4 (door-unit #:width unit-w #:height 1200 #:depth depth #:clearance 4))
  (named: u5 (door-unit #:width unit-w #:height 500 #:depth depth #:clearance 4))
  (named: kb (kickboard #:width (- (+ u4.x (/ u4.width 2)) (- u1.x (/ u1.width 2))) #:depth depth #:height 120))
  (named: ct (countertop-30mm-circular-sink #:width (+ u1.width u2.width u3.width countertop-overhang)
                                            #:depth (+ depth countertop-overhang)
                                            #:sink-dia sink-diameter)))
 (constraints:
  (assert: (align-bottom #:item1 u1 #:item2 u2))
  (assert: (align-bottom #:item1 u1 #:item2 u3))
  (assert: (align-bottom #:item1 u1 #:item2 u4))
  (assert: (align-back #:item1 u1 #:item2 u2))
  (assert: (align-back #:item1 u1 #:item2 u3))
  (assert: (align-back #:item1 u1 #:item2 u4))
  (assert: (on-top-of #:top u5 #:bottom u4))
  (assert: (= u4.x u5.x))
  (assert: (= u4.y u5.y))
  (assert: (beside #:left u1 #:right u2))
  (assert: (beside #:left u2 #:right u3))
  (assert: (beside #:left u3 #:right u4))
  (assert: (on-top-of #:top u1 #:bottom kb))
  (assert: (align-left #:item1 u1 #:item2 kb))
  (assert: (align-back #:item1 u1 #:item2 kb))
  (assert: (align-right #:item1 u3 #:item2 ct))
  (assert: (align-back #:item1 u3 #:item2 ct))
  (assert: (on-top-of #:top ct #:bottom u1))
  (assert: (= u2.x (+ ct.x ct.sink-x))) ;; Make sure sink aligns with sink-unit
  (assert: (= u2.y (+ ct.y ct.sink-y)))
  (assert: (<= sink-diameter u2.sink-max-width))
  (assert: (<= sink-diameter u2.sink-max-depth))
  (assert: (= unit-h (- counter-height kb.height ct.height)))))

(print: (kitchen #:counter-height 880 #:unit-w 600 #:depth 560 #:countertop-overhang 18 #:sink-diameter 350) "kitchen.stl")