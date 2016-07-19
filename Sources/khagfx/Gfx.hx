package khagfx;

import haxe.ds.Vector;
import kha.graphics1.Graphics;
import kha.Color;

/** 
 * http://members.chello.at/~easyfilter/bresenham.html
 * http://members.chello.at/~easyfilter/bresenham.c
**/

class Gfx
{
	static var M_MAX:Int = 6;	
	
	public static function drawLine(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, color:Color):Void
	{
	   var dx:Int =  iabs(x1-x0), sx:Int = x0 < x1 ? 1 : -1;
	   var dy:Int = -iabs(y1-y0), sy:Int = y0 < y1 ? 1 : -1;
	   var err:Int = dx + dy, e2:Int;                                   /* error value e_xy */
														
	   while (true){                                                          /* loop */
		  g1.setPixel(x0,y0,color);                              
		  e2 = 2*err;                                   
		  if (e2 >= dy) {                                         /* e_xy+e_x > 0 */
			 if (x0 == x1) break;                       
			 err += dy; x0 += sx;                       
		  }                                             
		  if (e2 <= dx) {                                         /* e_xy+e_y < 0 */
			 if (y0 == y1) break;
			 err += dx; y0 += sy;
		  }
	   }
	}

	public static function drawEllipse(g1:Graphics, xm:Int, ym:Int, a:Int, b:Int, color:Color):Void
	{
	   var x:Int = -a, y:Int = 0;           /* II. quadrant from bottom left to top right */
	   var e2:Int = (Int)b*b, err:Int = (Int)x*(2*e2+x)+e2;         /* error of 1.step */
															  
	   do {                                                   
		   g1.setPixel(xm-x, ym+y,color);                                 /*   I. Quadrant */
		   g1.setPixel(xm+x, ym+y,color);                                 /*  II. Quadrant */
		   g1.setPixel(xm+x, ym-y,color);                                 /* III. Quadrant */
		   g1.setPixel(xm-x, ym-y,color);                                 /*  IV. Quadrant */
		   e2 = 2*err;                                        
		   if (e2 >= (x*2+1)*(Int)b*b)                           /* e_xy+e_x > 0 */
			  err += (++x*2+1)*(Int)b*b;                     
		   if (e2 <= (y*2+1)*(Int)a*a)                           /* e_xy+e_y < 0 */
			  err += (++y*2+1)*(Int)a*a;
	   } while (x <= 0);

	   while (y++ < b) {                  /* too early stop of flat ellipses a=1, */
		   g1.setPixel(xm, ym+y,color);                        /* -> finish tip of ellipse */
		   g1.setPixel(xm, ym-y,color);
	   }
	}

	public static function drawOptimizedEllipse(g1:Graphics, xm:Int, ym:Int, a:Int, b:Int, color:Color):Void
	{
	   var x:Int = -a, y:Int = 0;          /* II. quadrant from bottom left to top right */
	   var e2:Int = b, dx:Int = (1+2*x)*e2*e2;                       /* error increment  */
	   var dy:Int = x*x, err:Int = dx+dy;                             /* error of 1.step */
														 
	   do {                                              
		   g1.setPixel(xm-x, ym+y,color);                                 /*   I. Quadrant */
		   g1.setPixel(xm+x, ym+y,color);                                 /*  II. Quadrant */
		   g1.setPixel(xm+x, ym-y,color);                                 /* III. Quadrant */
		   g1.setPixel(xm-x, ym-y,color);                                 /*  IV. Quadrant */
		   e2 = 2*err;
		   if (e2 >= dx) { x++; err += dx += 2*(Int)b*b; }             /* x step */
		   if (e2 <= dy) { y++; err += dy += 2*(Int)a*a; }             /* y step */
	   } while (x <= 0);

	   while (y++ < b) {            /* too early stop for flat ellipses with a=1, */
		   g1.setPixel(xm, ym+y,color);                        /* -> finish tip of ellipse */
		   g1.setPixel(xm, ym-y,color);
	   }
	}

	public static function drawCircle(g1:Graphics, xm:Int, ym:Int, r:Int, color:Color):Void
	{
	   var x:Int = -r, y:Int = 0, err:Int = 2-2*r;                /* bottom left to top right */
	   do {                                          
		  g1.setPixel(xm-x, ym+y,color);                            /*   I. Quadrant +x +y */
		  g1.setPixel(xm-y, ym-x,color);                            /*  II. Quadrant -x +y */
		  g1.setPixel(xm+x, ym-y,color);                            /* III. Quadrant -x -y */
		  g1.setPixel(xm+y, ym+x,color);                            /*  IV. Quadrant +x -y */
		  r = err;                                   
		  if (r <= y) err += ++y*2+1;                             /* e_xy+e_y < 0 */
		  if (r > x || err > y)                  /* e_xy+e_x > 0 or no 2nd y-step */
			 err += ++x*2+1;                                     /* -> x-step now */
	   } while (x < 0);
	}

	/* rectangular parameter enclosing the ellipse */
	public static function drawEllipseRect(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, color:Color):Void
	{
	   var a:Int = iabs(x1-x0), b:Int = iabs(y1-y0), b1:Int = b&1;                 /* diameter */
	   var dx:Float = 4*(1.0-a)*b*b, dy:Float = 4*(b1+1)*a*a;           /* error increment */
	   var err:Float = dx+dy+b1*a*a, e2:Float;                          /* error of 1.step */

	   if (x0 > x1) { x0 = x1; x1 += a; }        /* if called with swapped points */
	   if (y0 > y1) y0 = y1;                                  /* .. exchange them */
	   y0 += (b+1)/2; y1 = y0-b1;                               /* starting pixel */
	   a = 8*a*a; b1 = 8*b*b;                   
												
	   do {                                     
		  g1.setPixel(x1, y0,color);                                      /*   I. Quadrant */
		  g1.setPixel(x0, y0,color);                                      /*  II. Quadrant */
		  g1.setPixel(x0, y1,color);                                      /* III. Quadrant */
		  g1.setPixel(x1, y1,color);                                      /*  IV. Quadrant */
		  e2 = 2*err;
		  if (e2 <= dy) { y0++; y1--; err += dy += a; }                 /* y step */
		  if (e2 >= dx || 2*err > dy) { x0++; x1--; err += dx += b1; }  /* x step */
	   } while (x0 <= x1);

	   while (y0-y1 <= b) {                /* too early stop of flat ellipses a=1 */
		  g1.setPixel(x0-1, y0,color);                         /* -> finish tip of ellipse */
		  g1.setPixel(x1+1, y0++,color);
		  g1.setPixel(x0-1, y1,color);
		  g1.setPixel(x1+1, y1--,color);
	   }
	}

	/* plot a limited quadratic Bezier segment */
	public static function drawQuadBezierSeg(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int, color:Color):Void
	{
	  var sx:Int = x2-x1, sy:Int = y2-y1;
	  var xx:Int = x0-x1, yy:Int = y0-y1, xy:Int;              /* relative values for checks */
	  var dx:Float, dy:Float, err:Float, cur:Float = xx*sy-yy*sx;                         /* curvature */

	  //assert(xx*sx <= 0 && yy*sy <= 0);       /* sign of gradient must not change */

	  if (sx*(Int)sx+sy*(Int)sy > xx*xx+yy*yy) {      /* begin with longer part */
		x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur;       /* swap P0 P2 */
	  }
	  if (cur != 0) {                                         /* no straight line */
		xx += sx; xx *= sx = x0 < x2 ? 1 : -1;                /* x step direction */
		yy += sy; yy *= sy = y0 < y2 ? 1 : -1;                /* y step direction */
		xy = 2*xx*yy; xx *= xx; yy *= yy;               /* differences 2nd degree */
		if (cur*sx*sy < 0) {                                /* negated curvature? */
		  xx = -xx; yy = -yy; xy = -xy; cur = -cur;
		}
		dx = 4.0*sy*cur*(x1-x0)+xx-xy;                  /* differences 1st degree */
		dy = 4.0*sx*cur*(y0-y1)+yy-xy;
		xx += xx; yy += yy; err = dx+dy+xy;                     /* error 1st step */
		do {
		  g1.setPixel(x0,y0,color);                                          /* plot curve */
		  if (x0 == x2 && y0 == y2) return;       /* last pixel -> curve finished */
		  y1 = 2*err < dx;                       /* save value for test of y step */
		  if (2*err > dy) { x0 += sx; dx -= xy; err += dy += yy; }      /* x step */
		  if (    y1    ) { y0 += sy; dy -= xy; err += dx += xx; }      /* y step */
		} while (dy < 0 && dx > 0);        /* gradient negates -> algorithm fails */
	  }
	  drawLine(g1, x0,y0, x2,y2,color);                       /* plot remaining part to end */
	}

	/* plot any quadratic Bezier curve */
	public static function drawQuadBezier(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int, color:Color):Void
	{
	   var x:Int = x0-x1, y:Int = y0-y1;
	   var t:Float = x0-2*x1+x2, r:Float;

	   if ((Int)x*(x2-x1) > 0) {                        /* horizontal cut at P4? */
		  if ((Int)y*(y2-y1) > 0)                     /* vertical cut at P6 too? */
			 if (Math.abs((y0-2*y1+y2)/t*x) > iabs(y)) {               /* which first? */
				x0 = x2; x2 = x+x1; y0 = y2; y2 = y+y1;            /* swap points */
			 }                            /* now horizontal cut at P4 comes first */
		  t = (x0-x1)/t;
		  r = (1-t)*((1-t)*y0+2.0*t*y1)+t*t*y2;                       /* By(t=P4) */
		  t = (x0*x2-x1*x1)*t/(x0-x1);                       /* gradient dP4/dx=0 */
		  x = Math.floor(t+0.5); y = Math.floor(r+0.5);            
		  r = (y1-y0)*(t-x0)/(x1-x0)+y0;                  /* intersect P3 | P0 P1 */
		  drawQuadBezierSeg(g1,x0,y0, x,Math.floor(r+0.5), x,y,color);
		  r = (y1-y2)*(t-x2)/(x1-x2)+y2;                  /* intersect P4 | P1 P2 */
		  x0 = x1 = x; y0 = y; y1 = Math.floor(r+0.5);             /* P0 = P4, P1 = P8 */
	   }                                                 
	   if ((Int)(y0-y1)*(y2-y1) > 0) {                    /* vertical cut at P6? */
		  t = y0-2*y1+y2; t = (y0-y1)/t;                 
		  r = (1-t)*((1-t)*x0+2.0*t*x1)+t*t*x2;                       /* Bx(t=P6) */
		  t = (y0*y2-y1*y1)*t/(y0-y1);                       /* gradient dP6/dy=0 */
		  x = Math.floor(r+0.5); y = Math.floor(t+0.5);            
		  r = (x1-x0)*(t-y0)/(y1-y0)+x0;                  /* intersect P6 | P0 P1 */
		  drawQuadBezierSeg(g1,x0,y0, Math.floor(r+0.5),y, x,y,color);
		  r = (x1-x2)*(t-y2)/(y1-y2)+x2;                  /* intersect P7 | P1 P2 */
		  x0 = x; x1 = Math.floor(r+0.5); y0 = y1 = y;             /* P0 = P6, P1 = P7 */
	   }
	   drawQuadBezierSeg(g1,x0,y0, x1,y1, x2,y2,color);                  /* remaining part */
	}

	/* plot a limited rational Bezier segment, squared weight */
	public static function drawQuadRationalBezierSeg(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int, w:Float, color:Color):Void                               
	{
	  var sx:Int = x2-x1, sy:Int = y2-y1;                   /* relative values for checks */
	  var dx:Float = x0-x2, dy:Float = y0-y2, xx:Float = x0-x1, yy:Float = y0-y1;
	  var xy:Float = xx*sy+yy*sx, cur:Float = xx*sy-yy*sx, err:Float;               /* curvature */

	  //assert(xx*sx <= 0.0 && yy*sy <= 0.0);   /* sign of gradient must not change */

	  if (cur != 0.0 && w > 0.0) {                            /* no straight line */
		if (sx*(Int)sx+sy*(Int)sy > xx*xx+yy*yy) {    /* begin with longer part */
		  x2 = x0; x0 -= dx; y2 = y0; y0 -= dy; cur = -cur;         /* swap P0 P2 */
		}
		xx = 2.0*(4.0*w*sx*xx+dx*dx);                   /* differences 2nd degree */
		yy = 2.0*(4.0*w*sy*yy+dy*dy);
		sx = x0 < x2 ? 1 : -1;                                /* x step direction */
		sy = y0 < y2 ? 1 : -1;                                /* y step direction */
		xy = -2.0*sx*sy*(2.0*w*xy+dx*dy);

		if (cur*sx*sy < 0.0) {                              /* negated curvature? */
		  xx = -xx; yy = -yy; xy = -xy; cur = -cur;
		}
		dx = 4.0*w*(x1-x0)*sy*cur+xx/2.0+xy;            /* differences 1st degree */
		dy = 4.0*w*(y0-y1)*sx*cur+yy/2.0+xy;

		if (w < 0.5 && (dy > xy || dx < xy)) {   /* flat ellipse, algorithm fails */
		   cur = (w+1.0)/2.0; w = Math.sqrt(w); xy = 1.0/(w+1.0);
		   sx = Math.floor((x0+2.0*w*x1+x2)*xy/2.0+0.5);    /* subdivide curve in half */
		   sy = Math.floor((y0+2.0*w*y1+y2)*xy/2.0+0.5);
		   dx = Math.floor((w*x1+x0)*xy+0.5); dy = Math.floor((y1*w+y0)*xy+0.5);
		   drawQuadRationalBezierSeg(g1,x0,y0, dx,dy, sx,sy, cur,color);/* plot separately */
		   dx = Math.floor((w*x1+x2)*xy+0.5); dy = Math.floor((y1*w+y2)*xy+0.5);
		   drawQuadRationalBezierSeg(g1,sx,sy, dx,dy, x2,y2, cur,color);
		   return;
		}
		err = dx+dy-xy;                                           /* error 1.step */
		do {
		  setPixel(x0,y0);                                          /* plot curve */
		  if (x0 == x2 && y0 == y2) return;       /* last pixel -> curve finished */
		  x1 = 2*err > dy; y1 = 2*(err+yy) < -dy;/* save value for test of x step */
		  if (2*err < dx || y1) { y0 += sy; dy += xy; err += dx += xx; }/* y step */
		  if (2*err > dx || x1) { x0 += sx; dx += xy; err += dy += yy; }/* x step */
		} while (dy <= xy && dx >= xy);    /* gradient negates -> algorithm fails */
	  }
	  drawLine(x0,y0, x2,y2);                     /* plot remaining needle to end */
	}

	/* plot any quadratic rational Bezier curve */
	public static function drawQuadRationalBezier(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int, w:Float, color:Color):Void                            
	{                                 
	   var x:Int = x0-2*x1+x2, y:Int = y0-2*y1+y2;
	   var xx:Float = x0-x1, yy:Float = y0-y1, ww:Float, t:Float, q:Float;

	   //assert(w >= 0.0);

	   if (xx*(x2-x1) > 0) {                             /* horizontal cut at P4? */
		  if (yy*(y2-y1) > 0)                          /* vertical cut at P6 too? */
			 if (Math.abs(xx*y) > Math.abs(yy*x)) {                       /* which first? */
				x0 = x2; x2 = xx+x1; y0 = y2; y2 = yy+y1;          /* swap points */
			 }                            /* now horizontal cut at P4 comes first */
		  if (x0 == x2 || w == 1.0) t = (x0-x1)/(Float)x;
		  else {                                 /* non-rational or rational case */
			 q = Math.sqrt(4.0*w*w*(x0-x1)*(x2-x1)+(x2-x0)*(Int)(x2-x0));
			 if (x1 < x0) q = -q;
			 t = (2.0*w*(x0-x1)-x0+x2+q)/(2.0*(1.0-w)*(x2-x0));        /* t at P4 */
		  }
		  q = 1.0/(2.0*t*(1.0-t)*(w-1.0)+1.0);                 /* sub-divide at t */
		  xx = (t*t*(x0-2.0*w*x1+x2)+2.0*t*(w*x1-x0)+x0)*q;               /* = P4 */
		  yy = (t*t*(y0-2.0*w*y1+y2)+2.0*t*(w*y1-y0)+y0)*q;
		  ww = t*(w-1.0)+1.0; ww *= ww*q;                    /* squared weight P3 */
		  w = ((1.0-t)*(w-1.0)+1.0)*Math.sqrt(q);                         /* weight P8 */
		  x = Math.floor(xx+0.5); y = Math.floor(yy+0.5);                             /* P4 */
		  yy = (xx-x0)*(y1-y0)/(x1-x0)+y0;                /* intersect P3 | P0 P1 */
		  drawQuadRationalBezierSeg(g1,x0,y0, x,Math.floor(yy+0.5), x,y, ww,color);
		  yy = (xx-x2)*(y1-y2)/(x1-x2)+y2;                /* intersect P4 | P1 P2 */
		  y1 = Math.floor(yy+0.5); x0 = x1 = x; y0 = y;            /* P0 = P4, P1 = P8 */
	   }
	   if ((y0-y1)*(Int)(y2-y1) > 0) {                    /* vertical cut at P6? */
		  if (y0 == y2 || w == 1.0) t = (y0-y1)/(y0-2.0*y1+y2);
		  else {                                 /* non-rational or rational case */
			 q = Math.sqrt(4.0*w*w*(y0-y1)*(y2-y1)+(y2-y0)*(Int)(y2-y0));
			 if (y1 < y0) q = -q;
			 t = (2.0*w*(y0-y1)-y0+y2+q)/(2.0*(1.0-w)*(y2-y0));        /* t at P6 */
		  }
		  q = 1.0/(2.0*t*(1.0-t)*(w-1.0)+1.0);                 /* sub-divide at t */
		  xx = (t*t*(x0-2.0*w*x1+x2)+2.0*t*(w*x1-x0)+x0)*q;               /* = P6 */
		  yy = (t*t*(y0-2.0*w*y1+y2)+2.0*t*(w*y1-y0)+y0)*q;
		  ww = t*(w-1.0)+1.0; ww *= ww*q;                    /* squared weight P5 */
		  w = ((1.0-t)*(w-1.0)+1.0)*Math.sqrt(q);                         /* weight P7 */
		  x = Math.floor(xx+0.5); y = Math.floor(yy+0.5);                             /* P6 */
		  xx = (x1-x0)*(yy-y0)/(y1-y0)+x0;                /* intersect P6 | P0 P1 */
		  drawQuadRationalBezierSeg(g1,x0,y0, Math.floor(xx+0.5),y, x,y, ww,color);
		  xx = (x1-x2)*(yy-y2)/(y1-y2)+x2;                /* intersect P7 | P1 P2 */
		  x1 = Math.floor(xx+0.5); x0 = x; y0 = y1 = y;            /* P0 = P6, P1 = P7 */
	   }
	   drawQuadRationalBezierSeg(g1,x0,y0, x1,y1, x2,y2, w*w,color);          /* remaining */
	}

	/* plot ellipse rotated by angle (radian) */
	public static function drawRotatedEllipse(g1:Graphics, x:Int, y:Int, a:Int, b:Int, angle:Float, color:Color):Void
	{
	   var xd:Float = (Int)a*a, yd:Float = (Int)b*b;
	   var s:Float = Math.sin(angle), zd:Float = (xd-yd)*s;                  /* ellipse rotation */
	   xd = Math.sqrt(xd-zd*s), yd = Math.sqrt(yd+zd*s);           /* surrounding rectangle */
	   a = xd+0.5; b = yd+0.5; zd = zd*a*b/(xd*yd);           /* scale to integer */
	   drawRotatedEllipseRect(g1,x-a,y-b, x+a,y+b, (Int)(4*zd*Math.cos(angle)),color);
	}

	/* rectangle enclosing the ellipse, integer rotation angle */
	public static function drawRotatedEllipseRect(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, zd:Int, color:Color):Void
	{
	   var xd:Int = x1-x0, yd:Int = y1-y0;
	   var w:Float = xd*(Int)yd;
	   if (zd == 0) return drawEllipseRect(g1,x0,y0, x1,y1,color);          /* looks nicer */
	   if (w != 0.0) w = (w-zd)/(w+w);                    /* squared weight of P1 */
	   //assert(w <= 1.0 && w >= 0.0);                /* limit angle to |zd|<=xd*yd */
	   xd = Math.floor(xd*w+0.5); yd = Math.floor(yd*w+0.5);           /* snap xe,ye to Int */
	   drawQuadRationalBezierSeg(g1,x0,y0+yd, x0,y0, x0+xd,y0, 1.0-w,color);
	   drawQuadRationalBezierSeg(g1,x0,y0+yd, x0,y1, x1-xd,y1, w,color);
	   drawQuadRationalBezierSeg(g1,x1,y1-yd, x1,y1, x1-xd,y1, 1.0-w,color);
	   drawQuadRationalBezierSeg(g1,x1,y1-yd, x1,y0, x0+xd,y0, w,color);
	}

	/* plot limited cubic Bezier segment */
	// TODO: convert pointers
	//public static function drawCubicBezierSeg(g1:Graphics, x0:Int, y0:Int, x1:Float, y1:Float, x2:Float, y2:Float, x3:Int, y3:Int, color:Color):Void                        
	//{
	   //var f:Int, fx:Int, fy:Int, leg:Int = 1;
	   //var sx:Int = x0 < x3 ? 1 : -1, sy:Int = y0 < y3 ? 1 : -1;        /* step direction */
	   //var xc:Float = -Math.abs(x0+x1-x2-x3), xa:Float = xc-4*sx*(x1-x2), xb:Float = sx*(x0-x1-x2+x3);
	   //var yc:Float = -Math.abs(y0+y1-y2-y3), ya:Float = yc-4*sy*(y1-y2), yb:Float = sy*(y0-y1-y2+y3);
	   //var ab:Float, ac:Float, bc:Float, cb:Float, xx:Float, xy:Float, yy:Float, dx:Float, dy:Float, ex:Float, *pxy:Float, EP:Float = 0.01;
													 ///* check for curve restrains */
	   ///* slope P0-P1 == P2-P3    and  (P0-P3 == P1-P2      or   no slope change) */
	   ////assert((x1-x0)*(x2-x3) < EP && ((x3-x0)*(x1-x2) < EP || xb*xb < xa*xc+EP));
	   ////assert((y1-y0)*(y2-y3) < EP && ((y3-y0)*(y1-y2) < EP || yb*yb < ya*yc+EP));
//
	   //if (xa == 0 && ya == 0) {                              /* quadratic Bezier */
		  //sx = Math.floor((3*x1-x0+1)/2); sy = Math.floor((3*y1-y0+1)/2);   /* new midpoint */
		  //return drawQuadBezierSeg(x0,y0, sx,sy, x3,y3);
	   //}
	   //x1 = (x1-x0)*(x1-x0)+(y1-y0)*(y1-y0)+1;                    /* line lengths */
	   //x2 = (x2-x3)*(x2-x3)+(y2-y3)*(y2-y3)+1;
	   //do {                                                /* loop over both ends */
		  //ab = xa*yb-xb*ya; ac = xa*yc-xc*ya; bc = xb*yc-xc*yb;
		  //ex = ab*(ab+ac-3*bc)+ac*ac;       /* P0 part of self-intersection loop? */
		  //f = ex > 0 ? 1 : Math.sqrt(1+1024/x1);               /* calculate resolution */
		  //ab *= f; ac *= f; bc *= f; ex *= f*f;            /* increase resolution */
		  //xy = 9*(ab+ac+bc)/8; cb = 8*(xa-ya);  /* init differences of 1st degree */
		  //dx = 27*(8*ab*(yb*yb-ya*yc)+ex*(ya+2*yb+yc))/64-ya*ya*(xy-ya);
		  //dy = 27*(8*ab*(xb*xb-xa*xc)-ex*(xa+2*xb+xc))/64-xa*xa*(xy+xa);
												///* init differences of 2nd degree */
		  //xx = 3*(3*ab*(3*yb*yb-ya*ya-2*ya*yc)-ya*(3*ac*(ya+yb)+ya*cb))/4;
		  //yy = 3*(3*ab*(3*xb*xb-xa*xa-2*xa*xc)-xa*(3*ac*(xa+xb)+xa*cb))/4;
		  //xy = xa*ya*(6*ab+6*ac-3*bc+cb); ac = ya*ya; cb = xa*xa;
		  //xy = 3*(xy+9*f*(cb*yb*yc-xb*xc*ac)-18*xb*yb*ab)/8;
//
		  //if (ex < 0) {         /* negate values if inside self-intersection loop */
			 //dx = -dx; dy = -dy; xx = -xx; yy = -yy; xy = -xy; ac = -ac; cb = -cb;
		  //}                                     /* init differences of 3rd degree */
		  //ab = 6*ya*ac; ac = -6*xa*ac; bc = 6*ya*cb; cb = -6*xa*cb;
		  //dx += xy; ex = dx+dy; dy += xy;                    /* error of 1st step */
//
		  //for (pxy = &xy, fx = fy = f; x0 != x3 && y0 != y3; ) {
			 //setPixel(x0,y0);                                       /* plot curve */
			 //do {                                  /* move sub-steps of one pixel */
				//if (dx > *pxy || dy < *pxy) goto exit;       /* confusing values */
				//y1 = 2*ex-dy;                    /* save value for test of y step */
				//if (2*ex >= dx) {                                   /* x sub-step */
				   //fx--; ex += dx += xx; dy += xy += ac; yy += bc; xx += ab;
				//}
				//if (y1 <= 0) {                                      /* y sub-step */
				   //fy--; ex += dy += yy; dx += xy += bc; xx += ac; yy += cb;
				//}
			 //} while (fx > 0 && fy > 0);                       /* pixel complete? */
			 //if (2*fx <= f) { x0 += sx; fx += f; }                      /* x step */
			 //if (2*fy <= f) { y0 += sy; fy += f; }                      /* y step */
			 //if (pxy == &xy && dx < 0 && dy > 0) pxy = &EP;  /* pixel ahead valid */
		  //}
	//exit: xx = x0; x0 = x3; x3 = xx; sx = -sx; xb = -xb;             /* swap legs */
		  //yy = y0; y0 = y3; y3 = yy; sy = -sy; yb = -yb; x1 = x2;
	   //} while (leg--);                                          /* try other end */
	   //drawLine(x0,y0, x3,y3);       /* remaining part in case of cusp or crunode */
	//}

	/* plot any cubic Bezier curve */
	public static function drawCubicBezier(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, color:Color):Void                     
	{
	   var n:Int = 0, i:Int = 0;
	   var xc:Int = x0+x1-x2-x3, xa:Int = xc-4*(x1-x2);
	   var xb:Int = x0-x1-x2+x3, xd:Int = xb+4*(x1+x2);
	   var yc:Int = y0+y1-y2-y3, ya:Int = yc-4*(y1-y2);
	   var yb:Int = y0-y1-y2+y3, yd:Int = yb+4*(y1+y2);
	   var fx0:Float = x0, fx1:Float, fx2:Float, fx3:Float, fy0:Float = y0, fy1:Float, fy2:Float, fy3:Float;
	   var t1:Float = xb*xb-xa*xc, t2:Float, t = new Vector<Float>(5);
									 /* sub-divide curve at gradient sign changes */
	   if (xa == 0) {                                               /* horizontal */
		  if (iabs(xc) < 2*iabs(xb)) t[n++] = xc/(2.0*xb);            /* one change */
	   } else if (t1 > 0.0) {                                      /* two changes */
		  t2 = Math.sqrt(t1);
		  t1 = (xb-t2)/xa; if (Math.abs(t1) < 1.0) t[n++] = t1;
		  t1 = (xb+t2)/xa; if (Math.abs(t1) < 1.0) t[n++] = t1;
	   }
	   t1 = yb*yb-ya*yc;
	   if (ya == 0) {                                                 /* vertical */
		  if (iabs(yc) < 2*iabs(yb)) t[n++] = yc/(2.0*yb);            /* one change */
	   } else if (t1 > 0.0) {                                      /* two changes */
		  t2 = Math.sqrt(t1);
		  t1 = (yb-t2)/ya; if (Math.abs(t1) < 1.0) t[n++] = t1;
		  t1 = (yb+t2)/ya; if (Math.abs(t1) < 1.0) t[n++] = t1;
	   }
	   for (i = 1; i < n; i++)                         /* bubble sort of 4 points */
		  if ((t1 = t[i-1]) > t[i]) { t[i-1] = t[i]; t[i] = t1; i = 0; }

	   t1 = -1.0; t[n] = 1.0;                                /* begin / end point */
	   for (i = 0; i <= n; i++) {                 /* plot each segment separately */
		  t2 = t[i];                                /* sub-divide at t[i-1], t[i] */
		  fx1 = (t1*(t1*xb-2*xc)-t2*(t1*(t1*xa-2*xb)+xc)+xd)/8-fx0;
		  fy1 = (t1*(t1*yb-2*yc)-t2*(t1*(t1*ya-2*yb)+yc)+yd)/8-fy0;
		  fx2 = (t2*(t2*xb-2*xc)-t1*(t2*(t2*xa-2*xb)+xc)+xd)/8-fx0;
		  fy2 = (t2*(t2*yb-2*yc)-t1*(t2*(t2*ya-2*yb)+yc)+yd)/8-fy0;
		  fx0 -= fx3 = (t2*(t2*(3*xb-t2*xa)-3*xc)+xd)/8;
		  fy0 -= fy3 = (t2*(t2*(3*yb-t2*ya)-3*yc)+yd)/8;
		  x3 = Math.floor(fx3+0.5); y3 = Math.floor(fy3+0.5);        /* scale bounds to Int */
		  if (fx0 != 0.0) { fx1 *= fx0 = (x0-x3)/fx0; fx2 *= fx0; }
		  if (fy0 != 0.0) { fy1 *= fy0 = (y0-y3)/fy0; fy2 *= fy0; }
		  if (x0 != x3 || y0 != y3)                            /* segment t1 - t2 */
			 drawCubicBezierSeg(g1, x0,y0, x0+fx1,y0+fy1, x0+fx2,y0+fy2, x3,y3, color);
		  x0 = x3; y0 = y3; fx0 = fx3; fy0 = fy3; t1 = t2;
	   }
	}

	/* draw a black (0) anti-aliased line on white (255) background */
	public static function drawLineAA(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, color:Color):Void
	{
	   var sx:Int = x0 < x1 ? 1 : -1, sy:Int = y0 < y1 ? 1 : -1, x2:Int;
	   var dx:Int = iabs(x1-x0), dy:Int = iabs(y1-y0), err:Int = dx*dx+dy*dy;
	   var e2:Int = err == 0 ? 1 : 0xffff7fl/Math.sqrt(err);     /* multiplication factor */

	   dx *= e2; dy *= e2; err = dx-dy;                       /* error value e_xy */
	   while (true){                                                 /* pixel loop */
		  setPixelAA(g1, x0,y0, color,iabs(err-dx+dy)>>16);
		  e2 = err; x2 = x0;
		  if (2*e2 >= -dx) {                                            /* x step */
			 if (x0 == x1) break;
			 if (e2+dy < 0xff0000l) setPixelAA(g1, x0,y0+sy, color,(e2+dy)>>16);
			 err -= dy; x0 += sx; 
		  } 
		  if (2*e2 <= dy) {                                             /* y step */
			 if (y0 == y1) break;
			 if (dx-e2 < 0xff0000l) setPixelAA(g1, x2+sx,y0, color,(dx-e2)>>16);
			 err += dx; y0 += sy; 
		}
	}

	/* draw a black anti-aliased circle on white background */
	public static function drawCircleAA(g1:Graphics, xm:Int, ym:Int, r:Int, color:Color):Void
	{
	   var x:Int = -r, y:Int = 0;           /* II. quadrant from bottom left to top right */
	   var i:Int, x2:Int, e2:Int, err:Int = 2-2*r;                             /* error of 1.step */
	   r = 1-err;
	   do {
		  i = 255*iabs(err-2*(x+y)-2)/r;               /* get blend value of pixel */
		  setPixelAA(g1, xm-x, ym+y, color,i);                             /*   I. Quadrant */
		  setPixelAA(g1, xm-y, ym-x, color,i);                             /*  II. Quadrant */
		  setPixelAA(g1, xm+x, ym-y, color,i);                             /* III. Quadrant */
		  setPixelAA(g1, xm+y, ym+x, color,i);                             /*  IV. Quadrant */
		  e2 = err; x2 = x;                                    /* remember values */
		  if (err+y > 0) {                                              /* x step */
			 i = 255*(err-2*x-1)/r;                              /* outward pixel */
			 if (i < 256) {
				setPixelAA(g1, xm-x, ym+y+1, color,i);
				setPixelAA(g1, xm-y-1, ym-x, color,i);
				setPixelAA(g1, xm+x, ym-y-1, color,i);
				setPixelAA(g1, xm+y+1, ym+x, color,i);
			 }
			 err += ++x*2+1;
		  }
		  if (e2+x2 <= 0) {                                             /* y step */
			 i = 255*(2*y+3-e2)/r;                                /* inward pixel */
			 if (i < 256) {
				setPixelAA(g1, xm-x2-1, ym+y, color,i);
				setPixelAA(g1, xm-y, ym-x2-1, color,i);
				setPixelAA(g1, xm+x2+1, ym-y, color,i);
				setPixelAA(g1, xm+y, ym+x2+1, color,i);
			 }
			 err += ++y*2+1;
		  }
	   } while (x < 0);
	}

	/* draw a black anti-aliased rectangular ellipse on white background */
	public static function drawEllipseRectAA(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, color:Color):Void
	{
	   var a:Int = iabs(x1-x0), b:Int = iabs(y1-y0), b1:Int = b&1;                 /* diameter */
	   var dx:Float = 4*(a-1.0)*b*b, dy:Float = 4*(b1+1)*a*a;            /* error increment */
	   var ed:Float, i:Float, err:Float = b1*a*a-dx+dy;                        /* error of 1.step */
	   var f:Bool;

	   if (a == 0 || b == 0) return drawLine(g1, x0,y0, x1,y1, color);
	   if (x0 > x1) { x0 = x1; x1 += a; }        /* if called with swapped points */
	   if (y0 > y1) y0 = y1;                                  /* .. exchange them */
	   y0 += (b+1)/2; y1 = y0-b1;                               /* starting pixel */
	   a = 8*a*a; b1 = 8*b*b;

	   while (true) {                             /* approximate ed=Math.sqrt(dx*dx+dy*dy) */
		  i = min(dx,dy); ed = max(dx,dy);
		  if (y0 == y1+1 && err > dy && a > b1) ed = 255*4./a;           /* x-tip */
		  else ed = 255/(ed+2*ed*i*i/(4*ed*ed+i*i));             /* approximation */
		  i = ed*Math.abs(err+dx-dy);           /* get intensity value by pixel error */
		  setPixelAA(g1, x0,y0, color,i); setPixelAA(g1, x0,y1, color,i);
		  setPixelAA(g1, x1,y0, color,i); setPixelAA(g1, x1,y1, color,i);
					   
		  if (f = 2*err+dy >= 0) {                  /* x step, remember condition */
			 if (x0 >= x1) break;
			 i = ed*(err+dx);
			 if (i < 255) {
				setPixelAA(g1, x0,y0+1, color,i); setPixelAA(g1, x0,y1-1, color,i);
				setPixelAA(g1, x1,y0+1, color,i); setPixelAA(g1, x1,y1-1, color,i);
			 }          /* do error increment later since values are still needed */
		  } 
		  if (2*err <= dx) {                                            /* y step */
			 i = ed*(dy-err);
			 if (i < 255) {
				setPixelAA(g1, x0+1,y0, color,i); setPixelAA(g1, x1-1,y0, color,i);
				setPixelAA(g1, x0+1,y1, color,i); setPixelAA(g1, x1-1,y1, color,i);
			 }
			 y0++; y1--; err += dy += a; 
		  }  
		  if (f) { x0++; x1--; err -= dx -= b1; }            /* x error increment */
	   } 
	   if (--x0 == x1++)                       /* too early stop of flat ellipses */
		  while (y0-y1 < b) {
			 i = 255*4*Math.abs(err+dx)/b1;               /* -> finish tip of ellipse */
			 setPixelAA(g1, x0,++y0, color,i); setPixelAA(g1, x1,y0, color,i);
			 setPixelAA(g1, x0,--y1, color,i); setPixelAA(g1, x1,y1, color,i);
			 err += dy += a; 
		  }
	}

	/* draw an limited anti-aliased quadratic Bezier segment */
	public static function drawQuadBezierSegAA(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int, color:Color):Void
	{
	   var sx:Int = x2-x1, sy:Int = y2-y1;
	   var xx:Int = x0-x1, yy:Int = y0-y1, xy:Int;             /* relative values for checks */
	   var dx:Float, dy:Float, err:Float, ed:Float, cur:Float = xx*sy-yy*sx;                    /* curvature */

	   //assert(xx*sx <= 0 && yy*sy <= 0);      /* sign of gradient must not change */

	   if (sx*(Int)sx+sy*(Int)sy > xx*xx+yy*yy) {     /* begin with longer part */
		  x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur;     /* swap P0 P2 */
	   }
	   if (cur != 0)
	   {                                                      /* no straight line */
		  xx += sx; xx *= sx = x0 < x2 ? 1 : -1;              /* x step direction */
		  yy += sy; yy *= sy = y0 < y2 ? 1 : -1;              /* y step direction */
		  xy = 2*xx*yy; xx *= xx; yy *= yy;             /* differences 2nd degree */
		  if (cur*sx*sy < 0) {                              /* negated curvature? */
			 xx = -xx; yy = -yy; xy = -xy; cur = -cur;
		  }
		  dx = 4.0*sy*(x1-x0)*cur+xx-xy;                /* differences 1st degree */
		  dy = 4.0*sx*(y0-y1)*cur+yy-xy;
		  xx += xx; yy += yy; err = dx+dy+xy;                   /* error 1st step */
		  do {
			 cur = fmin(dx+xy,-xy-dy);
			 ed = fmax(dx+xy,-xy-dy);               /* approximate error distance */
			 ed += 2*ed*cur*cur/(4*ed*ed+cur*cur);
			 setPixelAA(g1, x0,y0, color,255*Math.abs(err-dx-dy-xy)/ed);          /* plot curve */
			 if (x0 == x2 || y0 == y2) break;     /* last pixel -> curve finished */
			 x1 = x0; cur = dx-err; y1 = 2*err+dy < 0;
			 if (2*err+dx > 0) {                                        /* x step */
				if (err-dy < ed) setPixelAA(g1, x0,y0+sy, color,255*Math.abs(err-dy)/ed);
				x0 += sx; dx -= xy; err += dy += yy;
			 }
			 if (y1) {                                                  /* y step */
				if (cur < ed) setPixelAA(g1, x1+sx,y0, color,255*Math.abs(cur)/ed);
				y0 += sy; dy -= xy; err += dx += xx;
			 }
		  } while (dy < dx);                  /* gradient negates -> close curves */
	   }
	   drawLineAA(g1, x0,y0, x2,y2,color);                  /* plot remaining needle to end */
	}

	/* draw an anti-aliased rational quadratic Bezier segment, squared weight */
	public static function drawQuadRationalBezierSegAA(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int, w:Float, color:Color):Void                    
	{
	   var sx:Int = x2-x1, sy:Int = y2-y1;                  /* relative values for checks */
	   var dx:Float = x0-x2, dy:Float = y0-y2, xx:Float = x0-x1, yy:Float = y0-y1;
	   var xy:Float = xx*sy+yy*sx, cur:Float = xx*sy-yy*sx, err:Float, ed:Float;          /* curvature */
	   var f:Bool;

	   //assert(xx*sx <= 0.0 && yy*sy <= 0.0);  /* sign of gradient must not change */

	   if (cur != 0.0 && w > 0.0) {                           /* no straight line */
		  if (sx*(Int)sx+sy*(Int)sy > xx*xx+yy*yy) {  /* begin with longer part */
			 x2 = x0; x0 -= dx; y2 = y0; y0 -= dy; cur = -cur;      /* swap P0 P2 */
		  }
		  xx = 2.0*(4.0*w*sx*xx+dx*dx);                 /* differences 2nd degree */
		  yy = 2.0*(4.0*w*sy*yy+dy*dy);
		  sx = x0 < x2 ? 1 : -1;                              /* x step direction */
		  sy = y0 < y2 ? 1 : -1;                              /* y step direction */
		  xy = -2.0*sx*sy*(2.0*w*xy+dx*dy);

		  if (cur*sx*sy < 0) {                              /* negated curvature? */
			 xx = -xx; yy = -yy; cur = -cur; xy = -xy;
		  }
		  dx = 4.0*w*(x1-x0)*sy*cur+xx/2.0+xy;          /* differences 1st degree */
		  dy = 4.0*w*(y0-y1)*sx*cur+yy/2.0+xy;

		  if (w < 0.5 && dy > dx) {              /* flat ellipse, algorithm fails */
			 cur = (w+1.0)/2.0; w = Math.sqrt(w); xy = 1.0/(w+1.0);
			 sx = Math.floor((x0+2.0*w*x1+x2)*xy/2.0+0.5); /* subdivide curve in half  */
			 sy = Math.floor((y0+2.0*w*y1+y2)*xy/2.0+0.5);
			 dx = Math.floor((w*x1+x0)*xy+0.5); dy = Math.floor((y1*w+y0)*xy+0.5);
			 drawQuadRationalBezierSegAA(g1, x0,y0, dx,dy, sx,sy, cur,color); /* plot apart */
			 dx = Math.floor((w*x1+x2)*xy+0.5); dy = Math.floor((y1*w+y2)*xy+0.5);
			 return drawQuadRationalBezierSegAA(g1, sx,sy, dx,dy, x2,y2, cur,color);
		  }
		  err = dx+dy-xy;                                       /* error 1st step */
		  do {                                                      /* pixel loop */
			 cur = fmin(dx-xy,xy-dy); ed = fmax(dx-xy,xy-dy);
			 ed += 2*ed*cur*cur/(4.*ed*ed+cur*cur); /* approximate error distance */
			 x1 = 255*Math.abs(err-dx-dy+xy)/ed;    /* get blend value by pixel error */
			 if (x1 < 256) setPixelAA(x0,y0, x1);                   /* plot curve */
			 if (f = 2*err+dy < 0) {                                    /* y step */
				if (y0 == y2) return;             /* last pixel -> curve finished */
				if (dx-err < ed) setPixelAA(g1, x0+sx,y0, color,255*Math.abs(dx-err)/ed);
			 }
			 if (2*err+dx > 0) {                                        /* x step */
				if (x0 == x2) return;             /* last pixel -> curve finished */
				if (err-dy < ed) setPixelAA(g1, x0,y0+sy, color,255*Math.abs(err-dy)/ed);
				x0 += sx; dx += xy; err += dy += yy;
			 }
			 if (f) { y0 += sy; dy += xy; err += dx += xx; }            /* y step */
		  } while (dy < dx);               /* gradient negates -> algorithm fails */
	   }
	   drawLineAA(g1, x0,y0, x2,y2, color);                  /* plot remaining needle to end */
	}

	/* plot limited anti-aliased cubic Bezier segment */
	// TODO: remove goto
	//public static function drawCubicBezierSegAA(g1:Graphics, x0:Int, y0:Int, x1:Float, y1:Float, x2:Float, y2:Float, x3:Int, y3:Int, color:Color):Void
	//{
	   //var f:Int, fx:Int, fy:Int, leg:Int = 1;
	   //var sx:Int = x0 < x3 ? 1 : -1, sy:Int = y0 < y3 ? 1 : -1;        /* step direction */
	   //var xc:Float = -Math.abs(x0+x1-x2-x3), xa:Float = xc-4*sx*(x1-x2), xb:Float = sx*(x0-x1-x2+x3);
	   //var yc:Float = -Math.abs(y0+y1-y2-y3), ya:Float = yc-4*sy*(y1-y2), yb:Float = sy*(y0-y1-y2+y3);
	   //var ab:Float, ac:Float, bc:Float, ba:Float, xx:Float, xy:Float, yy:Float, dx:Float, dy:Float, ex:Float, px:Float, py:Float, ed:Float, ip:Float, EP:Float = 0.01;
//
													 ///* check for curve restrains */
	   ///* slope P0-P1 == P2-P3     and  (P0-P3 == P1-P2      or  no slope change) */
	   ////assert((x1-x0)*(x2-x3) < EP && ((x3-x0)*(x1-x2) < EP || xb*xb < xa*xc+EP));
	   ////assert((y1-y0)*(y2-y3) < EP && ((y3-y0)*(y1-y2) < EP || yb*yb < ya*yc+EP));
//
	   //if (xa == 0 && ya == 0) {                              /* quadratic Bezier */
		  //sx = Math.floor((3*x1-x0+1)/2); sy = Math.floor((3*y1-y0+1)/2);   /* new midpoint */
		  //return drawQuadBezierSegAA(g1, x0,y0, sx,sy, x3,y3, color);
	   //}
	   //x1 = (x1-x0)*(x1-x0)+(y1-y0)*(y1-y0)+1;                    /* line lengths */
	   //x2 = (x2-x3)*(x2-x3)+(y2-y3)*(y2-y3)+1;
	   //do {                                                /* loop over both ends */
		  //ab = xa*yb-xb*ya; ac = xa*yc-xc*ya; bc = xb*yc-xc*yb;
		  //ip = 4*ab*bc-ac*ac;                   /* self intersection loop at all? */
		  //ex = ab*(ab+ac-3*bc)+ac*ac;       /* P0 part of self-intersection loop? */
		  //f = ex > 0 ? 1 : Math.sqrt(1+1024/x1);               /* calculate resolution */
		  //ab *= f; ac *= f; bc *= f; ex *= f*f;            /* increase resolution */
		  //xy = 9*(ab+ac+bc)/8; ba = 8*(xa-ya);  /* init differences of 1st degree */
		  //dx = 27*(8*ab*(yb*yb-ya*yc)+ex*(ya+2*yb+yc))/64-ya*ya*(xy-ya);
		  //dy = 27*(8*ab*(xb*xb-xa*xc)-ex*(xa+2*xb+xc))/64-xa*xa*(xy+xa);
												///* init differences of 2nd degree */
		  //xx = 3*(3*ab*(3*yb*yb-ya*ya-2*ya*yc)-ya*(3*ac*(ya+yb)+ya*ba))/4;
		  //yy = 3*(3*ab*(3*xb*xb-xa*xa-2*xa*xc)-xa*(3*ac*(xa+xb)+xa*ba))/4;
		  //xy = xa*ya*(6*ab+6*ac-3*bc+ba); ac = ya*ya; ba = xa*xa;
		  //xy = 3*(xy+9*f*(ba*yb*yc-xb*xc*ac)-18*xb*yb*ab)/8;
//
		  //if (ex < 0) {         /* negate values if inside self-intersection loop */
			 //dx = -dx; dy = -dy; xx = -xx; yy = -yy; xy = -xy; ac = -ac; ba = -ba;
		  //}                                     /* init differences of 3rd degree */
		  //ab = 6*ya*ac; ac = -6*xa*ac; bc = 6*ya*ba; ba = -6*xa*ba;
		  //dx += xy; ex = dx+dy; dy += xy;                    /* error of 1st step */
//
		  //for (fx = fy = f; x0 != x3 && y0 != y3; ) {
			 //y1 = fmin(Math.abs(xy-dx),Math.abs(dy-xy));
			 //ed = fmax(Math.abs(xy-dx),Math.abs(dy-xy));    /* approximate error distance */
			 //ed = f*(ed+2*ed*y1*y1/(4*ed*ed+y1*y1));
			 //y1 = 255*Math.abs(ex-(f-fx+1)*dx-(f-fy+1)*dy+f*xy)/ed;
			 //if (y1 < 256) setPixelAA(g1, x0, y0, color,y1);                  /* plot curve */
			 //px = Math.abs(ex-(f-fx+1)*dx+(fy-1)*dy);       /* pixel intensity x move */
			 //py = Math.abs(ex+(fx-1)*dx-(f-fy+1)*dy);       /* pixel intensity y move */
			 //y2 = y0;
			 //do {                                  /* move sub-steps of one pixel */
				//if (ip >= -EP)               /* intersection possible? -> check.. */
				   //if (dx+xx > xy || dy+yy < xy) goto exit;   /* two x or y steps */
				//y1 = 2*ex+dx;                    /* save value for test of y step */
				//if (2*ex+dy > 0) {                                  /* x sub-step */
				   //fx--; ex += dx += xx; dy += xy += ac; yy += bc; xx += ab;
				//} else if (y1 > 0) goto exit;                 /* tiny nearly cusp */
				//if (y1 <= 0) {                                      /* y sub-step */
				   //fy--; ex += dy += yy; dx += xy += bc; xx += ac; yy += ba;
				//}
			 //} while (fx > 0 && fy > 0);                       /* pixel complete? */
			 //if (2*fy <= f) {                           /* x+ anti-aliasing pixel */
				//if (py < ed) setPixelAA(g1, x0+sx, y0, color,255*py/ed);      /* plot curve */
				//y0 += sy; fy += f;                                      /* y step */
			 //}
			 //if (2*fx <= f) {                           /* y+ anti-aliasing pixel */
				//if (px < ed) setPixelAA(g1, x0, y2+sy, color,255*px/ed);      /* plot curve */
				//x0 += sx; fx += f;                                      /* x step */
			 //}
		  //}
		  //break;                                          /* finish curve by line */
	//exit:
		  //if (2*ex < dy && 2*fy <= f+2) {         /* round x+ approximation pixel */
			 //if (py < ed) setPixelAA(g1, x0+sx, y0, color,255*py/ed);         /* plot curve */
			 //y0 += sy;
		  //}
		  //if (2*ex > dx && 2*fx <= f+2) {         /* round y+ approximation pixel */
			 //if (px < ed) setPixelAA(g1, x0, y2+sy, color,255*px/ed);         /* plot curve */
			 //x0 += sx;
		  //}
		  //xx = x0; x0 = x3; x3 = xx; sx = -sx; xb = -xb;             /* swap legs */
		  //yy = y0; y0 = y3; y3 = yy; sy = -sy; yb = -yb; x1 = x2;
	   //} while (leg--);                                          /* try other end */
	   //drawLineAA(g1, x0,y0, x3,y3, color);     /* remaining part in case of cusp or crunode */
	//}

	/* plot an anti-aliased line of width wd */
	public static function drawLineWidth(g1:Graphics, x0:Int, y0:Int, x1:Int, y1:Int, wd:Float, color:Color):Void
	{
	   var dx:Int = iabs(x1-x0), sx:Int = x0 < x1 ? 1 : -1; 
	   var dy:Int = iabs(y1-y0), sy:Int = y0 < y1 ? 1 : -1; 
	   var err:Int = dx-dy, e2, x2:Int, y2:Int;                           /* error value e_xy */
	   var ed:Float = dx+dy == 0 ? 1 : Math.sqrt((Float)dx*dx+(Float)dy*dy);
														   
	   for (wd = (wd+1)/2; ; ) {                                    /* pixel loop */
		  setPixelColor(g1, x0, y0, color,max(0,255*(abs(err-dx+dy)/ed-wd+1)));
		  e2 = err; x2 = x0;
		  if (2*e2 >= -dx) {                                            /* x step */
			 for (e2 += dy, y2 = y0; e2 < ed*wd && (y1 != y2 || dx > dy); e2 += dx)
				setPixelColor(g1,x0, y2 += sy, color,max(0,255*(iabs(e2)/ed-wd+1)));
			 if (x0 == x1) break;
			 e2 = err; err -= dy; x0 += sx; 
		  } 
		  if (2*e2 <= dy) {                                             /* y step */
			 for (e2 = dx-e2; e2 < ed*wd && (x1 != x2 || dx < dy); e2 += dy)
				setPixelColor(g1, x2 += sx, y0, color,max(0,255*(iabs(e2)/ed-wd+1)));
			 if (y0 == y1) break;
			 err += dx; y0 += sy; 
		  }
	   }
	}

	/* plot quadratic spline, destroys input arrays x,y */
	public static function drawQuadSpline(g1:Graphics, n:Int, Int x[], Int y[], color:Color):Void
	{	   
	   var mi:Float = 1, m = new Vector<Float>(M_MAX);                    /* diagonal constants of matrix */
	   var i:Int, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int = x[n], y2:Int = y[n];

	   //assert(n > 1);                        /* need at least 3 points P[0]..P[n] */

	   x[1] = x0 = 8*x[1]-2*x[0];                          /* first row of matrix */
	   y[1] = y0 = 8*y[1]-2*y[0];

	   for (i = 2; i < n; i++) {                                 /* forward sweep */
		  if (i-2 < M_MAX) m[i-2] = mi = 1.0/(6.0-mi);
		  x[i] = x0 = Math.floor(8*x[i]-x0*mi+0.5);                        /* store yi */
		  y[i] = y0 = Math.floor(8*y[i]-y0*mi+0.5);
	   }
	   x1 = Math.floor((x0-2*x2)/(5.0-mi)+0.5);                 /* correction last row */
	   y1 = Math.floor((y0-2*y2)/(5.0-mi)+0.5);

	   for (i = n-2; i > 0; i--) {                           /* back substitution */
		  if (i <= M_MAX) mi = m[i-1];
		  x0 = Math.floor((x[i]-x1)*mi+0.5);                            /* next corner */
		  y0 = Math.floor((y[i]-y1)*mi+0.5);
		  drawQuadBezier(g1, (x0+x1)/2,(y0+y1)/2, x1,y1, x2,y2, color);
		  x2 = (x0+x1)/2; x1 = x0;
		  y2 = (y0+y1)/2; y1 = y0;
	   }
	   drawQuadBezier(g1, x[0],y[0], x1,y1, x2,y2,color);
	}

	/* plot cubic spline, destroys input arrays x,y */
	public static function drawCubicSpline(g1:Graphics, n:Int, x:Vector<Int>, y:Vector<Int>, color:Color):Void
	{	   
	   var mi:Float = 0.25, m = new Vector<Float>(M_MAX);                 /* diagonal constants of matrix */
	   var x3:Int = x[n-1], y3:Int = y[n-1], x4:Int = x[n], y4:Int = y[n];
	   var i:Int, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int;

	   //assert(n > 2);                        /* need at least 4 points P[0]..P[n] */

	   x[1] = x0 = 12*x[1]-3*x[0];                         /* first row of matrix */
	   y[1] = y0 = 12*y[1]-3*y[0];

	   for (i = 2; i < n; i++) {                                /* foreward sweep */
		  if (i-2 < M_MAX) m[i-2] = mi = 0.25/(2.0-mi);
		  x[i] = x0 = Math.floor(12*x[i]-2*x0*mi+0.5);
		  y[i] = y0 = Math.floor(12*y[i]-2*y0*mi+0.5);
	   }
	   x2 = Math.floor((x0-3*x4)/(7-4*mi)+0.5);                    /* correct last row */
	   y2 = Math.floor((y0-3*y4)/(7-4*mi)+0.5);
	   drawCubicBezier(g1, x3,y3, (x2+x4)/2,(y2+y4)/2, x4,y4, x4,y4, color);

	   if (n-3 < M_MAX) mi = m[n-3];
	   x1 = Math.floor((x[n-2]-2*x2)*mi+0.5);
	   y1 = Math.floor((y[n-2]-2*y2)*mi+0.5);
	   for (i = n-3; i > 0; i--) {                           /* back substitution */
		  if (i <= M_MAX) mi = m[i-1];
		  x0 = Math.floor((x[i]-2*x1)*mi+0.5);
		  y0 = Math.floor((y[i]-2*y1)*mi+0.5);
		  x4 = Math.floor((x0+4*x1+x2+3)/6.0);                     /* reconstruct P[i] */
		  y4 = Math.floor((y0+4*y1+y2+3)/6.0);
		  drawCubicBezier(g1, x4,y4,
						  Math.floor((2*x1+x2)/3+0.5),Math.floor((2*y1+y2)/3+0.5),
						  Math.floor((x1+2*x2)/3+0.5),Math.floor((y1+2*y2)/3+0.5),
						  x3,y3, color);
		  x3 = x4; y3 = y4; x2 = x1; y2 = y1; x1 = x0; y1 = y0;
	   }
	   x0 = x[0]; x4 = Math.floor((3*x0+7*x1+2*x2+6)/12.0);        /* reconstruct P[1] */
	   y0 = y[0]; y4 = Math.floor((3*y0+7*y1+2*y2+6)/12.0);
	   drawCubicBezier(g1, x4,y4, Math.floor((2*x1+x2)/3+0.5),Math.floor((2*y1+y2)/3+0.5),
					   Math.floor((x1+2*x2)/3+0.5),Math.floor((y1+2*y2)/3+0.5), x3,y3, color);
	   drawCubicBezier(g1, x0,y0, x0,y0, (x0+x1)/2,(y0+y1)/2, x4,y4, color);
	}
	
	function setPixelAA(g1:Graphics, x:Int, y:Int, color:Color, alpha:Int):Void
	{
		
	}
	
	function setPixelColor(g1:Graphics, x:Int, y:Int, color:Color, alpha:Int):Void
	{
		
	}
	
	static function iabs(v:Int):Int
	{
		return Std.int(Math.abs(v));
	}
}