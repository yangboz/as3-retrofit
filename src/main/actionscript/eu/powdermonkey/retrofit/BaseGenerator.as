package eu.powdermonkey.retrofit
{
	import org.flemit.bytecode.*;
	import org.flemit.reflection.*;
	
	public class BaseGenerator
	{
		protected function addInterfaceMembers(dynamicClass:DynamicClass):void
		{
			var allInterfaces:Array = dynamicClass.getInterfaces()
			
			for each(var inter:Type in allInterfaces)
			{
				for each(var extendedInterface:Type in inter.getInterfaces())
				{
					if (allInterfaces.indexOf(extendedInterface) == -1)
					{
						allInterfaces.push(extendedInterface)
					}
				}
				
				for each(var method:MethodInfo in inter.getMethods())
				{
					if (dynamicClass.getMethod(method.name) == null)
					{					
						var classMethod:MethodInfo = new MethodInfo(dynamicClass, method.name, null, method.visibility, method.isStatic, false, method.returnType, method.parameters) 
						dynamicClass.addMethod(classMethod)
						dynamicClass.addMethodBody(classMethod, generateMethod(inter, dynamicClass, classMethod, null, false, classMethod.name, MethodType.METHOD))
					}
				}
				
				for each(var property:PropertyInfo in inter.getProperties())
				{
					if (dynamicClass.getProperty(property.name) == null)
					{
						var classProperty:PropertyInfo = new PropertyInfo(dynamicClass, property.name, null, property.visibility, property.isStatic, false, property.type, property.canRead, property.canWrite)
						dynamicClass.addProperty(classProperty)
						
						if (property.canRead)
						{
							dynamicClass.addMethodBody(classProperty.getMethod, generateMethod(inter, dynamicClass, classProperty.getMethod, null, false, classProperty.name, MethodType.PROPERTY_GET))
						}
						
						if (property.canWrite)
						{
							dynamicClass.addMethodBody(classProperty.setMethod, generateMethod(inter, dynamicClass, classProperty.setMethod, null, false, classProperty.name, MethodType.PROPERTY_SET))
						}
					}
				}
			}
		}
		
		protected function generateMethod(type:Type, dynamicClass:DynamicClass, method:MethodInfo, baseMethod:MethodInfo, baseIsDelegate:Boolean, name:String, methodType:uint):DynamicMethod
		{
			var argCount : uint = method.parameters.length;

			with (Instructions)
			{
				var instructions : Array = [
					[GetLocal_0],
					[PushScope],
					[GetLocal_0],
					[PushByte, methodType],
					[PushString, name],
					[GetLocal, argCount + 1], // 'arguments'					
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
				else
				{
					instructions.push(
						[PushNull]
					);
				}
				
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
		
		protected function generateScriptInitialier(dynamicClass : DynamicClass) : DynamicMethod
		{
			var clsNamespaceSet:NamespaceSet = new NamespaceSet(
				[new BCNamespace(dynamicClass.packageName, NamespaceKind.PACKAGE_NAMESPACE)]
			)
			
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
					])
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
		
		protected function generateStaticInitialiser(dynamicClass:DynamicClass):DynamicMethod
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
	}
}