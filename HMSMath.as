package 
{
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	public class HMSMath 
	{
		
		public static function random(maxValue:Number):int {
			return Math.floor(Math.random() * maxValue);
		}
		
		/**
		 * Simple linear interpolation between two values.
		 * @param	fraction	Number between 0 and 1 that indicates how close to <pre>endValue</pre> the returned value should be.
		 * @param	startValue	Value if <pre>fraction</pre> is 0.
		 * @param	endValue	Value if <pre>fraction</pre> is 1.
		 * @return
		 */
		public static function interpolate(fraction:Number, startValue:Number, endValue:Number):Number {
			if (isNaN(fraction)) fraction = 0;
			return startValue + fraction * (endValue - startValue);
		}
		
		public static function degToRad(degrees:Number):Number {
			return degrees * Math.PI / 180;
		}
		
		public static function radToDeg(radians:Number):Number {
			return radians * 180 / Math.PI;
		}
		
		public static function zeroPad(num:int, digits:uint):String {
			var numStr:String = num.toString();
			var minus:String = "";
			if (num < 0) {
				minus = "-";
				numStr = numStr.substr(1);
			}
			while (numStr.length < digits) {
				numStr = "0" + numStr;
			}
			return minus + numStr;
		}
		
		/**
		 * Returns a number between 0 and ''peak'' in an exponential curve. Useful for calculating position and scale according to perspective.
		 * ''value'' should identify the distance of the object from the 'camera', and ''gentleness'' is a constant that alters the depth perception.
		 * @param	value			The variable value. The closer it is to 0, the closer to the peak.
		 * @param	gentleness		A number equal to or greater than 1, indicating the gentleness (length) of the curve.
		 * 							The lower this value, the steeper the curve.
		 * @param	peak			Peak of the curve, returned for a ''value'' of 0 (or ''valueSubstract'', if used).
		 * @param	valueSubstract	Substracted from the ''value''. Curve will peak at a ''value'' equal to or lower than this number.
		 * @return					A number between 0 (or ''valueSubstract'') and ''peak''.
		 */
		public static function curve(value:Number, gentleness:Number, peak:Number = 1, valueSubstract:Number = 0):Number {
			if (valueSubstract) value = Math.max(value - valueSubstract, 0);
			if (gentleness < 1) gentleness = 1;
			return peak / ((value / gentleness) +1);
		}
		
		/**
		 * Returns a curve that allows for scaling
		 */
		public static function fractalCurve(value:Number, gentleness:Number):Number {
			return Math.pow(gentleness, -value);
		}
		
		/**
		 * Sine function.
		 * @param	time		Time (variable).
		 * @param	amplitude	Maximum amplitude of the movement.
		 * @param	frequency	How many oscillations occur in a unit of time (radians per second).
		 * @param	phase		Time start offset (positive values represent a delay).
		 * @return				
		 */
		public static function sine(time:Number, amplitude:Number = 100, frequency:Number = 0.1, phase:Number = 0):Number {
			return amplitude * Math.sin((frequency * time) + phase);
		}
		
		public static function rotatePoint(point:Point, radians:Number = 0, returnNewPoint:Boolean = false):Point {
			var pt:Point = (returnNewPoint) ? point.clone() : point;
			
			if (radians == 0) return pt;
			
			var angle:Number = cartesianToRadians(pt.x, pt.y); //Math.atan2(pt.y, pt.x);
			if (isNaN(angle)) angle = 0;
			pt = Point.polar(pt.length, angle + radians);
			return pt;
		}
		
		public static function cartesianToRadians(x:Number, y:Number):Number {
			return Math.atan2(y, x);
		}
		
		public static function polygonCenter(... points):Point {
			if (points.length < 2) {
				if (points.length == 1 && points[0] is Point)
					return points[0];
				else
					return null;
			}
			
			var p:Point, p2:Point;
			var len:uint = points.length - 1;
			for (var i:int = 0; i < len; i++) {
				if (i == 0)
					p = points[i].clone();
				p2 = points[i+1];
				
				p.x = (p.x - p2.x) / (i+2) + p.x;
				p.y = (p.y - p2.y) / (i+2) + p.y;
			}
			
			return p;
		}
		
	}
	
}