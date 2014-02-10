#!/usr/bin/tclsh
package require Tk
# Simulation for biocybernetic systems
# by Wei-Lun Chao <bluebat@member.fsf.org>
set version @VERSION@
set Xzahl 9
set Yzahl 3
set Zzahl 120
if [file readable /usr/share/tksimsys/bitmaps/tksimsys.bm] {
  set Dateiname /usr/share/tksimsys/models
  set bmdir /usr/share/tksimsys/bitmaps
} else {
  set Dateiname models
  set bmdir bitmaps
}
set tmpdir /tmp
set Amp 32
set Szahl 6
set lpcom "evince"
#set weiter 0
set Swert 1
set Sout 0
set Nout ""
set Sline 1

set GFont {Luxi 10 bold}
set MFont {Luxi 10 normal}
set KFont {Luxi 7 normal}
#====================== arguments =========================
for {set x 0} {$x < $argc} {incr x} {
  switch -- [lindex $argv $x] {
    -noi {set weiter 1}
    -nov {set Swert 0}
    -nos {set Sline 0}
    -o {set Nout [lindex $argv [incr x]] ; set Sout 1}
    -x {set Xzahl [lindex $argv [incr x]]}
    -y {set Yzahl [lindex $argv [incr x]]}
    -t {set Zzahl [lindex $argv [incr x]]}
    -a {set Amp [lindex $argv [incr x]]}
    -p {set Szahl [lindex $argv [incr x]]}
    -mddir {set Dateiname [lindex $argv [incr x]]}
    -bmdir {set bmdir [lindex $argv [incr x]]}
    -tmpdir {set tmpdir [lindex $argv [incr x]]}
    -lpc {set lpcom [lindex $argv [incr x]]}
    default {puts stderr {usage: tksimsys [options]
-x %d	     Number of X [9]
-y %d	     Number of Y [3]
-t %d	     Duration [120]
-a %f	     Amplify factor [32]
-p %d	     Number of outputs for a page [6]
-mddir %s    Directory of the models [/usr/share/tksimsys/models]
-bmdir %s    Directory of the bitmaps [/usr/share/tksimsys/bitmaps]
-tmpdir %s   Directory for the temporary files [/tmp]
-lpc %s      Command for print [envice]
-o %s        File name for output [standard output]
-nov	     Don't show values
-noi	     Don't show the initial menu
-nos	     Don't use stippled lines}
      exit 1
    }
  }
}
#============= initial ===============================
wm title . "TkSimSys"
wm resizable . 0 0
set BG [. cget -background]
wm iconbitmap . @$bmdir/tksimsys.bm
#============= bitmaps ====================================
foreach bmname {leere nnwn5 nnnw5 cuws9 cuwn5
    xe1 xs1 xn1 xi1 xd1 xc1 xr1 xz1 xe4 xs4 xn4 xi4 xd4 xc4 xr4 xz4
    pfw1 pfe2 pfw4 pfe8 pfs1 pfn2 pfn1 pfw8 pfn5 pfn6 pfn4 pfs8 pfe4 pfs2
    pfw5 pfe6 pfw9 pfe10 pfen6 pfws9 pfw12 pfe12 pfw13 pfwn5 pfes10
    tpw1 tpe2 hpw1 hpe2 igw1 ige2 dfw1 dfe2
    grw1 gre2 vsw1 vse2 epw1 epe2 tze2 tzw1 snw1 sne2
    adwn1 adws1 aden2 ades2 adns1 adns2 adwns1 suwn1 suws1 
    mpws1 mpwn1 mpns1 mpns2 mpwns1 mpes2 mpen2} {
  image creat bitmap $bmname -file $bmdir/$bmname.bm -foreground black
}
foreach bmname {
    auswblack auswblue auswred ausworange auswgreen3
    ausnblack ausnblue ausnred ausnorange ausngreen3} {
  image creat bitmap $bmname -file $bmdir/[string range $bmname 0 3].bm \
    -foreground [string range $bmname 4 end]
}
#============= procedures =================================
set Randseed [pid]
proc random {bereich} {
  global Randseed
  set Randseed [expr ($Randseed * 9301 + 49297) % 233280]
  return [expr int($bereich * ($Randseed / double(233280)))]
}

set pflist {ws9 en6 0 0 0 0 w1 e2 0 0 e4 s1 w4 s2 w5 e6 \
            0 0 n1 e8 w8 n2 w9 e10 n4 s8 n5 e12 w12 n6 0 w13 wn5 es10}
set wlist {xe xs xn xd tp hp ep vs tz nn sn au}
proc Setzen_Zelle {x y e w o} {
  global W bmdir pflist Swert wlist
  set W($x,$y,z) $e
  set farbe black
  switch -glob $e {
    pf* {
      set Zelle pf[expr [lsearch $pflist [string range $e 2 end]]/2]}
    nn* {set Zelle nn15}
    cu* {set Zelle cu15}
    aus* {
      set Zelle [string range $e 0 3]
      set farbe [string range $e 4 end]}
    default {set Zelle $e}
  }
  if ![file isfile $bmdir/$Zelle.bm] {set Zelle leere}
  .c itemconfig $W($x,$y,i) -bitmap @$bmdir/$Zelle.bm -foreground $farbe
  .c itemconfig $W($x,$y,t) -text ""
  set w [string trim $w]
  set W($x,$y,e) [expr [lsearch $wlist [string range $e 0 1]]<0?1:"$w"]
  set o [string trim $o]
  set W($x,$y,o) [expr [string compare leere $e]?"$o":""]
  switch $Swert {
    1 {if [lsearch $wlist [string range $e 0 1]]>=0 {
         .c itemconfig $W($x,$y,t) -text $W($x,$y,e) -fill blue}}
    2 {if [string compare leere $e] {
         .c itemconfig $W($x,$y,t) -text $W($x,$y,o) -fill red}}
  }
}

proc Redraw {} {
  global Element wlist
  .ff.elel config -image $Element
  if [lsearch $wlist [string range $Element 0 1]]<0 {
    .ff.were config -state disabled -show "-"} else {
    .ff.were config -state normal -show ""
  }
  if [string compare leere $Element] {
    .ff.orde config -state normal -show ""} else {
    .ff.orde config -state disabled -show "-"
  }
}

proc Reshow {} {
  global W Xzahl Yzahl
  for {set x 1} {$x<=$Xzahl} {incr x} {
    for {set y 1} {$y<=$Yzahl} {incr y} {
      Setzen_Zelle $x $y $W($x,$y,z) $W($x,$y,e) $W($x,$y,o)
    }
  }
}

proc Sehen_Zelle {x y} {
  global W Element Wert Order Preorder
  set Element $W($x,$y,z)
  if [string compare leere $Element] {
    set Preorder [lindex [split $Order ,] end]
  }
  set Order $W($x,$y,o)
  set Wert $W($x,$y,e)
  Redraw
}

proc Anfangen {x y} {
  global W Zeit KS tk_version
  switch [string index $W($x,$y,z) 1] {
    e {
      set SinWert [expr sin($Zeit*6.2831853/$W($x,$y,e))]
      set w [expr $SinWert<0 ? -1.0 : 1.0]
    }
    n {
      set t [expr ($Zeit-1)*2.0/$W($x,$y,e)]
      set w [expr int($t)==($t)?(int($t/2)==$t/2?1.0:-1.0):0.0]
    }
    s {set w [expr sin($Zeit*6.2831853/$W($x,$y,e))]}
    d {
      set SinWert [expr sin($Zeit*6.2831853/$W($x,$y,e))]
      set w [expr 2 *asin($SinWert) /3.14159265]
    }
    i {set w [expr ($Zeit-1)?0.0:1.0]}
    c {set w 1.0}
    r {set w [expr $tk_version<8.0?[random 2.0]-1:rand()*2.0-1]}
    z {set w $KS}
  }
  switch [string index $W($x,$y,z) 2] {
    1 {set W([expr $x+1],$y,w) $w}
    4 {set W($x,[expr $y+1],n) $w}
  }
}

proc Rechnen {x y} {
  global W Zeit Zzahl
  set Z $W($x,$y,z)
  set xx [expr $x+1]
  set yy [expr $y+1]
  switch $Z {
    pfw1 {set W($xx,$y,w) $W($x,$y,w)}
    pfe2 {set W($x,$y,w) $W($xx,$y,w)}
    pfn1 {set W($xx,$y,w) $W($x,$y,n)}
    pfe8 {set W($x,$y,n) $W($xx,$y,w)}
    pfw8 {set W($x,$y,n) $W($x,$y,w)}
    pfn2 {set W($x,$y,w) $W($x,$y,n)}
    pfw4 {set W($x,$yy,n) $W($x,$y,w)}
    pfs2 {set W($x,$y,w) $W($x,$yy,n)}
    pfs1 {set W($xx,$y,w) $W($x,$yy,n)}
    pfe4 {set W($x,$yy,n) $W($xx,$y,w)}
    pfn4 {set W($x,$yy,n) $W($x,$y,n)}
    pfs8 {set W($x,$y,n) $W($x,$yy,n)}
    tpw1 {
      set W($x,$y,d) [expr $W($x,$y,d) + $W($x,$y,w) - $W($xx,$y,w)]
      set W($xx,$y,w) [expr $W($x,$y,d) / $W($x,$y,e)]
    }
    tpe2 {
      set W($x,$y,d) [expr $W($x,$y,d) + $W($xx,$y,w) - $W($x,$y,w)]
      set W($x,$y,w) [expr $W($x,$y,d) / $W($x,$y,e)]
    }
    hpw1 {
      set W($x,$y,d) [expr $W($x,$y,d) + $W($xx,$y,w)]
      set W($xx,$y,w) [expr $W($x,$y,w) - $W($x,$y,d) / $W($x,$y,e)]
    }
    hpe2 {
      set W($x,$y,d) [expr $W($x,$y,d) + $W($x,$y,w)]
      set W($x,$y,w) [expr $W($xx,$y,w) - $W($x,$y,d) / $W($x,$y,e)]
    }
    igw1 {set W($xx,$y,w) [expr $W($xx,$y,w) + $W($x,$y,w)]}
    ige2 {set W($x,$y,w) [expr $W($x,$y,w) + $W($xx,$y,w)}
    dfw1 {
      set W($xx,$y,w) [expr $W($x,$y,w) - $W($x,$y,d)]
      set W($x,$y,d) $W($x,$y,w)
    }
    dfe2 {
      set W($x,$y,w) [expr $W($xx,$y,w) - $W($x,$y,d)]
      set W($x,$y,d) $W($xx,$y,w)
    }
    grw1 {set W($xx,$y,w) [expr $W($x,$y,w)>0 ? $W($x,$y,w) : 0]}
    gre2 {set W($x,$y,w) [expr $W($xx,$y,w)>0 ? $W($xx,$y,w) : 0]}
    snw1 {
      if $W($x,$y,w)>$W($x,$y,e) {set W($xx,$y,w) $W($x,$y,e)
      } elseif $W($x,$y,w)<-$W($x,$y,e) {set W($xx,$y,w) -$W($x,$y,e)
      } else {set W($xx,$y,w) $W($x,$y,w)}
    }
    sne2 {
      if $W($xx,$y,w)>$W($x,$y,e) {set W($x,$y,w) $W($x,$y,e)
      } elseif $W($xx,$y,w)<-$W($x,$y,e) {set W($x,$y,w) -$W($x,$y,e)
      } else {set W($x,$y,w) $W($xx,$y,w)}
    }
    vsw1 {set W($xx,$y,w) [expr $W($x,$y,w) * $W($x,$y,e)]}
    vse2 {set W($x,$y,w) [expr $W($xx,$y,w) * $W($x,$y,e)]}
    epw1 {set W($xx,$y,w) [expr pow($W($x,$y,w),$W($x,$y,e))]}
    epe2 {set W($x,$y,w) [expr pow($W($xx,$y,w),$W($x,$y,e))]}
    tzw1 {
      set W($x,$y,0) $W($x,$y,w)
      set t [expr $W($x,$y,e)>$Zzahl ? $Zzahl : $W($x,$y,e)]
      set W($xx,$y,w) $W($x,$y,$t)
      while {$t>0} {set W($x,$y,$t) $W($x,$y,[incr t -1])}
    }
    tze2 {
      set W($x,$y,0) $W($xx,$y,w)
      set t [expr $W($x,$y,e)>$Zzahl ? $Zzahl : $W($x,$y,e)]
      set W($x,$y,w) $W($x,$y,$t)
      while {$t>0} {set W($x,$y,$t) $W($x,$y,[incr t -1])}
    }
    pfws9 {set W($xx,$y,w) $W($x,$y,w) ; set W($x,$y,n) $W($x,$yy,n)}
    pfen6 {set W($x,$y,w) $W($xx,$y,w) ; set W($x,$yy,n) $W($x,$y,n)}
    pfwn5 {set W($xx,$y,w) $W($x,$y,w) ; set W($x,$yy,n) $W($x,$y,n)}
    pfes10 {set W($x,$y,w) $W($xx,$y,w) ; set W($x,$y,n) $W($x,$yy,n)}
    pfw5 {set W($xx,$y,w) $W($x,$y,w) ; set W($x,$yy,n) $W($x,$y,w)}
    pfe6 {set W($x,$y,w) $W($xx,$y,w) ; set W($x,$yy,n) $W($xx,$y,w)}
    pfw9 {set W($xx,$y,w) $W($x,$y,w) ; set W($x,$y,n) $W($x,$y,w)}
    pfe10 {set W($x,$y,w) $W($xx,$y,w) ; set W($x,$y,n) $W($xx,$y,w)}
    pfw12 {set W($x,$y,n) $W($x,$y,w) ; set W($x,$yy,n) $W($x,$y,w)}
    pfn6 {set W($x,$y,w) $W($x,$y,n) ; set W($x,$yy,n) $W($x,$y,n)}
    pfe12 {set W($x,$y,n) $W($xx,$y,w) ; set W($x,$yy,n) $W($xx,$y,w)}
    pfn5 {set W($xx,$y,w) $W($x,$y,n) ; set W($x,$yy,n) $W($x,$y,n)}
    pfw13 {
      set W($x,$y,n) $W($x,$y,w)
      set W($x,$yy,n) $W($x,$y,w)
      set W($xx,$y,w) $W($x,$y,w)
    }
    adws1 {set W($xx,$y,w) [expr $W($x,$y,w) + $W($x,$yy,n)]}
    adwn1 {set W($xx,$y,w) [expr $W($x,$y,w) + $W($x,$y,n)]}
    aden2 {set W($x,$y,w) [expr $W($xx,$y,w) + $W($x,$y,n)]}
    ades2 {set W($x,$y,w) [expr $W($xx,$y,w) + $W($x,$yy,n)]}
    adns1 {set W($xx,$y,w) [expr $W($x,$y,n) + $W($x,$yy,n)]}
    adns2 {set W($x,$y,w) [expr $W($x,$y,n) + $W($x,$yy,n)]}
    adwns1 {set W($xx,$y,w) [expr $W($x,$y,w) + $W($x,$yy,n) + $W($x,$y,n)]}
    suws1 {set W($xx,$y,w) [expr $W($x,$y,w) - $W($x,$yy,n)]}
    suwn1 {set W($xx,$y,w) [expr $W($x,$y,w) - $W($x,$y,n)]}
    mpws1 {set W($xx,$y,w) [expr $W($x,$y,w) * $W($x,$yy,n)]}
    mpes2 {set W($x,$y,w) [expr $W($xx,$y,w) * $W($x,$yy,n)]}
    mpwn1 {set W($xx,$y,w) [expr $W($x,$y,w) * $W($x,$y,n)]}
    mpen2 {set W($x,$y,w) [expr $W($xx,$y,w) * $W($x,$y,n)]}
    mpns1 {set W($xx,$y,w) [expr $W($x,$y,n) * $W($x,$yy,n)]}
    mpns2 {set W($x,$y,w) [expr $W($x,$y,n) * $W($x,$yy,n)]}
    mpwns1 {set W($xx,$y,w) [expr $W($x,$y,w) * $W($x,$yy,n) * $W($x,$y,n)]}
    nnwn5 {
      set W($xx,$y,w) $W($x,$y,w)
      set W($x,$yy,n) [expr $W($x,$y,w) * $W($x,$y,e) + $W($x,$y,n)]
    }
    nnnw5 {
      set W($x,$yy,n) $W($x,$y,n)
      set W($xx,$y,w) [expr $W($x,$y,n) * $W($x,$y,e) + $W($x,$y,w)]
    }
    cuws9 {
      set W($xx,$y,w) $W($x,$y,w)
      set W($x,$y,n) [expr !$W($x,$y,w) * $W($x,$yy,n)]
    }
    cuwn5 {
      set W($x,$yy,n) $W($x,$y,n)
      set W($xx,$y,w) [expr !$W($x,$y,n) * $W($x,$y,w)]
    }
  }
}

proc Zeichnen {x y} {
  global W X0 Amp Zeit Brechen Swert KFont Sout Fout Sline Zzahl einx
  set Y0 [expr $W($x,$y,e)*($Amp+5)+15]
  set Farbe [string range $W($x,$y,z) 4 end]
  if $Zeit==1 {
    .bc create line [expr $X0-8] $Y0 $X0 $Y0
    .bc create text [expr $X0-1] $Y0 -text [expr $Swert?$W($x,$y,e):""] \
      -anchor se -fill $Farbe -font $KFont
    set W($x,$y,d) $Y0
  }
  set z [expr $X0+$Zeit*$einx]
  set R [string index $W($x,$y,z) 3]
  if $Sout {puts -nonewline $Fout " $W($x,$y,$R)"}
  set NeuY [expr $Y0-$W($x,$y,$R)*$Amp]
  if $Sline {
    .bc create line [expr $z-1] $NeuY $z $NeuY -fill $Farbe
  } else {
    .bc create line [expr $z-$einx] $W($x,$y,d) $z $NeuY -fill $Farbe
    set W($x,$y,d) $NeuY
  }
  if ($Brechen||$Zeit==$Zzahl)&&$Swert {
    .bc create text $z $NeuY -anchor w -text [format %.2f $W($x,$y,$R)] \
      -fill $Farbe -font $KFont
  }
}

set X0 20
proc XYsys {Y} {
  global X0 Amp GFont MFont Zzahl einx
  set einx [expr 240/$Zzahl?240/$Zzahl:1]
  set X [expr $Zzahl*$einx+$X0]
  set Y [expr $Y*($Amp+5)+$Amp+25]
  .bc create line $X0 10 $X0 $Y
  .bc create text [expr $X0-8] 30 -text A -font $GFont
  .bc create line [expr $X0-8] 22 [expr $X0-8] 5 -arrow last
  for {set x 0} {$x <= $Zzahl} {incr x [expr ($Zzahl/25?$Zzahl/25:1)*5]} {
    .bc create line [expr $x*$einx+$X0] [expr $Y+6] [expr $x*$einx+$X0] $Y
    .bc create text [expr $x*$einx+$X0] [expr $Y+14] -text $x -font $MFont
  }
  .bc create line $X0 $Y [expr $X+10] $Y
  set Y [expr $Y+26]
  .bc create text [expr $X-13] $Y -text t -font $GFont
  .bc create line [expr $X-7] $Y [expr $X+15] $Y -arrow last
  .bc config -height [expr $Y+4] -width [expr $X+20]
}

proc Datei {F} {
  global GFont MFont Dateiname Altname
  set Altname $Dateiname
  .f.comb config -state disabled
  wm title [toplevel .q] "Question"
  if [string compare save $F] {
    frame .q.f -relief raised -bd 2
    checkbutton .q.f.rb -text Replace -var ersetzen -font $GFont -selectc black
    label .q.f.xl -text "at  cell: " -font $GFont
    entry .q.f.xe -textvar loadx -font $MFont -width 3
    label .q.f.yl -text "," -font $GFont
    entry .q.f.ye -textvar loady -font $MFont -width 3
    pack .q.f.rb .q.f.xl .q.f.xe .q.f.yl .q.f.ye -side left
    pack .q.f -fill x
  }
  label .q.l -text "File name to $F:" -font $GFont
  entry .q.e -textvar Dateiname -font $MFont -width [string length $Dateiname]
  bind .q.e <KeyPress-Return> "Dateiok $F"
  pack .q.l .q.e [frame .q.bf] -fill x
  button .q.bf.ok -text OK -font $GFont -command "Dateiok $F"
  label .q.bf.ml -text "" -font $GFont
  button .q.bf.no -text Cancel -font $GFont -command "Dateiok no"
  pack .q.bf.ok .q.bf.ml .q.bf.no -side left -expand 1
}

set ersetzen 1
set loadx 1
set loady 1
proc Dateiok {F} {
  global W Dateiname Altname ersetzen loadx loady Xzahl Yzahl NeuX NeuY bmdir
  switch $F {
    load {
      if [file isfile $Dateiname] {
        destroy .q
        .f.comb config -state normal
        set mddatei [open $Dateiname r]
        set l [split [gets $mddatei]]
        set NeuX [expr [lindex $l 0]+$loadx-1]
        set NeuY [expr [lindex $l 1]+$loady-1]
        if $ersetzen {
          Schieben model
          wm title . "tksimsys: [lindex [split $Dateiname /] end]"
        } else {
          set NeuX [expr $NeuX<$Xzahl?$Xzahl:$NeuX]
          set NeuY [expr $NeuY<$Yzahl?$Yzahl:$NeuY]
        }
        Zoomdo go
        while {[gets $mddatei l]!=-1} {
          set l [split $l]
          set x [expr [lindex $l 0]+$loadx-1]
          set y [expr [lindex $l 1]+$loady-1]
          if $x>0&&$x<=$Xzahl&&$y>0&&$y<=$Yzahl {
            Setzen_Zelle $x $y [lindex $l 2] [lindex $l 3] [lindex $l 4]
          }
        }
        close $mddatei
      } else {
        .q.bf.ml config -text "Read error!"
      }
    }
    save {
      if ![file isdir $Dateiname]&&[file isdir [file dirname $Dateiname]] {
        destroy .q
        .f.comb config -state normal
        wm title . "tksimsys: [lindex [split $Dateiname /] end]"
        set mddatei [open $Dateiname w]
        puts $mddatei "$Xzahl $Yzahl"
        for {set x 1} {$x<=$Xzahl} {incr x} {
          for {set y 1} {$y<=$Yzahl} {incr y} {
            if [string compare leere $W($x,$y,z)] {
              puts $mddatei "$x $y $W($x,$y,z) $W($x,$y,e) $W($x,$y,o)"
            }
          }
        }
        close $mddatei
      } else {
        .q.bf.ml config -text "Write error!"
      }
    }
    no {
      set Dateiname $Altname
      destroy .q
      .f.comb config -state normal
    }
  }
}

proc Ueber {} {
  global GFont MFont version
  .f.comb config -state disabled
  wm title [toplevel .about] About
  message .about.me -justify center -text "
TKSimSys  $version

Simulation for Biocybernetic Systems

Wei-Lun Chao <bluebat@member.fsf.org>

GPL (c) 1997,1998,2005
" -font $GFont -relief raised
  message .about.tip -justify center -aspect 250 -text {
Using three mouse buttons
to design the model
Using space and s-space keys
to control the last input element
  } -font $MFont -relief raised
  button .about.b -text Close -font $GFont -command {
    destroy .about
    .f.comb config -state normal
  }
  pack .about.me .about.tip .about.b -fill x -expand 1 
}

proc Schieben {F} {
  global W Xzahl Yzahl Order
  switch $F {
    model {
      for {set x 1} {$x<=$Xzahl} {incr x} {
	for {set y 1} {$y<=$Yzahl} {incr y} {
          Setzen_Zelle $x $y leere 1 ""
        }
      }
      wm title . tksimsys
    }
    order {
      set Order ""
      for {set x 1} {$x<=$Xzahl} {incr x} {
	for {set y 1} {$y<=$Yzahl} {incr y} {
          Setzen_Zelle $x $y $W($x,$y,z) $W($x,$y,e) ""
        }
      }
    }
    up {
      for {set x 1} {$x<=$Xzahl} {incr x} {
        set z $W($x,1,z)
        set e $W($x,1,e)
        set o $W($x,1,o)
	for {set y 1} {$y<$Yzahl} {incr y} {
          set yy [expr $y+1]
          Setzen_Zelle $x $y $W($x,$yy,z) $W($x,$yy,e) $W($x,$yy,o)
        }
        Setzen_Zelle $x $Yzahl $z $e $o
      }
    }
    down {
      for {set x 1} {$x<=$Xzahl} {incr x} {
        set z $W($x,$Yzahl,z)
        set e $W($x,$Yzahl,e)
        set o $W($x,$Yzahl,o)
        for {set y $Yzahl} {$y>1} {incr y -1} {
          set yy [expr $y-1]
          Setzen_Zelle $x $y $W($x,$yy,z) $W($x,$yy,e) $W($x,$yy,o)
        }
        Setzen_Zelle $x 1 $z $e $o
      }
    }
    right {
      for {set y 1} {$y<=$Yzahl} {incr y} {
        set z $W($Xzahl,$y,z)
        set e $W($Xzahl,$y,e)
        set o $W($Xzahl,$y,o)
        for {set x $Xzahl} {$x>1} {incr x -1} {
          set xx [expr $x-1]
          Setzen_Zelle $x $y $W($xx,$y,z) $W($xx,$y,e) $W($xx,$y,o)
        }
        Setzen_Zelle 1 $y $z $e $o
      }
    }
    left {
      for {set y 1} {$y<=$Yzahl} {incr y} {
        set z $W(1,$y,z)
        set e $W(1,$y,e)
        set o $W(1,$y,o)
       for {set x 1} {$x<$Xzahl} {incr x} {
          set xx [expr $x+1]
          Setzen_Zelle $x $y $W($xx,$y,z) $W($xx,$y,e) $W($xx,$y,o)
        }
        Setzen_Zelle $Xzahl $y $z $e $o
      }
    }
  }
}

proc ZoomQ {} {
  global GFont MFont Xzahl Yzahl Zzahl Amp Sline Sout Nout
  global NeuX NeuY NeuZ NeuA NeuS NeuO NeuN
  set NeuX $Xzahl
  set NeuY $Yzahl
  set NeuZ $Zzahl
  set NeuA $Amp
  set NeuS $Sline
  set NeuO $Sout
  set NeuN $Nout
  .f.comb config -state disabled
  wm title [toplevel .q] "Question"
  frame .q.f -relief raised -bd 2
  frame .q.ff -relief raised -bd 2
  frame .q.cf -relief raised -bd 2
  frame .q.nf -relief raised -bd 2
  pack .q.f .q.ff .q.cf .q.nf [frame .q.bf] -fill x
  label .q.f.xl -text "Width:" -font $GFont
  entry .q.f.xe -textvar NeuX -font $MFont -width 3
  label .q.f.yl -text "Height:" -font $GFont
  entry .q.f.ye -textvar NeuY -font $MFont -width 3
  pack .q.f.xl .q.f.xe .q.f.yl .q.f.ye -side left -expand 1
  label .q.ff.zl -text "Duration:" -font $GFont
  entry .q.ff.ze -textvar NeuZ -font $MFont -width 4
  label .q.ff.al -text "Amplify:" -font $GFont
  entry .q.ff.ae -textvar NeuA -font $MFont -width 3
  pack .q.ff.al .q.ff.ae .q.ff.zl .q.ff.ze -side left -expand 1
  checkbutton .q.cf.cl -text "Stippled line" -var NeuS -font $GFont
  checkbutton .q.cf.so -text "Data output" -var NeuO -font $GFont
  pack .q.cf.cl .q.cf.so -side left
  label .q.nf.ol -text "Output file:" -font $GFont
  entry .q.nf.oe -textvar NeuN -font $MFont -width 6
  label .q.nf.sl -text "(stdout)" -font $GFont
  pack .q.nf.ol .q.nf.oe .q.nf.sl -side left -expand 1
  button .q.bf.ok -text OK -font $GFont -command "Zoomdo ok"
  label .q.bf.ml -text "" -font $GFont
  button .q.bf.no -text Cancel -font $GFont -command "Zoomdo no"
  pack .q.bf.ok .q.bf.ml .q.bf.no -side left -expand 1
}

proc Zoomdo {F} {
  global W Xzahl Yzahl Zzahl Amp Sline Sout Nout
  global NeuX NeuY NeuZ NeuA NeuS NeuO NeuN
  if [string compare no $F] {
    set NeuX [expr int(abs($NeuX))]
    set NeuY [expr int(abs($NeuY))]
    if $NeuX*$NeuY {
      set zx [expr $NeuX>$Xzahl ? 2 : ($NeuX<$Xzahl ? 1 : 0)]
      set zy [expr $NeuY>$Yzahl ? 2 : ($NeuY<$Yzahl ? 1 : 0)]
      switch [expr $zx*3+$zy] {
        1 {
          for {set y [expr $NeuY+1]} {$y<=$Yzahl} {incr y} {
            for {set x 1} {$x<=$Xzahl} {incr x} {Zoom in $x $y}}
        }
        2 {
          for {set y [expr $Yzahl+1]} {$y<=$NeuY} {incr y} {
            for {set x 1} {$x<=$NeuX} {incr x} {Zoom out $x $y}}
        }
        3 {
          for {set x [expr $NeuX+1]} {$x<=$Xzahl} {incr x} {
            for {set y 1} {$y<=$Yzahl} {incr y} {Zoom in $x $y}}
        }
        4 {
          for {set x [expr $NeuX+1]} {$x<=$Xzahl} {incr x} {
            for {set y 1} {$y<=$Yzahl} {incr y} {Zoom in $x $y}}
          for {set y [expr $NeuY+1]} {$y<=$Yzahl} {incr y} {
            for {set x 1} {$x<=$NeuX} {incr x} {Zoom in $x $y}}
        }
        5 {
          for {set x [expr $NeuX+1]} {$x<=$Xzahl} {incr x} {
            for {set y 1} {$y<=$Yzahl} {incr y} {Zoom in $x $y}}
          for {set y [expr $Yzahl+1]} {$y<=$NeuY} {incr y} {
            for {set x 1} {$x<=$NeuX} {incr x} {Zoom out $x $y}}
        }
        6 {
          for {set x [expr $Xzahl+1]} {$x<=$NeuX} {incr x} {
            for {set y 1} {$y<=$NeuY} {incr y} {Zoom out $x $y}}
        }
        7 {
          for {set x [expr $Xzahl+1]} {$x<=$NeuX} {incr x} {
            for {set y 1} {$y<=$NeuY} {incr y} {Zoom out $x $y}}
          for {set y [expr $NeuY+1]} {$y<=$Yzahl} {incr y} {
            for {set x 1} {$x<=$Xzahl} {incr x} {Zoom in $x $y}}
        }
        8 {
          for {set x [expr $Xzahl+1]} {$x<=$NeuX} {incr x} {
            for {set y 1} {$y<=$NeuY} {incr y} {Zoom out $x $y}}
          for {set y [expr $Yzahl+1]} {$y<=$NeuY} {incr y} {
            for {set x 1} {$x<=$Xzahl} {incr x} {Zoom out $x $y}}
        }
      }
      set Xzahl $NeuX
      set Yzahl $NeuY
      .c config -width [expr $Xzahl*31+2] -height [expr $Yzahl*31+2]
      if ![string compare ok $F] {
        destroy .q
	set Zzahl [expr int(abs($NeuZ))]
	set Amp [expr int(abs($NeuA))]
	set Sline $NeuS
	set Sout $NeuO
	set Nout $NeuN
      }
      .f.comb config -state normal
    } else {
      if ![string compare ok $F] {.q.bf.ml config -text "Illegal Value(s)!"}
    }
  } else {
    destroy .q
    .f.comb config -state normal
  }
}

proc Zoom {z x y} {
  global W KFont bmdir BG
  if [string compare in $z] {
    set xx [expr $x*31-12]
    set yy [expr $y*31-12]
    set W($x,$y,t) [.c create text $xx [expr $yy+13] -text "" -font $KFont]
    set W($x,$y,i) [.c create bitmap $xx $yy -bitmap @$bmdir/leere.bm -backg {}]
    set i $W($x,$y,i)
    .c bind $i <Leave> ".c itemconfig $i -backg {}"
    .c bind $i <Enter> ".c itemconfig $i -backg [.c cget -selectbackg]"
    .c bind $i <ButtonPress-1> "Setzen_Zelle $x $y \$Element \$Wert \$Order"
    .c bind $i <ButtonPress-2> "Sehen_Zelle $x $y ; Incr_Order 0 ; \
                           Setzen_Zelle $x $y \$Element \$Wert \$Order"
    .c bind $i <ButtonPress-3> "Sehen_Zelle $x $y"
    Setzen_Zelle $x $y leere 1 ""
  } else {
    .c delete $W($x,$y,i)
    .c delete $W($x,$y,t)
  }
}

set Preorder 0
proc Incr_Order {v} {
  global Order Preorder
  if [string compare disabled [.ff.orde cget -state]] {
    if [string compare "" $Order] {set o [lindex [split $Order ,] end]
    } else {set o [lindex [split $Preorder ,] end]}
    switch -- $v {
      1 {set Order [expr $o+1]}
      -1 {if $o {set Order [expr $o-1]}}
      0 {
        if [string compare "" $Order] {
          set Order [expr $Preorder+1]} else {set Order [expr $o+1]}
      }
    }
  }
}

set Seite 0
proc Druck {} {
  global Seite tmpdir Szahl lpcom
  if $Seite {set PSdatei [open $tmpdir/ss[pid].ps a]} else {
    set PSdatei [open $tmpdir/ss[pid].ps w]}
  set S [expr $Szahl%2 ? $Szahl+1 : $Szahl]
  foreach w {.c .bc} {
    set pa [expr $Seite%2?"sw":"nw"]
    set px [expr $Seite<$S ? 40 : 320]
    set py [expr 831-($Seite%$S+1)/2*int(1640/$S)]
    set pw [expr [$w cget -width]*0.75]
    set pw [expr $pw>260?260:int($pw)]
    set tmpdatei $tmpdir/ss[pid].tmp
    $w postscript -file $tmpdatei -pagew $pw -pagea $pa -pagex $px -pagey $py
    set tmpdatei [open $tmpdatei]
    set neu 1
    while {![eof $tmpdatei]} {
      gets $tmpdatei l
      if $Seite {
    	while {$neu} {
    	  gets $tmpdatei l
    	  set neu [string compare save $l]
    	}
      } else {
    	if [string first BoundingBox $l]==2 {set l "%%BoundingBox 0 0 595 842"}
      }
      if $Seite!=[expr $Szahl*2-1] {
    	if ![string compare "restore showpage" $l] {
    	  while {![eof $tmpdatei]} {gets $tmpdatei l}
    	  set l restore
    	}
      }
      puts $PSdatei $l
    }
    close $tmpdatei
    incr Seite
  }
  close $PSdatei
  if $Seite==[expr $Szahl*2] {eval exec $lpcom $tmpdir/ss[pid].ps &}
  set Seite [expr $Seite % ($Szahl*2)]
  .f.comb.m entryconfig 12 -label "Print [expr $Seite/2+1]/$Szahl"
}

proc Start {X Y Z} {
  global W Brechen Zeit Zzahl KS Sout Nout Fout
  set Brechen 0
  set KS 0.0
  set AxisY 0
  set Ezahl 0
  .bc delete all
  focus -force .
  .f.sb config -text Stop -command {
    set Brechen 1
    .f.sb config -text Start -command {Start $Xzahl $Yzahl $Zzahl}
  }
  for {set x 1} {$x<=$X} {incr x} {set W($x,[expr $Y+1],n) 0}
  for {set y 1} {$y<=$Y} {incr y} {set W([expr $X+1],$y,w) 0}
  for {set o 1} {$o<=$X*$Y} {incr o} {set E($o,x) 0 ; set E($o,y) 0}
  set W(0,0,z) leere
  for {set x 1} {$x <= $X} {incr x} {
    for {set y 1} {$y <= $Y} {incr y} {
      set W($x,$y,n) 0
      set W($x,$y,w) 0
      set W($x,$y,d) 0
      foreach o [split $W($x,$y,o) ,] {
        if ![string compare "" $o] {set o 0}
        set E($o,x) $x
        set E($o,y) $y
        if $Ezahl<$o {set Ezahl $o}
      }
      if [string match tz* $W($x,$y,z)] {
        for {set Zeit 0} {$Zeit<=$Zzahl} {incr Zeit} {set W($x,$y,$Zeit) 0}
      }
      if [string match aus* $W($x,$y,z)] {
        if $W($x,$y,e)>$AxisY {set AxisY $W($x,$y,e)}
      }
    }
  }
  if $Sout {if [string compare "" $Nout] {
    set Fout [open $Nout a]} else {set Fout stdout}
  }
  XYsys $AxisY
  for {set Zeit 1} {$Zeit<=$Zzahl} {incr Zeit} {
    if $Sout {
      puts $Fout ""
      puts -nonewline $Fout $Zeit
    }
    for {set o 1} {$o<=$Ezahl} {incr o} {
      set x $E($o,x)
      set y $E($o,y)
      switch -glob $W($x,$y,z) {
        leere {}
        x* {Anfangen $x $y}
        aus* {Zeichnen $x $y}
        default {Rechnen $x $y}
      }
    }
    if $Brechen break else update
  }
  if $Sout {
    puts $Fout ""
    if [string compare stdout $Fout] {close $Fout}
  }
  .f.sb config -text Start -command {Start $Xzahl $Yzahl $Zzahl}
}
#============= frame .f ===================================
frame .f -relief groove -bd 2

menubutton .f.comb -text Command -font $GFont -relief raised -menu .f.comb.m
set m [menu .f.comb.m -tearoff no]
$m add command -label "Load..." -font $GFont -command {Datei load}
$m add command -label "Save..." -font $GFont -command {Datei save}
$m add command -label "Setting..." -font $GFont -command ZoomQ
$m add separator
$m add command -label "Shift Up" -font $GFont -command {Schieben up}
$m add command -label "Shift Down" -font $GFont -command {Schieben down}
$m add command -label "Shift Right" -font $GFont -command {Schieben right}
$m add command -label "Shift Left" -font $GFont -command {Schieben left}
$m add command -label "Clear Order" -font $GFont -command {Schieben order}
$m add command -label "Clear Model" -font $GFont -command {Schieben model}
$m add command -label "Clear Graph" -font $GFont -command {.bc delete all}
$m add separator
$m add command -label "Print 1/$Szahl" -font $GFont -command Druck
$m add command -label "About..." -font $GFont -command Ueber
$m add command -label Exit -font $GFont -command exit

radiobutton .f.vrb -text Value -value 1 -selectc blue
radiobutton .f.orb -text Order -value 2 -selectc red
radiobutton .f.nrb -text None -value 0 -selectc black
foreach rb {vrb orb nrb} {.f.$rb config -var Swert -font $GFont -command Reshow}
button .f.sb -relief raised -width 3 -font $GFont

pack .f.comb .f.vrb .f.orb .f.nrb .f.sb -side left -expand 1
#============= frame .ff ===================================
frame .ff -relief flat -bd 2

menubutton .ff.elemb -relief raised -text Element -font $GFont -menu .ff.elemb.m
set m [menu .ff.elemb.m]
foreach mname {x1 x4 lw zw bw sw fw x le ze be se fe on ow} {
  switch $mname {
    x1 {set el {"> Input" xe1 xs1 xn1 xd1 xi1 xc1 xr1 xz1}}
    x4 {set el {"|  Input" xe4 xs4 xn4 xd4 xi4 xc4 xr4 xz4}}
    lw {set el {"> Conductor" pfw1 pfn1 pfw8 pfs1 pfw4 pfws9 pfwn5}}
    fw {set el {"> Divider" tpw1 hpw1 igw1 dfw1 tzw1}}
    sw {set el {"> Connector" vsw1 grw1 snw1 epw1}}
    bw {set el {"> Static C." suws1 suwn1 adws1 adwn1 adns1 adwns1
                mpws1 mpwn1 mpns1 mpwns1}}
    zw {set el {"> Dynamic C." pfw5 pfw9 pfw12 pfn5 pfw13}}
    x  {set el {"* Misc." leere pfn4 pfs8 nnwn5 nnnw5 cuws9 cuwn5}}
    le {set el {"< Conductor" pfe2 pfn2 pfe8 pfs2 pfe4 pfen6 pfes10}}
    fe {set el {"< Divider" tpe2 hpe2 ige2 dfe2 tze2}}
    se {set el {"< Connector" vse2 gre2 sne2 epe2}}
    be {set el {"< Static C." aden2 ades2 adns2 mpns2 mpes2 mpen2}}
    ze {set el {"< Dynamic C." pfe10 pfe6 pfe12 pfn6}}
    on {set el {"|  Output" ausnblack ausnblue ausnred ausnorange ausngreen3}}
    ow {set el {"> Output" auswblack auswblue auswred ausworange auswgreen3}}
  }
  $m add cascade -label [lindex $el 0] -menu $m.$mname -font $GFont
  set el [lrange $el 1 end]
  set mm [menu $m.$mname -tearoff no]
  foreach e $el {if $tk_version<8.0 {
    $mm add radio -indi no -image $e -value $e -var Element -command Redraw
  } else {
    $mm add radio -hidem 1 -indi no -image $e -value $e -var Element -command Redraw
  }}
}

set Element leere
label .ff.elel -relief sunken -image $Element
label .ff.werl -text Value -font $GFont
set Wert 1
entry .ff.were -width 4 -textvar Wert -fg blue -font $MFont
button .ff.ordb -text Order -relief raised -font $GFont -command {Incr_Order 1}
bind .ff.ordb <Button-3> {.ff.ordb config -relief sunken ; Incr_Order -1}
bind .ff.ordb <ButtonRelease-3> {.ff.ordb config -relief flat}
set Order ""
entry .ff.orde -width 5 -textvar Order -fg red -font $MFont
pack .ff.elemb .ff.elel .ff.werl .ff.were .ff.ordb .ff.orde -side left -expand 1
Redraw
#============= canvas .c ==================================
canvas .c -relief sunken -bd 2
set NeuX $Xzahl
set NeuY $Yzahl
set Xzahl 0
set Yzahl 0
Zoomdo go
#============= canvas .bc =================================
canvas .bc -relief sunken -bd 2
Start 0 0 0
#===================== . ==================================
pack .f .ff -fill x
pack .c .bc
bind . <KeyPress-space> "set KS 1.0"
bind . <Shift-KeyPress-space> "set KS -1.0"
bind . <KeyRelease-space> "set KS 0.0"
#===================== eof ================================
