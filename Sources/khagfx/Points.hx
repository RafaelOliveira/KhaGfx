package khagfx;

import kha.math.Vector2i;

class Points {

    public static function getLine(dist:Int, x0:Int, y0:Int, x1:Int, y1:Int):Array<Vector2i> 
    {
        var points = new Array<Vector2i>();
        var pos:Int = dist;
        if (dist < 0)
            dist = 0;
        
        var dx:Int =  Std.int(Math.abs(x1 - x0));
        var sx:Int = (x0 < x1) ? 1 : -1;
        var dy:Int = Std.int(-Math.abs(y1 - y0));
        var sy:Int = (y0 < y1) ? 1 : -1;
        var err:Int = dx + dy;
        var e2:Int;                                                	// error value e_xy
		
        // added safety get out as forever while's are dangerous
        var count = 0;
		
        while(true) 												// loop
		{
            if(count > 5000) break;

            //g1.setPixel( x0, y0, col );
            if (pos == dist)
            {
                points.push(new Vector2i(x0, y0));
                pos = 0;
            }
            else
                pos++;     
            
            if(x0 == x1 && y0 == y1) break;
            e2 = 2*err;
            if(e2 >= dy)											// e_xy+e_x > 0
			{
                err += dy;
                x0 += sx;
            }
            if(e2 <= dx)											// e_xy+e_y < 0	
			{
                err += dx;
                y0 += sy;
            }
            count++;
        }

        return points;
    }

    public static function getEllipse(dist:Int, xm:Int, ym:Int, a:Int, b:Int):Array<Vector2i> 
	{
		var pointsQ1 = new Array<Vector2i>();
		var pointsQ2 = new Array<Vector2i>();
		var pointsQ3 = new Array<Vector2i>();
		var pointsQ4 = new Array<Vector2i>();
		
        var pos:Int = dist;
        if (dist < 0)
            dist = 0;
        
        var x:Float = -a;
        var y:Float = 0;						// II. quadrant from bottom left to top right
        var e2:Float = b;
        var dx:Float = (1 + 2 * x) * e2 * e2;	// error increment
        var dy:Float = x*x;
        var err:Float = dx + dy;				// error of 1.step
		
        do 
		{
            if (pos == dist)
            {
                pointsQ1.push(new Vector2i(Std.int(xm - x), Std.int(ym + y)));
                pointsQ2.push(new Vector2i(Std.int(xm + x), Std.int(ym + y)));
                pointsQ3.push(new Vector2i(Std.int(xm + x), Std.int(ym - y)));
                pointsQ4.push(new Vector2i(Std.int(xm - x), Std.int(ym - y)));
                pos = 0;
            }
            else
                pos++;

            e2 = 2 * err;
            if(e2 >= dx) // x step
			{ 
                x++;
                err += dx += 2 * b * b;
            }
            if(e2 <= dy) // y step
			{ 
                y++;
                err += dy += 2 * a * a;
            }
        } 
		while(x <= 0);

        //while( y++ < b ){ // too early stop for flat ellipses with a = 1,
        //    g1.setPixel( xm, Std.int( ym + y ), col );     // -> finish tip of ellipse
        //    g1.setPixel( xm, Std.int( ym - y ), col );
        //}
        
        pointsQ2.reverse();
        pointsQ4.reverse();
		
        return pointsQ1.concat(pointsQ2).concat(pointsQ3).concat(pointsQ4); 
    }

	public static function getCircle(dist:Int, xm:Int, ym:Int, r:Float):Array<Vector2i>
	{
		var pointsQ1 = new Array<Vector2i>();
		var pointsQ2 = new Array<Vector2i>();
		var pointsQ3 = new Array<Vector2i>();
		var pointsQ4 = new Array<Vector2i>();
		
		var pos:Int = dist;
		if (dist < 0)
			dist = 0;
		
		var x:Float = -r;
		var y:Float = 0;
		var err:Float = 2 - 2 * r;										// bottom left to top right

		do
		{                                              
			if (pos == dist)
			{
				pointsQ1.push(new Vector2i(Std.int(xm - x), Std.int(ym + y)));	//   I. Quadrant +x +y
				pointsQ2.push(new Vector2i(Std.int(xm - y), Std.int(ym - x)));	//  II. Quadrant -x +y
				pointsQ3.push(new Vector2i(Std.int(xm + x), Std.int(ym - y)));	// III. Quadrant -x -y
				pointsQ4.push(new Vector2i(Std.int(xm + y), Std.int(ym + x)));	//  IV. Quadrant +x -y
				pos = 0;
			}
			else
				pos++;
			
			r = err;
			
			if(r <= y)
			{
				err += ++y * 2 + 1;				// e_xy + e_y < 0
			}
			if(r > x || err > y)				// e_xy + e_x > 0 or no 2nd y-step
			{
				err += ++x * 2 + 1;				// -> x-step now
			}
		} 
		while(x < 0);        
		
		return pointsQ1.concat(pointsQ2).concat(pointsQ3).concat(pointsQ4); 
	}
	
	public static function getQuadBezierSeg(dist:Int, x0:Int, y0:Int, x1:Int, y1:Int, x2:Int, y2:Int):Array<Vector2i>
	{
		var points = new Array<Vector2i>();
		
		var pos:Int = dist;
		if (dist < 0)
			dist = 0;		
		
		var sx:Int = x2 - x1;
		var sy:Int = y2 - y1;
		var xx:Float = x0 - x1;
		var yy:Float = y0  -y1;
		var xy:Float;                      					// relative values for checks
		var dx:Float;
		var dy:Float;
		var err:Float;
		var cur:Float = xx * sy - yy * sx;     				// curvature

        // sign of gradient must not change
        if (xx * sx <= 0 && yy * sy <= 0) {} else { trace('failed to drawQuadBezierSeg' ); return points; }

        if (sx * sx + sy * sy > xx * xx + yy * yy)			// begin with longer part
		{      
            x2 = x0;
            x0 = sx + x1;
            y2 = y0;
            y0 = sy + y1;
            cur = -cur;       // swap P0 P2
        }
        if (cur != 0)										// no straight line
		{                                    
            xx += sx;
            xx *= sx = (x0 < x2) ? 1 : -1;                 	// x step direction
            yy += sy;
            yy *= sy = (y0 < y2) ? 1 : -1;                 	// y step direction
            xy = 2 * xx * yy;
            xx *= xx;
            yy *= yy;                                       // differences 2nd degree
            if( cur*sx*sy < 0 ) {                           // negated curvature?
                xx = -xx;
                yy = -yy;
                xy = -xy;
                cur = -cur;
            }
            dx = 4.0*sy*cur*( x1 - x0 ) + xx - xy;          // differences 1st degree
            dy = 4.0*sx*cur*( y0 - y1 ) + yy - xy;
            xx += xx;
            yy += yy;
            err = dx + dy + xy;                             // error 1st step
            do {
				
                //g1.setPixel( , , col ); // draw curve
				if (pos == dist)
				{
					points.push(new Vector2i(x0, y0));
					pos = 0;
				}
				else
					pos++;
				
                if( x0 == x2 && y0 == y2 ) return points;              	// last pixel -> curve finished
                //y1 = 2*err < dx;                                    	// save value for test of y step
                if( 2*err > dy ) {
                    x0 += sx;
                    dx -= xy;
                    err += dy += yy;
                }      // x step
                if( 2*err < dx ) {//y1 ){
                    y0 += sy;
                    dy -= xy;
                    err += dx += xx;
                }      // y step
            } while( dy < 0 && dx > 0 );                            // gradient negates -> algorithm fails
        }
        
		//drawLine( g1, x0, y0, x2, y2, col );             // draw remaining part to end
		var pointsLine = getLine(dist, x0, y0, x2, y2);
		
		return points.concat(pointsLine);
    }
	
	public static function getQuadBezier(dist:Int, x0:Int, y0:Int, x1:Int, y1: Int, x2:Int, y2:Int):Array<Vector2i> 
	{
		var points = new Array<Vector2i>();
		
		var pos:Int = dist;
		if (dist < 0)
			dist = 0;
		
        var x: Int = x0 - x1;
        var y: Int = y0 - y1;
        var t: Float = x0 - 2*x1 + x2;
        var r: Float;

        if( x*( x2 - x1 ) > 0 ) {                                               // horizontal cut at P4?
            if( y*( y2 - y1 ) > 0 )                                             // vertical cut at P6 too?
                if( Math.abs( ( y0 - 2*y1 + y2 ) / t*x ) > Math.abs( y ) ) {    // which first?
                    x0 = x2;
                    x2 = x + x1;
                    y0 = y2;
                    y2 = y + y1;                                                // swap points
                }                                                               // now horizontal cut at P4 comes first
            t = ( x0 - x1 )/t;
            r = ( 1 - t )*( ( 1 - t )*y0 + 2.0*t*y1 ) + t*t*y2;                 // By( t = P4 )
            t = ( x0*x2 - x1*x1 )*t/( x0 - x1 );                                // gradient dP4/dx=0
            x = Math.floor( t + 0.5 );
            y = Math.floor( r + 0.5 );
            r = ( y1 - y0 )*( t - x0 )/( x1 - x0 ) + y0;                        // intersect P3 | P0 P1
            
			points = points.concat(getQuadBezierSeg( dist, x0, y0, x, Math.floor( r + 0.5 ), x, y ));
            
			r = ( y1 - y2 )*( t - x2 )/( x1 - x2 ) + y2;                        // intersect P4 | P1 P2
            x0 = x1 = x;
            y0 = y;
            y1 = Math.floor( r + 0.5 );                                         // P0 = P4, P1 = P8
        }
        if( ( y0 - y1 )*( y2 - y1 ) > 0 ) {                                     // vertical cut at P6?
            t = y0 - 2*y1 + y2;
            t = ( y0 - y1 )/t;
            r = ( 1 - t )*( ( 1 - t )*x0 + 2.0*t*x1 ) + t*t*x2;                 // Bx(t=P6)
            t = ( y0*y2 - y1*y1 )*t/( y0 - y1 );                                // gradient dP6/dy=0
            x = Math.floor( r + 0.5 );
            y = Math.floor( t + 0.5 );
            r = ( x1 - x0 )*( t - y0 )/( y1 - y0 ) + x0;                        // intersect P6 | P0 P1
            
			points = points.concat(getQuadBezierSeg( dist, x0, y0, Math.floor( r + 0.5 ), y, x, y ));
            
			r = ( x1 - x2 )*( t - y2 )/( y1 - y2 )+x2;                          // intersect P7 | P1 P2
            x0 = x;
            x1 = Math.floor( r + 0.5 );
            y0 = y1 = y;                                                        // P0 = P6, P1 = P7
        }
        	
		var pointsSeg = getQuadBezierSeg( dist, x0, y0, x1, y1, x2, y2 );
		pointsSeg.reverse();
		
		return points.concat(pointsSeg);        // remaining part
    }
}