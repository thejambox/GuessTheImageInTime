package {
	public class Tools {
		
		public static function multipleStringMatch(string:String, requiredMatches:Vector.<String> = null, forbiddenMatches:Vector.<String> = null):Boolean {
			var okay:Boolean = false;
			var item:String;
			
			if (requiredMatches) {
				for each (item in requiredMatches) {
					if (string.indexOf(item) != -1) {
						okay = true;
						break;
					}
				}
			} else {
				okay = true;
			}
			if (!okay) return false;
			
			if (forbiddenMatches) {
				for each (item in forbiddenMatches) {
					if (string.indexOf(item) != -1) {
						okay = false;
						break;
					}
				}
			}
			return okay;
		}
		
		public static function inDebugMode():Boolean {
			try {
				throw new Error("Setting global debug flag...");
			} catch(e:Error) {
				var re:RegExp = /\[.*:[0-9]+\]/;
				return re.test(e.getStackTrace());
			}
			return false;
		}
		
		
	}
	
}