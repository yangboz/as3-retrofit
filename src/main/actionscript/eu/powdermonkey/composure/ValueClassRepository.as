package eu.powdermonkey.composure
{
	import flash.utils.getQualifiedClassName;
	
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.reflection.ParameterInfo;
	import org.flemit.reflection.Type;
	import org.flemit.util.ClassUtility;
	import org.flemit.util.MethodUtil;
	
	public class ValueClassRepository extends ClassRepository
	{
		private var valueClassGenerator:ValueClassGenerator = new ValueClassGenerator()
		
		public function prepare(classes:Array):PreperationSignals
		{
			return prepareClasses(classes, valueClassGenerator)
		}
		
		public function create(cls:Class, args:Object):*
		{
			var clazz:Class = classes[cls]
			
			if (clazz == null)
			{
				throw new ArgumentError("A class for " 
					+ getQualifiedClassName(cls) + " has not been prepared yet") 
			}
			
			var dynamicClass:DynamicClass = dynamicClasses[cls]
			var classType:Type = Type.getType(clazz)
			var params:Array = dynamicClass.constructor.parameters
			var constructorRequiredArgCount:int = MethodUtil.getRequiredArgumentCount(classType.constructor)
			
			if (args.length < constructorRequiredArgCount || args.length > constructorRequiredArgCount)
			{
				throw new ArgumentError('Constructor expects at least '+constructorRequiredArgCount+'arguemnts')
			}
			
			var argumentValues:Array = []
			
			for (var i:int = 0; i < params.length; ++i)
			{
				var param:ParameterInfo = params[i]
				var paramName:String = param.name
				
				if (args.hasOwnProperty(paramName) )
				{
					argumentValues.push(args[paramName])
				}
				else if (param.optional == false)
				{
					throw new ArgumentError('The argument map did not contain an entry for "'+paramName+'" and this parameter is not optional')
				}
			}
			
			return ClassUtility.createClass(clazz, argumentValues) 
		}
	}
}