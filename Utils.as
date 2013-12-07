package 
{
	import flash.net.*;
	
	public class Utils
	{

		// Returns a Number from [0..maxRange)
		//
		public static function rnd(maxRange:Number):Number
		{
			return Math.random() * maxRange;
		}

		// Returns an int from [0..maxRange-1]
		//
		public static function rndInt(maxRange:Number):int
		{
			return int(Math.random() * maxRange);
		}

		// Returns a Boolean, takes a percent value 0..100
		//
		public static function chance(percent:Number):Boolean
		{
			return rnd(100) < percent;
		}

		// Returns a random float from (-highRange..highRange)
		//
		public static function rndSym(highRange:Number):Number
		{
			return Math.random() * highRange * 2 - highRange;
		}

		// Randomly returns -1 or 1
		public static function rndSign():int
		{
			if (chance(50))
			{
				return -1;
			}
			else
			{
				return 1;
			}
		}

		// Returns a number between [low..high)
		//
		public static function rndRange(low:Number, high:Number):Number
		{
			return rnd(high - low) + low;
		}
		
		// Opens a URL in a new window
		public static function openURL(url:String):void {
			var urlReq:URLRequest = new URLRequest(url);
			navigateToURL(urlReq, "_blank");
		}
	}
}