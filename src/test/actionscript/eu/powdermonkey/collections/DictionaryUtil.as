package eu.powdermonkey.collections
{
	import flash.utils.Dictionary;
	
	public class DictionaryUtil
	{
		public static function getKeys(dictionary:Dictionary):Array
		{
			var keys:Array = []
			
			for (var key:* in dictionary)
			{
				keys.push(key)
			}
			
			return keys
		}
		
		public static function getPropertyFromKeys(dictionary:Dictionary, propertyName:String):Array
		{
			var properties:Array = []
			
			for (var key:* in dictionary)
			{
				properties.push(key[propertyName])
			}
			
			return properties
		}
		
		public static function getValues(dictionary:Dictionary):Array
		{
			var values:Array = []
			
			for each (var value:* in dictionary)
			{
				values.push(value)
			}
			
			return values
		}
		
		public static function getPropertyFromValues(dictionary:Dictionary, propertyName:String):Array
		{
			var properties:Array = []
			
			for each (var value:* in dictionary)
			{
				properties.push(value[propertyName])
			}
			
			return properties
		}
		
		public static function clone(source:Dictionary):Dictionary
		{
			var clone:Dictionary = new Dictionary()
			
			for (var key:* in source)
			{
				clone[key] = source[key]
			}
			
			return clone
		}
		
		public static function toArray(dictionary:Dictionary):Array
		{
			var result:Array = []
			
			for (var key:* in dictionary)
			{
				result.push(dictionary[key])
			}
			
			return result
		}
	}
}