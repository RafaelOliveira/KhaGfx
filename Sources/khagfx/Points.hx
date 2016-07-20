package khagfx;

import kha.math.Vector2i;

class Points {

    public static function getLine(dist:Int, 
								   x0:Int, y0:Int,
								   x1:Int, y1:Int):Array<Vector2i> {
        var points = new Array<Vector2i>();
        var pos:Int = dist;
        if (dist < 0)
            dist = 0;
        
        var dx: Int =  Std.int( Math.abs( x1 - x0 ) );
        var sx: Int = ( x0 < x1 )? 1 : -1;
        var dy: Int = Std.int( - Math.abs( y1 - y0 ) );
        var sy: Int = ( y0 < y1 )? 1 : -1;
        var err: Int = dx + dy;
        var e2: Int;                                                // error value e_xy
        // added safety get out as forever while's are dangerous
        var count = 0;
        while( true ){                                              // loop
            if( count > 5000 ) break;

            //g1.setPixel( x0, y0, col );
            if (pos == dist)
            {
                points.push(new Vector2i(x0, y0));
                pos = 0;
            }
            else
                pos++;     
            
            if( x0 == x1 && y0 == y1 ) break;
            e2 = 2*err;
            if( e2 >= dy ){                                         // e_xy+e_x > 0
                err += dy;
                x0 += sx;
            }
            if( e2 <= dx ){                                         // e_xy+e_y < 0
                err += dx;
                y0 += sy;
            }
            count++;
        }

        return points;
    }

    public static function getEllipse(dist:Int,
									  xm:Int, ym:Int,
									  a:Int,  b:Int):Array<Vector2i> {
        var pointsQ1 = new Array<Vector2i>();
        var pointsQ2 = new Array<Vector2i>();
        var pointsQ3 = new Array<Vector2i>();
        var pointsQ4 = new Array<Vector2i>();
        var pos:Int = dist;
        if (dist < 0)
            dist = 0;
        
        var x: Float = -a;
        var y: Float = 0;                      // II. quadrant from bottom left to top right
        var e2: Float = b;
        var dx: Float = ( 1 + 2*x )*e2*e2;     // error increment
        var dy: Float = x*x;
        var err: Float = dx + dy;              // error of 1.step

        do {
            //g1.setPixel( Std.int( xm - x ), Std.int( ym + y ), col );  //   I. Quadrant
            //g1.setPixel( Std.int( xm + x ), Std.int( ym + y ), col );  //  II. Quadrant
            //g1.setPixel( Std.int( xm + x ), Std.int( ym - y ), col );  // III. Quadrant
            //g1.setPixel( Std.int( xm - x ), Std.int( ym - y ), col );  //  IV. Quadrant
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

            e2 = 2*err;
            if( e2 >= dx ){ // x step
                x++;
                err += dx += 2*b*b;
            }
            if( e2 <= dy ){ // y step
                y++;
                err += dy += 2*a*a;
            }
        } while( x <= 0 );

        //while( y++ < b ){ // too early stop for flat ellipses with a = 1,
        //    g1.setPixel( xm, Std.int( ym + y ), col );     // -> finish tip of ellipse
        //    g1.setPixel( xm, Std.int( ym - y ), col );
        //}
        
        pointsQ2.reverse();
        pointsQ4.reverse();
        return pointsQ1.concat(pointsQ2).concat(pointsQ3).concat(pointsQ4); 
    }
}