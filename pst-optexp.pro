%
% PostScript prologue for pst-optexp.tex.
% version 0.4 2010-10-26 (cb)
% For distribution, see pstricks.tex.
%
/tx@OptexpDict 20 dict def
tx@OptexpDict begin
%
% str1 str2 -> str1str2
/strcat {
    exch 2 copy
    length exch length add
    string dup dup 5 2 roll
    copy length exch
    putinterval
} bind def
%
% XB YB  XA YA XG YG
/calcNodes {
    /YG exch def /XG exch def
    /ay YG 3 -1 roll sub def
    /ax XG 3 -1 roll sub def
    /by exch YG sub def
    /bx exch XG sub def
    /a ax ay Pyth def
    /modA a def % for external use
    /b bx by Pyth def
    /cx ax a div bx b div add def
    /cy ay a div by b div add def
    /c@tmp cx cy Pyth def
    /c ax bx add ay by add Pyth def
    /OEangle c dup mul a dup mul sub b dup mul sub -2 a b mul mul div Acos def
    %
    % if c=0, then set the coordinates of the vector manually
    % depending on the dotproduct (and thus, if 'a' and 'b'
    % are parallel or antiparallel
    c 0 eq {
	ax bx mul ay by mul add 0 gt {
            % if dotprod > 0 then a and b are parallel
	    /cx ax def
	    /cy ay def
	}{% else a and b are antiparallel
          /cx ay def
          /cy ax neg def
	} ifelse
        /c@tmp a def
    } if
    /X@A XG cx c@tmp div add def
    /Y@A YG cy c@tmp div add def
    /X@B XG cx c@tmp div sub def
    /Y@B YG cy c@tmp div sub def
    %
    % chirality:
    % test the order of the input points as a input angle > 90�
    % doesn't really make sens.
    % So if 'chir' <= 0 exchange the calculated coordinates of 
    % A and B and otherwise leave it as is
    /chirality ax by mul ay bx mul sub def
    chirality 0 le {
	Y@A X@A 
        /X@A X@B def
        /Y@A Y@B def
        /X@B exch def
        /Y@B exch def
    }if
} bind def
%
% R1 height -> a1
/segLen {% 
    dup mul neg exch abs dup 3 1 roll dup mul add sqrt sub
} bind def
% height R1 -> y |R1| alpha_bottom alpha_top R1
/leftConvex {
   /R1 exch def /h exch def
   /a1  R1 h segLen def
   0 R1 abs
   R1 a1 sub neg dup
   h exch atan exch
   h neg exch atan
   /ArcL /arc load def
   R1
} bind def
%
% height R1 -> y |R1| alpha_bottom alpha_top R1
/leftConcave {
   /R1 exch def /h exch def
   /a1 R1 h segLen def
   0 R1 abs
   R1 neg a1 sub dup
   h exch atan exch
   h neg exch atan
   /ArcL /arcn load def
   /a1 0.5 a1 mul def
   R1
} bind def
%
% height R2 -> y |R2| alpha_bottom alpha_top R2
/rightConvex {
   /R2 exch def /h exch def
   /a2 R2 h segLen def
   0 R2 abs
   R2 a2 sub dup
   h neg exch atan exch
   h exch atan
   R2
   /ArcR /arc load def
} bind def
%
% height R2 -> y |R2| alpha_bottom alpha_top R2
/rightConcave {
   /R2 exch def /h exch def
   /a2 R2 h segLen def
   0 R2 abs
   R2 a2 add dup
   h neg exch atan exch
   h exch atan
   /ArcR /arcn load def
   /a2 0.5 a2 mul def
   R2
} bind def
%
% x1 y1 x2 y2 -> (x1+x2)/2 (y1+y2)/2
/mwNode {
    exch 3 1 roll add 2 div 3 1 roll add 2 div exch
} bind def
% Calculate angle of line from nodeA to nodeB
% nodeB nodeA -> angle
/FiberAngleB {%
    GetCenter 3 -1 roll GetCenter exch 3 1 roll sub 3 1 roll sub atan
} bind def
%
% Calculate angle of line from nodeB to nodeA
% nodeB nodeA -> angle
/FiberAngleA {%
    FiberAngleB 180 add
} bind def
%
/ExtNode {%
    @@x0 @xref @@x mul add 
    @@y0 @yref @@y mul add 
} bind def
%
% basicnodename reverse GetInternalNodeNames
/GetInternalNodeNames {
    /reverse exch def
    (N@) exch strcat 
    1 % counter
    {% counter and name on stack
	2 copy dup 3 string cvs 3 -1 roll exch strcat dup
	tx@NodeDict exch known {%
	    reverse {
		4 1 roll pop
	    } {
		exch 2 add 1 roll
	    } ifelse
	} {
	    reverse {
		pop pop pop (N) strcat
	    } {
		pop pop exch (N) strcat exch 1 roll
	    } ifelse
	    exit
	} ifelse
	1 add
    } loop
} bind def
%
% basicnodename reverse GetInternalBeamNodes x_n y_n ... x_1 y_1 (if reverse = false)
/GetInternalBeamNodes {
    [ 3 1 roll GetInternalNodeNames ]
    { cvn tx@NodeDict begin load GetCenter end } forall
} bind def
%
% Initialize some global variables for positioning of external nodes
/InitOptexpComp {%
    tx@Dict begin
	/@@x 0 def
	/@@y 0 def
	/@@x0 0 def
	/@@y0 0 def
        /@xref 0 def
        /@yref 0 def
    end
} bind def
%
% xa ya xb yb ExchCoor true|false
/ExchCoor {
    exch 4 -1 roll 2 copy 
    gt {
	pop pop pop pop false
    } {% xB > xA
	eq % xA == xB
	3 1 roll gt % yA < yB
	and {
	    false
	} {
	    true
	} ifelse
    } ifelse
} bind def
%
% added for version 2.2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% {x y} {dx dy} Name {scaling procedure}
/NewNodeComp {
  /sc ED
  dup cvn
  6 dict dup 3 1 roll def begin
      /ambiguous false def	
      /name ED
      {0 0} exch 3 -1 roll exec
      gsave
	  translate
	  /CompMtrx CM def
      grestore
      /N 1 def
      /n 1 def
      5 dict dup dup /P@1 ED /P@N ED
      begin
	  /mode trans def
	  {} NewPlaneInt
      end
      /adjustRel true def
  end
} bind def
%
% { x y } { rx ry } {scaling proc}
/NewCurvedInt {
    2 copy 5 3 roll exec 3 -1 roll exec VecAdd 5 -1 roll exec /Y ED /X ED
    exch exec 3 -1 roll exec 2 copy tx@Dict begin Pyth end /R ED /RY ED /RX ED
%    exch exec 2 copy add 0 lt { -1 } { 1 } ifelse /curv ED 3 -1 roll exec tx@Dict begin Pyth end /R ED
} bind def
%
% { x y } { dx dy } {scaling proc}
/NewPlaneInt {
    dup 3 -1 roll exec 3 -1 roll exec /DY ED /DX ED
    exch exec 3 -1 roll exec /Y ED /X ED
} bind def
%
% must be called within NewOptexpComp
% The plane has several attributes:
% {x y} are the coordinates of the node on the respective plane that is used
%       for unexpanded beams.
% {...} in case of a simple plane, this contains {dx dy} which is the relative
%       vector that defines the line representing the plane.
%       For curved surfaces, this procedure contains more values.
% type  Integer, characterizes if a surface is reflective or transmittent.
%       To avoid confusion you should use the parameters designed for that
%       (/refl and /trans)
% Name  String, Is the name of the new plane. It is expanded by an 'P@'
% {New..Int} Should contain the matching procedure for proper handling of the
%       variable procedure content {...}. Can be {NewPlaneInt} or {NewCurvedInt}
%
% { x y } {dx dy | rx ry} mode CompName Name {New..Int} {scaling proc}
/NewCompInt {
  /scl ED
  /next ED
  dup (P@) exch strcat cvn
  5 dict dup 			% { x y } {...} mode CompName Name /P@Name dict dict
  3 1 roll def 			% { x y } {...} mode CompName Name dict /P@Name dict def
  begin 			% { x y } {...} mode CompName Name dict begin
    3 -1 roll			% { x y } {...} CompName Name mode
    /mode ED                    % plane mode, 0: reflective, 1: transmittive
    4 -1 roll dup 5 -1 roll     % CompName Name { x y } { x y } {...}
    {scl} next
  end
  3 1 roll strcat exch exec scl ToVec exch @NewNode % store a new node /N@NameX, with X=1..N
  % this node always represents the intersection of an untilted and unshifted incoming beam
  % on the optical axis with the respective interface
} bind def
/refl 0 def /trans 1 def
/desc 0 def /asc 1 def /amb 2 def
%
% { x y } NodeName
/@NewNode {
    tx@NodeDict begin (N@) exch strcat cvn false exch 10 {InitPnode } NewNode end
} bind def
%
% About the design:
% NewOptexpComp creates a new dictionary that contains everything needed
% for an optical component. It contains the following variables:
% /n             -> refractive index (is usually 1)
% /CompMtrx      -> current matrix to store the planes correctly
% /name          -> name of the component
% /N             -> number of planes
% /P@1 ... /P@N  -> planes used for the 'ray tracing'
%
% [ { x y } { dx dy | rx ry} type {New..Int} refrIndex CompName {scaling proc} amb
/NewOptexpComp {
  3 1 roll /sc ED 
  dup cvn
  gsave
  10 dict dup 3 1 roll def begin
  /name ED
  /ambiguous ED
  tx@Dict begin
    STV {CP T} stopped pop % set scaling for all planes
  end
  /CompMtrx CM def
  grestore
  % count the planes and save their number
  counttomark dup 4 idiv dup /N ED 4 mul eq { 1 } if /n ED
  1 N eq {% only a single plane
      ambiguous { 4 copy name (C) 3 -1 roll {sc} NewCompInt } if
      4 copy name (1) 3 -1 roll {sc} NewCompInt
      name (N) 3 -1 roll {sc} NewCompInt
  }{
      ambiguous {
	  name (C) 3 -1 roll {sc} NewCompInt
	  /N N 1 sub def
      } if
      N -1 1 { %
	  dup N eq { pop (N) }{3 string cvs} ifelse
	  exch name 3 1 roll {sc} NewCompInt
      } for
  } ifelse
  end
  pop
} bind def
%
% PlaneNumber CompName -> PlaneVec
/GetPlaneVec {
    cvn load begin
%	dup N eq {
%	    pop (N)
%	} {
%	    3 string cvs
%	} ifelse
	PlaneName cvn load begin
	    currentdict /RX known {
		RX RY CompMtrx dtransform CM idtransform
		neg exch
	    } {
		DX DY CompMtrx dtransform CM idtransform
	    } ifelse
	end
    end
} bind def
%
% PlaneNumber CompName -> NodeCenter
% or
% {Plane} -> NodeCenter
/GetPlaneCenter {
    dup type /stringtype eq not {
	dup xcheck not {% ambiguous
	    0 get (C) exch
	} {
	    exec pop pop pop
	} ifelse
    } if
    cvn load begin
%	dup dup N eq {
%	    pop (N)
%	} {
%	    3 string cvs
%	} ifelse (N@)
%	name strcat exch strcat
%	cvn dup tx@NodeDict exch known {
%	    tx@NodeDict begin load GetCenter end
%	    3 -1 roll pop
%	} {
%	    pop
	    PlaneName cvn load begin
		currentdict /RX known {
		    X RX sub Y RY sub
		} {
		    X Y
		} ifelse
		CompMtrx transform CM itransform
	    end
%	} ifelse
    end
} bind def
%
% [ CompN ... Comp1 {options}
/ConnectPlaneNodes {%
    % preset options
    /nMul 1 def
    % execute options
    exec
    PrearrangePlanes
    PushAllPlanesOnStack
    counttomark /PlaneNum ED
    /PN 1 def
    { % iterate over all planes
	dup xcheck not {% array, not executable
	    PushAmbCompPlanesOnStack
	} if
	exec
	5 1 roll
	pop %/Mode ED
	pop % n
	% draw PlaneNumber CompName
	cvn load begin % comp dict
	    (N@) name strcat exch
	    dup N eq { pop (N) } { 3 string cvs } ifelse
	    strcat
	end
	tx@NodeDict begin cvn load GetCenter end
	2 copy ToVec /lastBeamPoint ED
	3 -1 roll
	PN 1 eq {
	    pop
	    counttomark 2 roll
	} {
	    counttomark 3 roll
	} ifelse
	PN PlaneNum eq {
	    exit
	} {
	    /PN PN 1 add def
	} ifelse
    } loop
} bind def
%
% InVec is relative to the connection between first and second components
% transform to absolute coordinates
% Plane2 Plane1 {InVec} -> {InVec'}
/TransformInVec {
    3 1 roll % {InVec} P2 P1
    GetPlaneCenter 4 2 roll % X1 Y1 {InVec} Plane2
    GetPlaneCenter 5 -2 roll % {InVec} X2 Y2 X1 Y1
    @ABVect % {InVec} dX dY
    3 -1 roll exec 2 copy 6 2 roll % Xi Yi dX dY Xi Yi 
    0 eq exch 0 eq and not {% invec != (0,0)
	exch atan matrix rotate dtransform
    } {
	4 2 roll pop pop
    } ifelse
    ToVec
} bind def
%/TransformInVec {
%    3 1 roll exec pop pop pop GetPlaneCenter
%    3 -1 roll exec pop pop pop GetPlaneCenter
%    4 2 roll @ABVect
%    3 -1 roll exec 2 copy 6 2 roll
%    0 eq exch 0 eq and not {    
%	exch atan matrix rotate dtransform
%    } {
%	4 2 roll pop pop
%    } ifelse
%    ToVec
%} bind def
%
% startpos is relative to the connection between first and second components
% transform to absolute coordinates and shift by first plane center
% Plane2 Plane1 {StartPos} -> {StartPos'+Plane1Center}
/TransformStartPos {
    exec 2 copy 6 2 roll 0 eq exch 0 eq and not  % SPx SPy P2 P1 neq00
    3 1 roll GetPlaneCenter 4 2 roll % SPx SPy X1 Y1 neq00 P2
    GetPlaneCenter 5 2 roll % SPx SPy X2 Y2 X1 Y1 neq00
    {% SP != (0,0)    SPx SPy X2 Y2 X1 Y1
	2 copy 8 2 roll % X1 Y1 SPx SPy X2 Y2 X1 Y1
	@ABVect	exch atan matrix rotate dtransform
	VecAdd
    } {
	6 2 roll pop pop pop pop
    } ifelse
    ToVec
} bind def
%/TransformStartPos {
%    exec 2 copy 6 2 roll 0 eq exch 0 eq and not  % SPx SPy P2 P1 bool
%    exch exec pop pop pop GetPlaneCenter % SPx SPy P2 bool X1 Y1
 %   3 -1 roll {% SP != 0,0    SPx SPy P2 X1 Y1 bool
%	2 copy 7 2 roll % X1 Y1 SPx SPy P2 X1 Y1
%	3 -1 roll exec pop pop pop GetPlaneCenter % X1 Y1 SPx SPy X1 Y1 X2 Y2
%	4 2 roll @ABVect
%	exch atan matrix rotate dtransform
%	VecAdd
 %   } {
%	5 2 roll pop pop pop
 %   } ifelse
  %  ToVec
%} bind def
% X Y CompName -> PlaneNumber
/GetNearestPlane {
    3 copy 1 exch GetPlaneCenter @ABDist /dist ED /nearestPlane 1 def
    dup cvn load /N get 2 1 3 -1 roll {
	4 copy exch GetPlaneCenter @ABDist dup dist lt {
	    /dist ED /nearestPlane ED
	} {
	    pop pop
	} ifelse
    } for
    pop pop pop nearestPlane
} bind def
%
% Plane1 Plane2 -> PlaneNumber1 CompName1 PlaneNumber2 CompName2
/GetNearestPlanes {
    dup xcheck not {% second is ambiguous
	1 index xcheck not {% also first is ambiguous
	    1 index % P1 P2 P1
	    0 get (C) exch GetPlaneCenter % P1 P2 XC1 YC1
	    3 -1 roll 0 get dup 4 1 roll GetNearestPlane % CompName2 P1 nextPlane2
	    3 -1 roll 2 copy GetPlaneCenter 5 -1 roll % nextPlane2 CompName2 X2 Y2 P1
	    0 get dup 4 1 roll GetNearestPlane exch % nextPlane2 CompName2 nextPlane1 CompName1
	    4 2 roll
	} {% first not ambiguous
	    exch exec pop pop pop 2 copy GetPlaneCenter % Plane2 nextPlane1 CompName1 X1 Y1
	    5 -1 roll 0 get dup 4 1 roll GetNearestPlane exch % nextPlane1 CompName1 nextPlane2 CompName2
	} ifelse
    } {
	1 index xcheck not {% only first is ambiguous
    	    exec pop pop pop 2 copy GetPlaneCenter % Plane1 nextPlane2 CompName2 X2 Y2
	    5 -1 roll 0 get dup 4 1 roll GetNearestPlane exch % nextPlane2 CompName2 nextPlane1 CompName1
	    4 2 roll
	} {% none is ambiguous
	    exec pop pop pop 3 -1 roll exec pop pop pop 4 2 roll
	} ifelse
    } ifelse
} bind def
%
/PushAmbCompPlanesOnStack {
%    counttomark /t ED t copy t{==} repeat
    currentdict /outToPlane undef
    PN PlaneNum eq not {% not last plane
	exch dup 3 1 roll % outToPlane
	dup xcheck not {%
	    0 get (C) exch
	} {
	    exec pop pop pop
	} ifelse
	[ 3 1 roll ] cvx /outToPlane ED
    } if
    /PlaneNumTmp PlaneNum def
    aload pop /draw ED /name ED
    name cvn load /N get /N ED
    currentdict /Curr known {
	/CurrTmp /Curr load def
	/CurrVecTmp /CurrVec load def
    } {
	/CurrTmp /CurrLow load def
	/CurrVecTmp /CurrVecLow load def
    } ifelse

    PN 1 eq not 1 N eq not and {% not first comp and not single interface
	CurrTmp name GetNearestPlane /nextPlane ED
	%
	% check if mode is trans or refl
	CurrVecTmp nextPlane name GetPlaneVec NormalVec
	(C) name GetPlaneCenter nextPlane name GetPlaneCenter @ABVect 2 copy 6 2 roll SProd 
	0 lt { trans }{ refl } ifelse
	3 1 roll ToVec /CurrVecTmp ED
	[ nextPlane name name cvn load /n get 5 -1 roll true ] cvx % always draw to first interface
    } if

    %
    % now add CenterPlane
    1 N eq {% only a single interface
	[ (C) name name cvn load /n get 
	PN 1 eq {
	    trans
	} {
	    PN PlaneNum eq {
		trans
	    } {
		CurrVecTmp (C) name GetPlaneVec NormalVec outToPlane GetPlaneCenter (C) name GetPlaneCenter @ABVect SProd
		0 lt { trans } { refl } ifelse % mode
	    } ifelse
	} ifelse
	true ] cvx
    } {
	PN PlaneNum eq {
	    [ (C) name name cvn load /n get trans draw ] cvx exch
	    /PlaneNumTmp PlaneNumTmp 1 add def
	} {
	    outToPlane GetPlaneCenter name GetNearestPlane /nextPlane ED
	    %
	    % check if mode of center is trans or refl
	    nextPlane name GetPlaneCenter (C) name GetPlaneCenter @ABVect
	    PN 1 eq {
		trans
		3 1 roll ToVec /CurrVecTmp ED
		[ (C) name name cvn load /n get 5 -1 roll draw ] cvx
	    }{
		2 copy CurrVecTmp (C) name GetPlaneVec NormalVec SProd
		0 lt { trans } { refl } ifelse % dX dY mode
		3 1 roll ToVec /CurrVecTmp ED
		[ (C) name name cvn load /n get 5 -1 roll draw ] cvx exch
		/PlaneNumTmp PlaneNumTmp 1 add def
	    } ifelse
	} ifelse
    } ifelse

    PN PlaneNum eq not 1 N eq not and {% not last comp and not single interface
	%
	% now check for mode of outgoing plane
	CurrVecTmp nextPlane name GetPlaneVec NormalVec
	outToPlane GetPlaneCenter nextPlane name GetPlaneCenter @ABVect SProd
	0 lt { trans } { refl } ifelse %dX dY mode
	[ nextPlane name 1 5 -1 roll draw ] cvx
	PN 1 eq {
	    exch
	} {
	    3 1 roll
	} ifelse
	/PlaneNumTmp PlaneNumTmp 1 add def
    } if
%    (PlaneNum) == PlaneNum ==
%    (PlaneNumTmp) == PlaneNumTmp ==
%    (PN) == PN ==
%    counttomark /t ED t copy t{==} repeat
    /PlaneNum PlaneNumTmp def
} bind def
%
% [ CompN ... Comp1 {options} {start point} {input vector}
% -> Yn Xn drawToN? ... Y1 X1 drawTo1? Y0 X0
/TraceBeam {%
    /InVec ED /StartPoint ED
    % preset options
    /nMul 1 def
    % execute options
    exec
    counttomark /N ED
    PrearrangePlanes
    PushAllPlanesOnStack
    2 copy /InVec load TransformInVec /CurrVec ED
    continueBeam currentdict /lastBeamPoint known and {
	/lastBeamPoint load /Curr ED
    }{
	2 copy /StartPoint load  TransformStartPos /Curr ED
    } ifelse
    counttomark /PlaneNum ED /n1 1 def % init the refractive index
    /PN 1 def
%    (start loop)==
    { % iterate over all planes
%	(PN) == PN ==
%	/Curr load ==
%	(on stack) == counttomark /t ED t copy t {==} repeat
	dup xcheck not {% array, not executable
	    PushAmbCompPlanesOnStack
%	    (completed planes on stack)==
%	    counttomark /t ED t copy t{==}repeat
%	    (done)==
	} {
%	    (on stack) ==
%   	    counttomark /t ED t copy t{==}repeat
%	    (done)==
	} ifelse
	exec
	/draw ED
	/Mode ED
	3 1 roll % n PlaneNumber CompName
%	3 copy == == ==
	cvn load begin % comp dict
%	    (comp dict) ==
	    PlaneName cvn load begin % plane dict
		X Y
%		PN 1 eq { (inplane center) == 2 copy == == } if
		CompMtrx transform CM itransform % n1 X Y
%		PN 1 eq { (inplane center transformed) == 2 copy == == } if
		currentdict /RX known {
		    RX RY
		} {
		    DX DY %PN 1 eq { (inplane) == 2 copy == == } if
		} ifelse
		CompMtrx dtransform CM idtransform  % PN 1 eq { (inplane transformed) == 2 copy == == } if
		Mode 6 -1 roll
		Curr CurrVec
		currentdict /RX known 
	    end
%	    (comp dict end)==
	end
	{ CurvedInterface }{ PlainInterface } ifelse
%	(*Interface done) == 
%	(after dict) == counttomark /t ED t copy t{==}repeat
	PN 1 eq {
	    pop pop 2 copy ToVec /Curr ED
	    /n1 1 def
	    counttomark 2 roll
	} {
	    ToVec /CurrVec ED 2 copy
	    ToVec /Curr ED 
	    draw
	    counttomark 3 roll
	} ifelse
	/lastBeamPoint /Curr load def
	
	PN PlaneNum eq {
	    exit
	} {
	    /PN PN 1 add def
	} ifelse
%	counttomark /t ED t copy t{==}repeat
%	(---)==
    } loop
    currentdict /CurrVec undef
    currentdict /Curr undef
} bind def
%
%
/DrawBeam {
%    (DrawBeam)==
%    counttomark /t ED t copy t {==} repeat
%    (TraceBeam)==
    connectPlaneNodes {
	ConnectPlaneNodes
    } {
	TraceBeam %2 copy (go to start point)== == ==
    } ifelse
    5 copy 3 -1 roll pop ArrowA pop pop pop pop % go to Startpoint
    counttomark 3 idiv -1 2 { pop {lineto}{moveto}ifelse } for
    {CP 4 2 roll ArrowB lineto pop pop } {moveto} ifelse
    pop
%    (---------------------------------) ==
} bind def
%
% [ CompN ... Comp1 {options} {start point up} {input vector up} {start point low} {input vector low}
/StrokeExtendedBeam {
    5 -1 roll dup 6 1 roll 3 1 roll % {opt} {sup} {inup} {opt} {slow} {inlow}
    counttomark 6 sub /numComp ED
    numComp 7 add 6 roll numComp 1 add copy % {opt} {sup} {inup} {opt} {slow} {inlow} [ CompN .. Comp1 [ CompN .. Comp1
    numComp 1 add 2 mul 6 add numComp 1 add roll % [ CompN .. Comp1 {opt} {sup} {inup} {opt} {slow} {inlow} [ CompN .. Comp1
    numComp 1 add 3 add -3 roll % [ CompN .. Comp1 {opt} {sup} {inup} [ CompN .. Comp1 {opt} {slow} {inlow}
    currentdict /lastBeamPointLow known {
	/lastBeamPointLow load /lastBeamPoint ED
    } if
    DrawBeam /lastBeamPoint load /lastBeamPointLow ED
    currentdict /lastBeamPoint undef
    currentdict /lastBeamPointUp known {
	/lastBeamPointUp load /lastBeamPoint ED
    } if
    DrawBeam /lastBeamPoint load /lastBeamPointUp ED 
} bind def
%
% [ CompN ... Comp1 {options} {start point up} {input vector up} {start point low} {input vector low} 
/ExtendedBeam {
%    (ExtendedBeam) ==
%    counttomark /t ED t copy t {==} repeat
    /InvecLow ED /StartLow ED /InvecUp ED /StartUp ED 
    % preset options
    currentdict /fillBeam known not { /fillBeam {gsave fill grestore} def } if
    /DrawnSegm 0 def
    /nMul 1 def
    % execute user options
    exec
    PrearrangePlanes
    PushAllPlanesOnStack
    2 copy /InvecLow load TransformInVec /CurrVecLow ED
    2 copy /InvecUp load TransformInVec /CurrVecUp ED
    continueBeam currentdict /lastBeamPointLow known currentdict /lastBeamPointUp known and and {
	/lastBeamPointLow load /CurrLow ED
	/lastBeamPointUp load /CurrUp ED
    } {
	2 copy /StartLow load TransformStartPos /CurrLow ED
	2 copy /StartUp load TransformStartPos /CurrUp ED
    } ifelse
    counttomark /PlaneNum ED /n1 1 def
    /CurrR false def
    /PN 1 def
    {
	dup xcheck not {% array, not executable
	    PushAmbCompPlanesOnStack
%	    (completed planes on stack)==
%	    counttomark /t ED t copy t{==}repeat
%	    (done)==
	} if
	exec
	/draw ED
	/Mode ED
	3 1 roll cvn load begin % comp dict
	    PlaneName cvn load begin % plane dict
%		(PlaneDict) ==
		X Y CompMtrx transform CM itransform
		currentdict /RX known {
		    RX RY 
		} {
		    DX DY
		} ifelse
		CompMtrx dtransform CM idtransform 4 copy
		Mode 10 -1 roll % X Y DX DY X Y DX DY mode n1
		6 copy
		currentdict /RX known
	    end
	end
	/curved ED
	/oldn1 n1 def
	% new upper vector and intersection point
	CurrUp CurrVecUp curved {
%	    (curved) ==
	    CurvedInterface
	} {
%	    (plain) == 
	    PlainInterface
	} ifelse
	/CurrVecUp load /OldVecUp ED /CurrUp load /OldUp ED
	ToVec /CurrVecUp ED
	ToVec /CurrUp ED
%	(upper done)==
	/n1 oldn1 def
	% new lower vector and intersection point
	CurrLow CurrVecLow curved {
	    CurvedInterface
	} {
	    PlainInterface
	} ifelse
	/CurrVecLow load /OldVecLow ED /CurrLow load /OldLow ED
	ToVec /CurrVecLow ED
	ToVec /CurrLow ED
%	(lower done)==
	/OldR CurrR def
	curved {
	    tx@Dict begin Pyth end /CurrR ED
	} {
	    pop pop /CurrR false def
	} ifelse
%	(radius done) ==
	% X Y still on stack
	OldR type /realtype eq {
	    /CurrCenter load /OldCenter ED
	} if
	curved {
	    ToVec /CurrCenter ED
	} {
	    pop pop
	    /CurrCenter false def
	} ifelse
%	(center done) == 
	draw {
	    /DrawnSegm dup load 1 add def
%	    (draw) == 
	    OldUp moveto CurrUp lineto
	    curved {
		CurrCenter CurrUp CurrLow TangentCrosspoint
		CurrLow CurrR arct
	    } {
		CurrLow lineto
	    } ifelse
	    OldLow lineto
	    OldR type /booleantype eq not {% previous interface was also curved
		OldCenter OldLow OldUp TangentCrosspoint
		OldUp OldR arct
	    } {
		OldUp lineto
	    } ifelse
	} {
%	    (skip) ==
	} ifelse
	Mode refl eq draw and
	draw not DrawnSegm 0 gt and or {
	    fillBeam
	    /DrawnSegm 0 def
	} if
	PN PlaneNum eq {
	    DrawnSegm 0 gt { fillBeam } if
	    exit
	} {
	    /PN PN 1 add def
	} ifelse
    } loop
    /CurrUp load /lastBeamPointUp ED
    /CurrLow load /lastBeamPointLow ED
%    (---------------------------------) ==
} bind def
%
%
/isAmb { cvn load /ambiguous get } bind def
%
% [ CompN .. Comp1 PrearrangePlanes -> [ desc|asc CompN .. desc|asc Comp1 
/PrearrangePlanes {
%    counttomark /t ED t copy t {==} repeat
    counttomark /N ED
    /CompA ED dup /CompB ED
%    counttomark /t ED t copy t {==} repeat
%    (compa) == CompA == (compb)== CompB ==
    CompA isAmb {
%	(A amb)==
	amb dup CompA
    } {
	CompB isAmb {
%	    (B amb) ==
	    1 CompA GetPlaneCenter (C) CompB GetPlaneCenter @ABDist
	    (N) CompA GetPlaneCenter (C) CompB GetPlaneCenter @ABDist
	} {
%	    (none amb) ==
	    1 CompA GetPlaneCenter 1 CompB GetPlaneCenter (N) CompB GetPlaneCenter true OrderNodes exch pop
	    (N) CompA GetPlaneCenter 1 CompB GetPlaneCenter (N) CompB GetPlaneCenter true OrderNodes exch pop % dist1 distN
	} ifelse
	le { desc } { asc } ifelse dup CompA
%	(1212)==
    } ifelse
%    
    counttomark 2 roll
    2 1 N {
	/i ED exch /CompB ED %
	CompB isAmb not {
	    dup desc eq { 1 } { dup amb eq { (C) }{ (N) } ifelse } ifelse CompA GetPlaneCenter
	    1 CompB GetPlaneCenter
	    (N) CompB GetPlaneCenter false OrderNodes dup dup
	    % check if we have a NodeIfc
	    % dirA dirB dirB dirB
	    4 -1 roll CompA exch 5 -1 roll CompB exch
	    i 2 eq {% check also the first plane
		4 copy 4 2 roll AdjustRelRot
	    } if
	    AdjustRelRot
	} {
	    pop amb dup
	} ifelse
        CompB /CompA CompB def
	counttomark 2 roll
    } for pop
} bind def
%
% CompA desc|asc CompB desc|asc
/AdjustRelRot {
    exch dup cvn load /adjustRel known {
	dup 3 -1 roll desc eq {(N)}{1} ifelse exch GetPlaneCenter 5 3 roll
	desc eq {1}{(N)} ifelse exch GetPlaneCenter
	@ABVect exch atan exch
	cvn load begin
	    adjustRel {
		matrix rotate CompMtrx matrix concatmatrix /CompMtrx ED
		/adjustRel false def
	    } {
		pop
	    } ifelse
	end
    } {
	pop pop pop pop
    } ifelse
} bind def
%
% [ desc|asc CompN .. desc|asc Comp1 PushAllPlanesOnStack
% -> { PlaneNumber CompName n mode draw }
% n is the refractive index after the respective interface,
% but draw determines if the connection _to_ this interface
% is drawn
/PushAllPlanesOnStack {%
%    counttomark /t ED t copy t {==}repeat
    counttomark 2 div cvi /numComp ED
    1 1 numComp {% iterate over all components
	/last false def
	/first false def
	dup 1 eq {
	    /first true def pop drawFirstInner
	} {
	    numComp eq {
		drawLastInner
		/last true def
	    } {
		drawOtherInner
	    } ifelse
	} ifelse /drawInner ED
	load dup /ambiguous get {
%	    (amb) ==
	    /name get drawInner [ 3 1 roll ]
	    counttomark 1 roll pop
	} {
	    begin % comp dict
%		(comp dict) == name ==
		desc eq {
		    first {1}{N}ifelse dup -1 1 dup
		} {
		    first{N}{1} ifelse dup 1 N dup
		} ifelse
		5 1 roll % stop start start inc stop
		{% iterate over all planes
		    % stop start i
%		    (i) == dup ==
		    3 1 roll 2 copy 5 -1 roll % stop start stop start i
		    dup 3 1 roll % stop start stop i start i
		    eq first not and { % the first plane
			true    % always draw the line to the first plane of a component
		    } {
			drawInner % the other beams depend on some options
		    } ifelse % on stack: stop i draw?
		    exch dup 4 -1 roll eq  {% draw i i stop
			1 % after the last component plane we have always air
		    }{ % otherwise the respective refractive index of the component
			n
		    }ifelse % draw i refrIndex
		    exch dup N eq {
			pop (N)
		    } {
			3 string cvs
		    } ifelse exch
		    3 1 roll name % refrIndex draw (i) name
		    4 1 roll % name refrIndex draw (i)
%		    (add mode)==
		    dup PlaneName load /mode get % name refrIndex draw i mode
%		    (added mode)==
		    3 1 roll 5 1 roll % i name refrIndex mode draw
		    [ 6 1 roll ] cvx counttomark 1 roll
		    last drawInner not and continueBeam not and {
			exit
		    } if
		} for pop pop
	    end
%	    (end comp dict)==
	} ifelse
%	(stack)==  counttomark /t ED t copy t {==}repeat
    } for
} bind def
%
% must be called within a OptExpComp dictionary
/PlaneName {
    dup N eq {
	pop (N)
    } {
	3 string cvs
    } ifelse
    (P@) exch strcat
} bind def
% 
% A B1 BN dist? OrderNodes -> desc|asc distance?
/OrderNodes {% def
   /dist ED %cvn /BN ED cvn /B1 ED cvn /A ED
   6 -2 roll 2 copy 8 2 roll
   @ABDist 5 1 roll @ABDist 2 copy gt {
       pop asc exch
   } {
       exch pop desc exch
   } ifelse
   dist not {
       pop
   } if
} bind def
%
% construct a normal plane vector such that n�(-in) > 0
% X_in Y_in X_plane Y_plane NormalVec -> X_norm Y_norm
/NormalVec {
    neg exch 2 copy 6 2 roll SProd 0 gt {
	-1 mul exch -1 mul exch
    } if
    NormalizeVec
} bind def
%
% scalar product
% ax ay bx by SProd -> val
/SProd {
    3 -1 roll mul 3 1 roll mul add
} bind def
%
% angle between two vectors
% cos(alpha) = a�b/(|a||b|)
% ax ay bx by -> angle
/VecAngle {
    4 copy SProd 5 1 roll tx@Dict begin Pyth 3 1 roll Pyth end mul div dup == (Acos) == Acos
} bind def
% ax ay bx by VecAdd ax+bx ay+by
/VecAdd {
    3 -1 roll add 3 1 roll add exch
} bind def
/ToVec {
    [ 3 1 roll ] cvx
} bind def
% X Y NormalizeVec X' Y' (with X^2 + Y^2 = 1)
/NormalizeVec {
    2 copy
    tx@Dict begin
	Pyth
    end
    dup 3 1 roll div 3 1 roll div exch
} bind def
/@ABVect { tx@EcldDict begin ABVect end } bind def
/@ABDist { tx@EcldDict begin ABDist end } bind def
% see <http://en.wikipedia.org/wiki/Snell%27s_law#Vector_form>
% X_in Y_in X_norm Y_norm n1 n2 RefractVec -> X_out Y_out
/RefractVec {
    div /n ED 4 2 roll NormalizeVec /Yin ED /Xin ED /Ynorm ED /Xnorm ED
    /costheta1 Xnorm Ynorm Xin neg Yin neg SProd def
    /costheta2 1 n dup mul 1 costheta1 dup mul sub mul sub sqrt def
    n Xin mul n Yin mul n costheta1 mul costheta2 sub dup Xnorm mul exch Ynorm mul VecAdd 
} bind def

% X_in Y_in X_norm Y_norm ReflectVec -> X_out Y_out
/ReflectVec {
    /Ynorm ED /Xnorm ED NormalizeVec /Yin ED /Xin ED
    /costheta1 Xnorm Ynorm Xin neg Yin neg SProd def
    Xin Yin 2 costheta1 mul dup Xnorm mul exch Ynorm mul VecAdd
} bind def

% X_p Y_p X_r Y_r trans|refl n2 X0 Y0 X_in Y_in CurvedInterface -> X' Y' X_out Y_out
/CurvedInterface {
    /Yin ED /Xin ED /Y0 ED /X0 ED /n2 ED /mode ED
    2 copy /Yr ED /Xr ED 
    tx@Dict begin Pyth end /radius ED /Yp ED /Xp ED
    /X0n X0 Xp sub def /Y0n Y0 Yp sub def
    n2 1 gt { /n2 n2 nMul mul def } if
    tx@EcldDict begin
	X0n Y0n 2 copy 2 copy Xin 3 -1 roll add Yin 3 -1 roll add
	2 copy 6 2 roll EqDr radius InterLineCircle
    end
    4 copy
    0 eq 3 {exch 0 eq and} repeat {% all coordinates are zero, missed circle, stop
	PlaneNum PN sub 4 add {pop} repeat
	exit
    } if
    4 copy
    % which point to take? 
    Xr neg Yr neg 2 copy
    8 -2 roll @ABDist %dist from first point
    5 1 roll @ABDist % dist1 dist2
    gt {% take second point
	4 2 roll
    } if pop pop
    Xp Yp VecAdd
    2 copy Xp Yp 4 2 roll @ABVect exch neg Xin Yin 4 2 roll NormalVec Xin Yin 4 2 roll
    % on stack: crossing point, in vector, and normal vector
    mode trans eq {
	n1 n2 RefractVec
    } {
	ReflectVec
    } ifelse /n1 n2 def
} bind def
%
% Xp Yp dXp dYp trans|refl n2 X0 Y0 X_in Y_in PlainInterface -> X' Y' X_out Y_out
/PlainInterface {%
    /Yin ED /Xin ED /Y0 ED /X0 ED /n2 ED /mode ED /dYp ED /dXp ED /Yp ED /Xp ED
    n2 1 gt { /n2 n2 nMul mul def } if
    tx@EcldDict begin
	Xp Yp Xp dXp add Yp dYp add X0 Y0 X0 Xin add Y0 Yin add InterLines Xin Yin
	Xin Yin dXp dYp NormalVec
    end
    mode trans eq {
	n1 n2 RefractVec
    } {
	ReflectVec
    } ifelse /n1 n2 def
} bind def
%
% Xp Yp Xt1 Yt1 Xt2 Yt2
/TangentCrosspoint {
    4 copy 4 copy 14 -2 roll 2 copy% Xt1 Yt1 Xt2 Yt2 Xt1 Yt1 Xt2 Yt2 Xp Yp Xp Yp
    6 2 roll @ABVect neg exch% Xt1 Yt1 Xt2 Yt2 Xt1 Yt1 Xt2 Yt2 Xt1 Yt1 Xp Yp -(Yt2 -Yp) (Xt2-Xp)
    6 2 roll @ABVect neg exch% Xt1 Yt1 Xt2 Yt2 Xt1 Yt1 Xt2 Yt2 -(Yt2-Yp) (Xt2-Xp) -(Yt1-Yp) (Xt1-Xp)
    8 -2 roll VecAdd 10 2 roll % Xt1-(Yt1-Yp) Yt1+(Xt1-Xp) Xt1 Yt1 Xt2 Yt2 Xt2 Yt2 -(Yt2-Yp) (Xt2-Xp)
    VecAdd % Xt1-(Yt1-Yp) Yt1+(Xt1-Xp) Xt1 Yt1 Xt2 Yt2 Xt2-(Yt2-Yp) Yt2+(Xt2-Xp)
    tx@EcldDict begin InterLines end
} bind def
end % tx@OptexpDict
