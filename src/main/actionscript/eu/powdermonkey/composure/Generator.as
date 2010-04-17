package eu.powdermonkey.composure
{
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.QualifiedName;
	
	public interface Generator
	{
		function generate(name:QualifiedName, types:Array):DynamicClass
	}
}