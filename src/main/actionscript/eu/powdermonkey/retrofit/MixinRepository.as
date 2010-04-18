package eu.powdermonkey.retrofit
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	import org.flemit.util.ClassUtility;
	import org.flemit.util.MethodUtil;
	
	public class MixinRepository extends ClassRepository
	{
		private var mixinGenerator:MixinGenerator = new MixinGenerator()
		
		protected var mixinPairs:Dictionary = new Dictionary()
		
		protected var bases:Dictionary = new Dictionary()
		
		public function defineMixin(interfaze:Class, clazz:Class):void
		{
			if (interfaze in mixinPairs)
			{
				throw ArgumentError(interfaze+' is already defined, you can supply an override during preparation of the base')
			}
			
			mixinPairs[interfaze] = clazz
		}
		
		public function defineBase(base:Class, mixins:Object=null):void
		{
			if (base in bases)
			{
				throw ArgumentError(base+' is already defined')
			}
			
			mixins = mixins || {}
			bases[base] = mixins
		}
		
		public function prepare():PreperationSignals
		{
			var baseClasses:Array = []
			
			for (var baseClass:* in bases)
			{
				baseClasses.push(baseClass)
			}
			
			if (baseClasses.length == 0)
			{
				throw new IllegalOperationError('No base classes were defined. Use defineBase()')
			}
			
			return prepareClasses(baseClasses, createDynClass)
			
			function createDynClass(name:QualifiedName, base:Type):DynamicClass
			{
				var interfaces:Array = base.getInterfaces()
				var mixins:Dictionary = new Dictionary()
				
				for each (var interfaze:Type in interfaces)
				{
					if (interfaze.classDefinition in mixinPairs)
					{
						mixins[interfaze] = mixinPairs[interfaze.classDefinition]
					}
					else
					{
						throw new Error('interface '+interfaze+' defined on '+base+'has not being defined') 
					}
				}
				
				return mixinGenerator.generate(name, base, mixins)
			}
		}
		
		public function create(cls:Class, args:Object=null):*
		{
			args = args || {}
			
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
			
//			for (var i:int = 0; i < params.length; ++i)
//			{
//				var param:ParameterInfo = params[i]
//				var paramName:String = param.name
//				
//				if (args.hasOwnProperty(paramName) )
//				{
//					argumentValues.push(args[paramName])
//				}
//				else if (param.optional == false)
//				{
//					throw new ArgumentError('The argument map did not contain an entry for "'+paramName+'" and this parameter is not optional')
//				}
//			}
			
			return ClassUtility.createClass(clazz, argumentValues)
		}
	}
}