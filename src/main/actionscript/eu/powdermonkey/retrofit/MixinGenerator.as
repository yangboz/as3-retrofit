package eu.powdermonkey.retrofit
{
	import flash.utils.Dictionary;
	
	import org.flemit.bytecode.*;
	import org.flemit.reflection.*;
	
	public class MixinGenerator extends BaseGenerator
	{
		public function generate(name:QualifiedName, base:Type, mixins:Dictionary):DynamicClass
		{
			var superClass:Type = Type.getType(Object)
			
			var interfaces:Array = [].concat(base).concat(base.getInterfaces())
//			var mixinClasses:Dictionary = new Dictionary()
//			
//			for each (var interfaceType:Type in interfaces)
//			{
//				if (mixins.hasOwnProperty(interfaceType.classDefinition))
//				{
//					mixinClasses[interfaceType] = mixins[interfaceType.name]
//				}
//				else if (mixins.hasOwnProperty(interfaceType.fullName))
//				{
//					mixinClasses[interfaceType] = mixins[interfaceType.fullName]
//				}
//			}
			
			var dynamicClass:DynamicClass = new DynamicClass(name, superClass, interfaces)
			
			addInterfaceMembers(dynamicClass)
			
			var method:MethodInfo
			var property:PropertyInfo
			
			dynamicClass.constructor = createConstructor(dynamicClass)
			
			dynamicClass.addMethodBody(dynamicClass.scriptInitialiser, generateScriptInitialier(dynamicClass))
			dynamicClass.addMethodBody(dynamicClass.staticInitialiser, generateStaticInitialiser(dynamicClass))
			dynamicClass.addMethodBody(dynamicClass.constructor, generateInitialiser(dynamicClass, mixins))
			
			return dynamicClass; 
		}
		
		private function createConstructor(dynamicClass:DynamicClass):MethodInfo
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
		
		override protected function generateMethod(type:Type, dynamicClass:DynamicClass, method:MethodInfo, baseMethod:MethodInfo, baseIsDelegate:Boolean, name:String, methodType:uint):DynamicMethod
		{
			var argCount:uint = method.parameters.length;
			var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
			var proxyPropertyName:QualifiedName = buildProxyPropName(namespaze, type)
			
			with (Instructions)
			{
				var instructions:Array = [
					[GetLocal_0],
					[PushScope],
				];
				
				if (methodType == MethodType.METHOD)
				{
					instructions.push([GetLex, proxyPropertyName])
					
					for (var i:uint=0; i < argCount; ++i)
					{
						instructions.push([GetLocal, i+1])
					}
					
//					var methodQName:QualifiedName = new QualifiedName(namespaze, method.name)
					if (method.returnType == Type.voidType)
					{
						instructions.push([CallPropVoid, method.qname, argCount])
					}
					else
					{
						instructions.push([CallProperty, method.qname, argCount])
					}
				}
				else if (methodType == MethodType.PROPERTY_GET || methodType == MethodType.PROPERTY_SET)
				{
					var methodName:String = method.fullName.match(/(\w+)\/\w+$/)[1]
					var methodQName:QualifiedName = new QualifiedName(namespaze, methodName) 
					instructions.push([GetLex, proxyPropertyName])
					instructions.push([GetProperty, methodQName])
					
					if (methodType == MethodType.PROPERTY_SET)
					{
						instructions.push([Pop])
					}
				}
				
				if (method.returnType == Type.voidType) // void
				{
					instructions.push([ReturnVoid])
				}
				else
				{
					instructions.push([ReturnValue])
				}
				
				return new DynamicMethod(method, 7 + argCount, argCount + 2, 4, 5, instructions);
			}
		}
	}		
}