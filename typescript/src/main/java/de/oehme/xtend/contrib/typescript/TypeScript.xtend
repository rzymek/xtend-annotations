package de.oehme.xtend.contrib.typescript

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference

@Target(ElementType.TYPE)
@Active(TypeScriptProcessor)
annotation TypeScript {
}

class TypeScriptProcessor extends AbstractClassProcessor {

	override doGenerateCode(List<? extends ClassDeclaration> sourceElements, extension CodeGenerationContext ctx) {
		val cu = sourceElements.head.compilationUnit
		val dir = cu.filePath.projectFolder.append('src/main/ts/d.ts')
		mkdir(dir)
		dir.append(cu.simpleName.replaceFirst('\\.[^.]*$','') + '.d.ts').contents = sourceElements.map [ clazz |
			'''
				interface «clazz.simpleName» {
					«FOR field : clazz.declaredFields»
						«field.simpleName»: «toJS(field.type)»;
					«ENDFOR»
				} 
			'''
		].join('\n');
	}
	
	def toJS(TypeReference type) {
		val number = #['short','int','long','float','double','integer','biginteger','bigdecimal']
		if(number.contains(type.simpleName.toLowerCase)) {
			'number'
		}else if(type.simpleName.equals('String')){
			'string';
		}else if(type.simpleName.equalsIgnoreCase('boolean')){
			'boolean'
		}else{
			type.simpleName.replace('List<','Array<')
		}
	}

}
