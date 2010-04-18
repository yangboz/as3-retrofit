package eu.powdermonkey.retrofit
{
	import org.flemit.bytecode.*;
	import org.flemit.reflection.*;
	
	public class ValueClassGenerator extends BaseGenerator
	{
		public function generate(name:QualifiedName, type:Type):DynamicClass
		{
			var superClass:Type = Type.getType(Object)
			var dynamicClass:DynamicClass = new DynamicClass(name, superClass, [type])
			
			addInterfaceMembers(dynamicClass)
			
			var method:MethodInfo
			var property:PropertyInfo
			
			dynamicClass.constructor = createConstructor(dynamicClass, type)
			
			dynamicClass.addMethodBody(dynamicClass.scriptInitialiser, generateScriptInitialier(dynamicClass));
			dynamicClass.addMethodBody(dynamicClass.staticInitialiser, generateStaticInitialiser(dynamicClass));
			dynamicClass.addMethodBody(dynamicClass.constructor, generateInitialiser(dynamicClass, type));
			
			var toStringMethod:MethodInfo = new MethodInfo(dynamicClass, 'toString', null, MemberVisibility.PUBLIC, false, false, Type.getType(String), [])
			dynamicClass.addMethod(toStringMethod)
			dynamicClass.addMethodBody(toStringMethod, generateToString(dynamicClass, toStringMethod))
			
			return dynamicClass
		}
		
		private function createConstructor(dynamicClass:DynamicClass, interfaceType:Type):MethodInfo
		{
			var baseCtor:MethodInfo = dynamicClass.baseType.constructor
			var params:Array = new Array().concat(baseCtor.parameters)
			
			var properties:Array = interfaceType.getProperties()
			var propertyInfo:PropertyInfo
			
			for (var i:uint=0; i<properties.length; i++) 
			{
				propertyInfo = properties[i]
				params.push(new ParameterInfo(propertyInfo.name, propertyInfo.type, false))
			}
			
			return new MethodInfo(dynamicClass, "ctor", null, MemberVisibility.PUBLIC, false, false, Type.star, params);
		}
		
		private function generateInitialiser(dynamicClass:DynamicClass, interfaseType:Type):DynamicMethod
		{
			var baseCtor : MethodInfo = dynamicClass.baseType.constructor;
			var argCount : uint = baseCtor.parameters.length;
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
				
				var properties:Array = dynamicClass.constructor.parameters
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
		
		override protected function generateMethod(type:Type, dynamicClass:DynamicClass, method:MethodInfo, baseMethod:MethodInfo, baseIsDelegate:Boolean, name:String, methodType:uint):DynamicMethod
		{
			var name:String = '_' + method.fullName.match(/(\w+)\/\w+$/)[1]
			
			with (Instructions)
			{
				var instructions : Array = [
					[GetLocal_0],
					[PushScope],
					[GetLex, new QualifiedName(new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE), name)],
					[ReturnValue]
				]
				
				return new DynamicMethod(method, 7, 2, 4, 5, instructions)
			}
		}
		
		private function generateToString(dynamicClass:DynamicClass, method:MethodInfo):DynamicMethod
		{
			var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
			
			with(Instructions)
			{
				var instructions:Array = [
					[GetLocal_0],
					[PushScope],
					[PushString, '['+dynamicClass.getInterfaces()[0].name]
				]
				
				var properties:Array = dynamicClass.constructor.parameters
				var propertyInfo:PropertyInfo
				var qname:QualifiedName
				
				for (var i:uint=0; i<properties.length; i++) 
				{
					propertyInfo = properties[i]
					qname = new QualifiedName(namespaze, '_' +propertyInfo.name) 
					instructions.push([PushString, ' '+propertyInfo.name+':'])
					instructions.push([Add])
					instructions.push([GetLex, qname])
					instructions.push([Add])
				} 
				
				instructions.push(
					[PushString, ']'],
					[Add],
					[ReturnValue]
				)
				
				return new DynamicMethod(method, 7, 2, 4, 5, instructions)
			}
		}
	}
}