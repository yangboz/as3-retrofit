package eu.powdermonkey.composure
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.DynamicMethod;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.NamespaceSet;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.MemberVisibility;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.ParameterInfo;
	import org.flemit.reflection.PropertyInfo;
	import org.flemit.reflection.Type;
	
	public class ValueClassGenerator implements Generator
	{
		public static const CREATE_METHOD : String = "__createInstance";
		
		public function generate(name:QualifiedName, interfaces:Array):DynamicClass
		{
			var superClass:Type = Type.getType(Object)
			var dynamicClass:DynamicClass = new DynamicClass(name, superClass, interfaces)
			
			addInterfaceMembers(dynamicClass)
			
			var method:MethodInfo
			var property:PropertyInfo
			
			dynamicClass.constructor = createConstructor(dynamicClass, interfaces[0])
			
			dynamicClass.addMethodBody(dynamicClass.scriptInitialiser, generateScriptInitialier(dynamicClass));
			dynamicClass.addMethodBody(dynamicClass.staticInitialiser, generateStaticInitialiser(dynamicClass));
			dynamicClass.addMethodBody(dynamicClass.constructor, generateInitialiser(dynamicClass, interfaces[0]));
			
			for each(method in dynamicClass.getMethods())
			{
				dynamicClass.addMethodBody(method, generateMethod(dynamicClass, method, null, false, method.name, MethodType.METHOD));
			}
			
			for each(property in dynamicClass.getProperties())
			{
				dynamicClass.addMethodBody(property.getMethod, generateMethod(dynamicClass, property.getMethod, null, false, property.name, MethodType.PROPERTY_GET));
//				dynamicClass.addMethodBody(property.setMethod, generateMethod(dynamicClass, property.setMethod, null, false, property.name, MethodType.PROPERTY_SET));
			}
			
			return dynamicClass;
		}
		
		private function addInterfaceMembers(dynamicClass : DynamicClass) : void
		{
			var allInterfaces : Array = dynamicClass.getInterfaces();
			
			for each(var inter : Type in allInterfaces)
			{
				for each(var extendedInterface : Type in inter.getInterfaces())
				{
					if (allInterfaces.indexOf(extendedInterface) == -1)
					{
						allInterfaces.push(extendedInterface);
					}
				}
				
				for each(var method : MethodInfo in inter.getMethods())
				{
					if (dynamicClass.getMethod(method.name) == null)
					{					
						dynamicClass.addMethod(new MethodInfo(dynamicClass, method.name, null, method.visibility, method.isStatic, false, method.returnType, method.parameters));
					}
				}
				
				for each(var property:PropertyInfo in inter.getProperties())
				{
					if (dynamicClass.getProperty(property.name) == null)
					{
						dynamicClass.addProperty(new PropertyInfo(dynamicClass, property.name, null, property.visibility, property.isStatic, false, property.type, property.canRead, property.canWrite));
					}
				}
			}
		}
		
		private function createConstructor(dynamicClass:DynamicClass, interfaseType:Type):MethodInfo
		{
			var baseCtor : MethodInfo = dynamicClass.baseType.constructor;
			
			var params : Array = new Array().concat(baseCtor.parameters);
			
			var properties:Array = interfaseType.getProperties()
			var propertyInfo:PropertyInfo
			
			for (var i:uint=0; i<properties.length; i++) 
			{
				propertyInfo = properties[i]
				params.push(new ParameterInfo(propertyInfo.name, propertyInfo.type, false))
			}
			
			//return new MethodInfo(dynamicClass, dynamicClass.name, null, MemberVisibility.PUBLIC, false, 
			return new MethodInfo(dynamicClass, "ctor", null, MemberVisibility.PUBLIC, false, false, 
				Type.star, params);
		}
		
		private function generateScriptInitialier(dynamicClass : DynamicClass) : DynamicMethod
		{
			var clsNamespaceSet:NamespaceSet = new NamespaceSet(
				[new BCNamespace(dynamicClass.packageName, NamespaceKind.PACKAGE_NAMESPACE)]);
			
			with (Instructions)
			{
				if (dynamicClass.isInterface)
				{
					return new DynamicMethod(dynamicClass.scriptInitialiser, 3, 2, 1, 3, [
						[GetLocal_0],
						[PushScope],
						[FindPropertyStrict, new MultipleNamespaceName(dynamicClass.name, clsNamespaceSet)], 
						[PushNull],
						[NewClass, dynamicClass],
						[InitProperty, dynamicClass.qname],
						[ReturnVoid]
					]); 
				}
				else
				{
					// TODO: Support where base class is not Object
					return new DynamicMethod(dynamicClass.scriptInitialiser, 3, 2, 1, 3, [
						[GetLocal_0],
						[PushScope],
						//[GetScopeObject, 0],
						[FindPropertyStrict, dynamicClass.multiNamespaceName], 
						[GetLex, dynamicClass.baseType.qname],
						[PushScope],
						[GetLex, dynamicClass.baseType.qname],
						[NewClass, dynamicClass],
						[PopScope],
						[InitProperty, dynamicClass.qname],
						[ReturnVoid]
					]);
				}
			}
		}
		
		private function generateStaticInitialiser(dynamicClass:DynamicClass):DynamicMethod
		{
			with (Instructions)
			{
				return new DynamicMethod(dynamicClass.staticInitialiser, 2, 2, 3, 4, [
					[GetLocal_0],
					[PushScope],
					[ReturnVoid]
				]);
			}
		}
		
		private function generateInitialiser(dynamicClass:DynamicClass, interfaseType:Type):DynamicMethod
		{
			var baseCtor : MethodInfo = dynamicClass.baseType.constructor;
			var argCount : uint = baseCtor.parameters.length;
//			var namespaze:BCNamespace = new BCNamespace(dynamicClass.packageName, NamespaceKind.PACKAGE_NAMESPACE)
			var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
			
			with (Instructions)
			{
				var instructions : Array = [
					[GetLocal_0],
					[PushScope],
					// begin construct super
					[GetLocal_0], // 'this'
					[ConstructSuper, argCount]
				];
				
				var properties:Array = interfaseType.getProperties()
				var propertyInfo:PropertyInfo
				var qname:QualifiedName
				
				for (var i:uint=0; i<properties.length; i++) 
				{
					propertyInfo = properties[i]
					qname = new QualifiedName(namespaze, '_' +propertyInfo.name) 
					instructions.push([FindProperty, qname])
					instructions.push([GetLocal, i+1]);
					instructions.push([InitProperty, qname])
				}
				
				instructions.push(
					[ReturnVoid]
				);
				
				var argumentBytes:int = properties.length * 5
				
				return new DynamicMethod(dynamicClass.constructor, 6 + argumentBytes, 3 + argumentBytes, 4, 5, instructions);
			}
		}
		
		private function generateMethod(dynamicClass:DynamicClass, method : MethodInfo, baseMethod : MethodInfo, baseIsDelegate : Boolean, name : String, methodType : uint) : DynamicMethod
		{
			var argCount : uint = method.parameters.length;
			var name:String = '_' + method.fullName.match(/(\w+)\/\w+$/)[1]
			
			with (Instructions)
			{
				var instructions : Array = [
					[GetLocal_0],
					[PushScope],
					[GetLex, new QualifiedName(new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE), name)],
				];
				
				// TODO: IsFinal?
				if (baseMethod != null)
				{
					if (baseIsDelegate)
					{
						instructions.push(
							[GetLex, baseMethod.qname]
						);
					}
					else
					{
						instructions.push(
							[GetLocal_0],
							[GetSuper, baseMethod.qname]
						);
					}
				}
//				else
//				{
//					instructions.push(
//						[PushNull]
//					);
//				}
				
//				instructions.push(
//					[CallProperty, proxyListenerType.getMethod("methodExecuted").qname, 5]
//				);
				
				if (method.returnType == Type.voidType) // void
				{
					instructions.push([ReturnVoid]);
				}
				else
				{
					instructions.push(
						//[GetLex, method.returnType.qname],
						//[AsTypeLate],
						[ReturnValue]
					);
				}
				
				return new DynamicMethod(method, 7 + argCount, argCount + 2, 4, 5, instructions);
			}
		}
	}
}