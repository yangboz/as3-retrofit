package eu.powdermonkey.composure
{
	import flash.utils.Dictionary;
	
	import org.flemit.bytecode.*;
	import org.flemit.reflection.*;
	
	public class MixinGenerator extends BaseGenerator
	{
		public function generate(name:QualifiedName, types:Array, mixins:Object):DynamicClass
		{
			var superClass:Type = Type.getType(Object)
			
			var baseType:Type = types[0]
			var interfaces:Array = [].concat(baseType).concat(baseType.getInterfaces())
			var mixinClasses:Dictionary = new Dictionary()
			
			for each (var interfaceType:Type in interfaces)
			{
				if (mixins.hasOwnProperty(interfaceType.name))
				{
					mixinClasses[interfaceType] = mixins[interfaceType.name]
				}
				else if (mixins.hasOwnProperty(interfaceType.fullName))
				{
					mixinClasses[interfaceType] = mixins[interfaceType.fullName]
				}
			}
			
			var dynamicClass:DynamicClass = new DynamicClass(name, superClass, interfaces)
			
			addInterfaceMembers(dynamicClass)
			
			var method:MethodInfo
			var property:PropertyInfo
			
			dynamicClass.constructor = createConstructor(dynamicClass, interfaces[0])
			
			dynamicClass.addMethodBody(dynamicClass.scriptInitialiser, generateScriptInitialier(dynamicClass))
			dynamicClass.addMethodBody(dynamicClass.staticInitialiser, generateStaticInitialiser(dynamicClass))
			dynamicClass.addMethodBody(dynamicClass.constructor, generateInitialiser(dynamicClass, mixinClasses))
			
			return dynamicClass; 
		}
		
		private function createConstructor(dynamicClass:DynamicClass, interfaseType:Type):MethodInfo
		{
			return new MethodInfo(dynamicClass, "ctor", null, MemberVisibility.PUBLIC, false, false, Type.star, [])
		}
		
		private function generateInitialiser(dynamicClass:DynamicClass, mixins:Dictionary):DynamicMethod
		{
			var baseCtor : MethodInfo = dynamicClass.baseType.constructor;
			var argCount : uint = baseCtor.parameters.length;
			var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
			var proxies:int = 0
			
			with (Instructions)
			{
				var instructions : Array = [
					[GetLocal_0],
					[PushScope],
					// begin construct super
					[GetLocal_0], // 'this'
					[ConstructSuper, argCount]
				];
				
				var propertyInfo:PropertyInfo
				var proxyPropertyName:QualifiedName
				var proxyObject:Object 
				var proxyObjectType:Type 
				
				for (var interfaceType:Type in mixins) 
				{
					proxyObject = mixins[interfaceType]
					proxyObjectType = Type.getType(proxyObject)
					proxyPropertyName = buildProxyPropName(namespaze, interfaceType)
					
					instructions.push([FindProperty, proxyPropertyName])
					instructions.push([FindPropertyStrict, proxyObjectType.qname])
					instructions.push([ConstructProp, proxyObjectType.qname, 0])
					instructions.push([InitProperty, proxyPropertyName])
					
					proxies++
				}
				
				instructions.push(
					[ReturnVoid]
				);
				
				var argumentBytes:int = proxies * 9
				
				return new DynamicMethod(dynamicClass.constructor, 6 + argumentBytes, 3 + argumentBytes, 4, 5, instructions);
			}
		}
		
		private function buildProxyPropName(namespaze:BCNamespace, interfaceType:Type):QualifiedName
		{
			return new QualifiedName(namespaze, '_' +interfaceType.fullName.replace(/[\.:]/g, '_'))
		}
		
		override protected function generateMethod(dynamicClass:DynamicClass, method:MethodInfo, baseMethod:MethodInfo, baseIsDelegate:Boolean, name:String, methodType:uint):DynamicMethod
		{
			trace('generateMethod:', method.fullName, methodType)
			return super.generateMethod(dynamicClass, method, baseMethod, baseIsDelegate, name, methodType)
		}
	}		
}