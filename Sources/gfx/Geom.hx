package gfx;

import kha.math.Vector2;

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
}