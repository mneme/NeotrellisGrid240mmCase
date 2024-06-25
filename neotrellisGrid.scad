include <BOSL2/std.scad>
$fn=50;

// Insets = https://www.adafruit.com/product/4255
// USB-C Breakout: Sparkfun BOB-15100


// With this to true the outer edge will be 1cm
// and the insets will fit without extra supports.
// This makes it look nice but you'll require a 260mm print pend.
// Set to false it looks worse but fits on a Prusa MK3 (250mm)
fullEdge=true;

// Large round supports rendered to help with print bed adhesion/warping
// Mostly because it was easier than properly calibrating my machine.

printHelp=true;

sq = 60;
trellisThickness=3.4;
connector = 15;
supportHeight=5.6;
supportWidth=4.8;
connectorCutout=2;

edge=fullEdge ? 10 : 5;
bottomThickness=2;
caseHeight=supportHeight+bottomThickness+trellisThickness;

button = 10;
buttonSpacing=5;
topHeight=6;

insertHeight=4.2;
insertRadius=2.1;
insertEdge=5;

// I had some m3 screw lying around. Not a clue from where
// Adapt this to your own screw heads
screwHeadRadius=2.8;
screwHeadHeight=2;
screwRadius=1.6;


translate([-102,0,0])
    case();
translate([102,0,-caseHeight])
    top();


module screwMounts(height){
    for(i=[-1,1]){
        for(j=[-1,0,1]){
            translate([(sq+edge/1.5)*i, (sq*2)*j, 0]){
                translate([-i*insertEdge,0, height/2]){
                    cuboid([insertEdge*2,insertEdge*2,height]);
                }
                cylinder(height, r=insertEdge);
            }
        }
    }
}

module inserts(){
    for(i=[-1,1]){
        for(j=[-1,0,1]){
            if(fullEdge){
                translate([(sq+edge/3)*i, (sq*2+edge/3)*j, caseHeight-insertHeight]){
                    cylinder(100, r=insertRadius);
                }
            }
            else {
                translate([(sq+edge/1.5)*i, (sq*2)*j, caseHeight-insertHeight]){
                    cylinder(100, r=insertRadius);
                }
            }
        }
    }
}


module screwHoles(height){
    for(i=[-1,1]){
        for(j=[-1,0,1]){
            if(fullEdge){
                translate([(sq+edge/3)*i, (sq*2+edge/3)*j, 0]){
                    cylinder(topHeight, r=screwRadius);
                    translate([0,0,height-screwHeadHeight]){
                        cylinder(screwHeadHeight, r=screwHeadRadius);
                    }
                }
            } 
            else {
                translate([(sq+edge/1.5)*i, (sq*2)*j, 0]){
                    cylinder(topHeight, r=screwRadius);
                    translate([0,0,height-screwHeadHeight]){
                        cylinder(screwHeadHeight, r=screwHeadRadius);
                    }
                }
            }
        }
    }
}



module supportPart(){
    difference(){
        cuboid([sq,sq,supportHeight]);
        cuboid([sq-supportWidth, sq-supportWidth, supportHeight+2]);
        translate([0,0,supportHeight-connectorCutout]){
            cuboid([connector, sq+10, supportHeight]);
            cuboid([sq+10, connector, supportHeight]);
        }
    }

}

module support(){
    difference(){
        translate([0,0,bottomThickness+supportHeight/2]){
            translate([-sq/2,-sq*1.5, 0]){
                for(i = [0:3]){
                    translate([0, i*sq, 0])
                        supportPart();
                    translate([sq, i*sq, 0])
                        supportPart();
                }
            }
            
            difference(){
                cuboid([sq*2,sq*4,supportHeight]);
                cuboid([sq*2-supportWidth, sq*4-supportWidth, supportHeight]);
            }
        }
        translate([sq/2,0, bottomThickness]){
            cuboid([35,35, supportHeight*2]);    
        }
    }  
}

module case(){
    difference(){
        union(){
            // Print help
            for(i=[-1,1]){
                for(j=[-1,1]){
                    translate([sq*i, (sq-17.5)*j*2, 0]){
                        if(printHelp) cylinder(h=0.8, r=40);
                    }
                }
            }
            // Supports
            support();
            // External case
            translate([0,0,caseHeight/2]){
                difference(){
                    union(){
                        cuboid([sq*2+edge+5+0.5,sq*4+edge+5,caseHeight], rounding=3, edges="Z");
                        // screw mounts
                        translate([0,0,-caseHeight/2]){
                            if(!fullEdge) screwMounts(caseHeight);
                        }
                    }
                    translate([0,0,bottomThickness])
                        cuboid([sq*2+0.5, sq*4, caseHeight]);
                    
                }
            }
        }
        usbCutout();
        inserts();
    }
}


module top(){
    difference(){
        union(){
            //Print Help
            for(i=[-1,1]){
                for(j=[-1,1]){
                    translate([sq*i, (sq-17.5)*j*2, caseHeight]){
                        if(printHelp) cylinder(h=0.8, r=40);
                    }
                }
            }
            translate([0,0, caseHeight]){
                if(!fullEdge) screwMounts(topHeight);
            }
            translate([0,0,caseHeight+topHeight/2])

                cuboid([sq*2+edge*2+0.5, sq*4+edge*2, topHeight], rounding=5, edges="Z");
        }
        translate([-sq+buttonSpacing*1.5, -sq*2+buttonSpacing*1.5,0]){
            for(i=[0:15]){
                cuboid([button+0.2,button+0.2,200]);
                for(j=[0:7]){
                    translate([j*(button+buttonSpacing), i*(button+buttonSpacing), 0])
                        cuboid([button+0.4,button+0.4,200], rounding=1, edges="Z");
                }
            }
        }
        translate([0,0, caseHeight]){
            screwHoles(topHeight);
        }
    }   
}

module usbCutout(){
    translate([sq-2.7,sq/2,0.0 + bottomThickness]){
        // port
        translate([1,0,1.6/2 + 3.2/2]){
            cuboid([20,9,3.2]);
        }
        //board
        translate([0,0,2.8])
            cuboid([13, 22.5, 6.4
        ]);
    }
}