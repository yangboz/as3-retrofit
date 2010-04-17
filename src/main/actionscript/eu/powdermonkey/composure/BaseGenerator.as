package eu.powdermonkey.composure
{
	import org.flemit.bytecode.*;
	import org.flemit.reflection.*;
	
	public class BaseGenerator
	{
		public function BaseGenerator()
		{
		}
		
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
						dynamicClass.addMethod(new MethodInfo(dynamicClass, method.name, null, method.visibility, method.isStatic, false, method.returnType, method.parameters))
					}
				}
				
				for each(var property:PropertyInfo in inter.getProperties())
				{
					if (dynamicClass.getProperty(property.name) == null)
					{
						dynamicClass.addProperty(new PropertyInfo(dynamicClass, property.name, null, property.visibility, property.isStatic, false, property.type, property.canRead, property.canWrite))
					}
				}
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