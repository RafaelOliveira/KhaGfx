package gfx;

import kha.math.Vector2;

@:allow(gfx.RenderEx)
class Geom
{
    public static function getLine(x0:Float, y0:Float, x1:Float, y1:Float, segments:Int = 0):Array<Vector2> 
    {        
        var points = new Array<Vector2>();
        var distance = Math.sqrt( ((x1 - x0) * (x1 - x0)) + ((y1 - y0) * (y1 - y0)) );
        var vec = new Vector2(x1 - x0, y1 - y0);

        if (segments == 0)
            segments = Std.int(distance / 10);
        
        vec.length = Std.int(distance / segments);        

        for (i in 0...segments)
        {
            points.push(new Vector2(x0, y0));
            x0 += vec.x;
            y0 += vec.y;            
        }

        return points;
    }

    public static function getEllipse(cx:Float, cy:Float, rx:Float, ry:Float, segments:Int = 0):Array<Vector2>
	{
        var points = new Array<Vector2>();

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

			points.push(new Vector2(x + cx, y + cy));
			angle += 2 * (Math.PI / segments);
		}
		
		points.push(new Vector2(rx + cx, cy));

        return points;
	}

    public static function getCubicBezier(x:Array<Float>, y:Array<Float>, segments:Int = 20):Array<Vector2> 
    {
        var points = new Array<Vector2>();

		var t:Float;
		
		var p = calculateCubicBezierPoint(0, x, y);
        points.push(new Vector2(p[0], p[1]));		
		
		for (i in 1...(segments + 1)) 
        {
			t = i / segments;
			p = calculateCubicBezierPoint(t, x, y);
            points.push(new Vector2(p[0], p[1]));						
		}

        return points;
	}

    public static function getCubicBezierPath(x:Array<Float>, y:Array<Float>, segments:Int = 20):Array<Vector2>
    {
        var points = new Array<Vector2>();

		var i = 0;
		var t:Float;
		var p:Array<Float> = null;		

		while (i < x.length - 3) 
        {
			if (i == 0)
            {
                p = calculateCubicBezierPoint(0, [x[i], x[i + 1], x[i + 2], x[i + 3]], [y[i], y[i + 1], y[i + 2], y[i + 3]]);
                points.push(new Vector2(p[0], p[1]));
            }
				

			for (j in 1...(segments + 1)) 
            {
				t = j / segments;
				p = calculateCubicBezierPoint(t, [x[i], x[i + 1], x[i + 2], x[i + 3]], [y[i], y[i + 1], y[i + 2], y[i + 3]]);
                points.push(new Vector2(p[0], p[1]));								
			}
			
			i += 3;
		}

        return points;
	}

    static function calculateCubicBezierPoint(t:Float, x:Array<Float>, y:Array<Float>):Array<Float> 
    {
		var u:Float = 1 - t;
		var tt:Float = t * t;
		var uu:Float = u * u;
		var uuu:Float = uu * u;
		var ttt:Float = tt * t;
	 		
		// first term
		var p:Array<Float> = [uuu * x[0], uuu * y[0]];
			
		// second term				
		p[0] += 3 * uu * t * x[1];
		p[1] += 3 * uu * t * y[1];
			
		// third term				
		p[0] += 3 * u * tt * x[2];
		p[1] += 3 * u * tt * y[2];		
			
		// fourth term				
		p[0] += ttt * x[3];
		p[1] += ttt * y[3];

		return p;
	}
}