package de.oehme.xtend.contrib.jaxrs

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Target(ElementType.TYPE)
@Active(ExportTypeScriptProcessor)
annotation ExportTypeScript {
} 
 
class ExportTypeScriptProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration target, extension TransformationContext context) {
		target.addWarning("@ExportTypeScript - Not implemented yet")
	}

	override doGenerateCode(ClassDeclaration clazz, extension CodeGenerationContext context) {
//		out = new OutputStreamWriter(System.out)	
//		generator.generateDefinition(clazz.qualifiedName, out, type)
//		out.close
	}

}
