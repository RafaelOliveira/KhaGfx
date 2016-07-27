package gfx;

import kha.math.Vector2;
import kha.graphics2.Graphics;

class RenderEx
{	
	public static function drawLineEx(g2:Graphics, renderFunc:Graphics->Float->Float->Void, x0:Float, y0:Float, x1:Float, y1:Float, segments:Int = 0):Void 
    {        
        var distance = Math.sqrt( ((x1 - x0) * (x1 - x0)) + ((y1 - y0) * (y1 - y0)) );
        var vec = new Vector2(x1 - x0, y1 - y0);

        if (segments == 0)
            segments = Std.int(distance / 10);
        
        vec.length = Std.int(distance / segments);        

        for (i in 0...segments)
        {            
            renderFunc(g2, x0, y0);

            x0 += vec.x;
            y0 += vec.y;            
        }        
    }

    public static function drawCircleEx(g2:Graphics, renderFunc:Graphics->Float->Float->Void, cx:Float, cy:Float, radius:Float, segments:Int = 0):Void 
    {
		if (segments <= 0)
			segments = Math.floor(10 * Math.sqrt(radius));
			
		var theta = 2 * Math.PI / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);
		
		var x = radius;
		var y = 0.0;
		var t = 0.0;

		for (n in 0...segments) 
        {						
            renderFunc(g2, x + cx, y + cy);
			
			t = x;
			x = c * x - s * y;
			y = c * y + s * t;            
		}
	}

    public static function drawEllipseEx(g2:Graphics, renderFunc:Graphics->Float->Float->Void, cx:Float, cy:Float, rx:Float, ry:Float, segments:Int = 0):Void
	{
		if (segments <= 0)
			segments = Math.floor(10 * Math.sqrt(rx));		
		
		var x:Float;
        var y:Float;
		
		var angle:Float = 0.0;		

		// go through all angles from 0 to 2 * PI radians
		while (angle < (2 * Math.PI))
		{			
			// calculate x, y from a vector with known length and angle
			x = rx * Math.cos(angle);
			y = ry * Math.sin(angle);
			
            renderFunc(g2, x + cx, y + cy);

			angle += 2 * (Math.PI / segments);
		}
				
        renderFunc(g2, rx + cx, cy);        
	}

    public static function drawPolygonEx(g2:Graphics, renderFunc:Graphics->Float->Float->Void, x:Float, y:Float, vertices:Array<Vector2>):Void
    {
		var iterator = vertices.iterator();
		var v0 = iterator.next();
		var v1 = v0;
		
		while (iterator.hasNext()) {
			var v2 = iterator.next();			
            drawLineEx(g2, renderFunc, v1.x + x, v1.y + y, v2.x + x, v2.y + y);
			v1 = v2;
		}		
        drawLineEx(g2, renderFunc, v1.x + x, v1.y + y, v0.x + x, v0.y + y);
	}

	public static function drawCubicBezierEx(g2:Graphics, renderFunc:Graphics->Float->Float->Void, x:Array<Float>, y:Array<Float>, segments:Int = 20):Void 
    {
		var t:Float;
		
		var p = Geom.calculateCubicBezierPoint(0, x, y);
        renderFunc(g2, p[0], p[1]);		
		
		for (i in 1...(segments + 1)) 
        {
			t = i / segments;
			p = Geom.calculateCubicBezierPoint(t, x, y);
            renderFunc(g2, p[0], p[1]);			
		}        
	}

	public static function drawCubicBezierPathEx(g2:Graphics, renderFunc:Graphics->Float->Float->Void, x:Array<Float>, y:Array<Float>, segments:Int = 20):Void
    {
		var i = 0;
		var t:Float;
		var p:Array<Float> = null;		

		while (i < x.length - 3) 
        {
			if (i == 0)
            {
                p = Geom.calculateCubicBezierPoint(0, [x[i], x[i + 1], x[i + 2], x[i + 3]], [y[i], y[i + 1], y[i + 2], y[i + 3]]);
                renderFunc(g2, p[0], p[1]);
            }				

			for (j in 1...(segments + 1)) 
            {
				t = j / segments;
				p = Geom.calculateCubicBezierPoint(t, [x[i], x[i + 1], x[i + 2], x[i + 3]], [y[i], y[i + 1], y[i + 2], y[i + 3]]);
                renderFunc(g2, p[0], p[1]);								
			}
			
			i += 3;
		}        
	}
}